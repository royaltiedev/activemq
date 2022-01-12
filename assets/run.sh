#!/bin/bash

python2 /app/entrypoint/Init.py
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
