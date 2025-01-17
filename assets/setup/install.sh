#!/bin/bash
set -e


ACTIVEMQ_VERSION="5.14.3"
ACTIVEMQ_HOME="/opt/activemq"
SETUP_DIR="/app/setup"
LOG_DIR="/var/log"
DATA_DIR="/data"

# Start install
mkdir -p ${ACTIVEMQ_HOME}
cd /usr/src
curl --fail -LO https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz
tar -xvzf apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz
mv apache-activemq-${ACTIVEMQ_VERSION}/* ${ACTIVEMQ_HOME}
rm -rf /usr/src/*

cd /app
mkdir -p /data/activemq
mkdir -p /var/log/activemq
groupadd activemq
useradd --system --home ${ACTIVEMQ_HOME} -g activemq activemq


chown -R activemq:activemq ${ACTIVEMQ_HOME}
chown -R activemq:activemq ${DATA_DIR}/activemq
chown -R activemq:activemq ${LOG_DIR}/activemq



# We setup logrotate for activemq
cat > /etc/logrotate.d/activemq <<EOF
${LOG_DIR}/activemq/*.log {
  su activemq activemq
  daily
  missingok
  rotate 10
  compress
  copytruncate
  dateext
  dateformat -%Y-%m-%d
}
EOF

# configure supervisord log rotation
cat > /etc/logrotate.d/supervisord <<EOF
${LOG_DIR}/supervisor/*.log {
  daily
  missingok
  rotate 10
  compress
  copytruncate
  dateext
  dateformat -%Y-%m-%d
}
EOF


# configure supervisord to start crond
cat > /etc/supervisor/conf.d/cron.conf <<EOF
[program:cron]
priority=20
directory=/tmp
command=/usr/sbin/cron -f
user=root
autostart=true
autorestart=true
stdout_logfile=${LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisord to start activeMQ
cat > /etc/supervisor/conf.d/activemq.conf <<EOF
[program:activemq]
priority=20
directory=/tmp
command=/opt/activemq/bin/activemq console
user=root
autostart=true
autorestart=true
stdout_logfile=${LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${LOG_DIR}/supervisor/%(program_name)s.log
EOF
