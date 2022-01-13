#!/bin/bash

python2 /app/entrypoint/Init.py

echo ""
echo "---"
echo ""

cat -n /opt/activemq/conf.tmp/jetty.xml

echo ""
echo "---"
echo ""

cat -n /opt/activemq/conf.tmp/log4j.properties

echo ""
echo "---"
echo ""

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
