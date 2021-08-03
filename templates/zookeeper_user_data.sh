#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt update && apt upgrade -y
apt install zip unzip openjdk-11-jdk-headless -y


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
tickTime=2000
dataDir=/var/lib/zookeeper
clientPort=2181
initLimit=5
syncLimit=2
server.1=zk1.itonics.services:2888:3888
server.2=zk2.itonics.services:2888:3888
server.3=zk3.itonics.services:2888:3888
EOF

#set the server ID
echo "${myid}" > ${DATA_DIR}/myid

systemctl daemon-reload
systemctl enable zookeeper
systemctl start zookeeper