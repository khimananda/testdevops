#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt update && apt upgrade -y
apt install zip unzip awscli jq openjdk-11-jdk-headless -y

#install cloudwatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb && dpkg -i amazon-cloudwatch-agent.deb

#Create zookeeper user
useradd --comment "ZooKeeper" --shell "/usr/sbin/nologin" --system --user-group zookeeper

mkdir -p ${DATA_DIR}
wget -O - https://archive.apache.org/dist/zookeeper/zookeeper-${APACHE_ZOOKEEPER_version}/zookeeper-${APACHE_ZOOKEEPER_version}.tar.gz | sudo tar -xz -C /opt/
mv /opt/zookeeper-${APACHE_ZOOKEEPER_version} /opt/zookeeper
chown zookeeper:zookeeper -R ${DATA_DIR} /opt/zookeeper

cat > /etc/systemd/system/${SERVICE_NAME} << EOF
[Unit]
Description=ZooKeeper Service
Documentation=http://zookeeper.apache.org
Requires=network.target
After=network.target

[Service]
Type=forking
WorkingDirectory=/opt/zookeeper
User=zookeeper
Group=zookeeper
ExecStart=/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
ExecStop=/opt/zookeeper/bin/zkServer.sh stop /opt/zookeeper/conf/zoo.cfg
ExecReload=/opt/zookeeper/bin/zkServer.sh restart /opt/zookeeper/conf/zoo.cfg
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=default.target
EOF

cat > /opt/zookeeper/conf/zoo.cfg << EOF
dataDir=/var/lib/zookeeper
dataLogDir=/var/lib/zookeeper/datalog
tickTime=2000
initLimit=5
syncLimit=2
autopurge.snapRetainCount=3
autopurge.purgeInterval=0
maxClientCnxns=60
standaloneEnabled=true
admin.enableServer=true
server.1=zk1.itonics.services:2888:3888
server.2=zk2.itonics.services:2888:3888
server.3=zk3.itonics.services:2888:3888
clientPort=2181
4lw.commands.whitelist=mntr, conf, ruok
metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpPort=7000
metricsProvider.exportJvmInfo=true

EOF

#set the server ID
echo "${myid}" > ${DATA_DIR}/myid

systemctl daemon-reload
systemctl enable zookeeper
systemctl start zookeeper

#cloudwatch-agent configuration
n=$(curl -s -o /dev/null -w \"%%{http_code}\" http://169.254.169.254/latest/meta-data/placement/region)
if [[ $n -eq 200 ]]; then
    Region=$(curl http://169.254.169.254/latest/meta-data/placement/region)
else
    Region=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\\\" '{print $4}')
fi
aws ssm get-parameter --name "AmazonCloudWatch-linux" --region $Region  | jq -r ".Parameter.Value" > cloudwatchAgent.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -c file:cloudwatchAgent.json -s -a fetch-config -m ec2
