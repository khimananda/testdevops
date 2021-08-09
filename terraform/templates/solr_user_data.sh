#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt update && apt upgrade -y
apt install zip unzip openjdk-11-jdk-headless -y


#Create zookeeper user
useradd --comment "solr" --shell "/usr/sbin/nologin" --system --user-group solr

mkdir -p ${DATA_DIR}/data
wget -O /tmp/solr.zip https://files.itonicsit.de/_itonics/solr-7.zip && unzip /tmp/solr.zip -d /opt
cp "/opt/solr/server/solr/"{solr.xml,zoo.cfg} "${DATA_DIR}/data/"
cp "/opt/solr/server/resources/log4j2.xml" "${DATA_DIR}/log4j2.xml"
chown solr:solr -R ${DATA_DIR} /opt/solr

cat > /etc/systemd/system/${SERVICE_NAME} << EOF
[Unit]
Description=Apache SOLR

[Service]
Type=forking
User=solr
Environment=SOLR_INCLUDE=/etc/default/solr.in.sh
ExecStart=/opt/solr/bin/solr start -cloud
ExecStop=/opt/solr/bin/solr stop
Restart=on-failure
LimitNOFILE=65000
LimitNPROC=65000
TimeoutSec=180s

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/default/solr.in.sh << EOF
SOLR_HEAP="768m"
SOLR_PID_DIR="/var/solr"
SOLR_HOME="${DATA_DIR}/data"
LOG4J_PROPS="/var/solr/log4j2.xml"
SOLR_LOGS_DIR="/var/solr/logs"
SOLR_PORT="8080"

#Zookeeper related settings
ZK_HOST=zk1.itonics.services:2181,zk2.itonics.services:2181,zk3.itonics.services:2181

EOF

systemctl daemon-reload
systemctl enable solr
systemctl start solr