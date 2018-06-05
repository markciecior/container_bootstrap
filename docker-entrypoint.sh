#!/bin/bash

#Attempt to make Django migrations against the database
python3 manage.py makemigrations
python3 manage.py migrate

#If the return code isn't 0, there was an error (the database probably was not ready).
#Exit this script with a non-zero error code.
#That will cause the docker stack to kill this container and launch another one.
#By then, the database will probably be ready
if [ ! $? -eq 0 ]
then
  exit 1
fi

#Creating the Django superuser (for Admin portal access) requires entering a password interactively.
#This will not work when spinning up a dynamic container, so we do this instead and run the background code directly.
python3 manage.py collectstatic --clear --noinput
python3 manage.py collectstatic --noinput


chmod +w /srv/logs/*.log

#Nginx won't run until it can put its pid file in this directory
mkdir -p /run/nginx/

#Start cron daemon
exec /usr/sbin/crond -f &

#Gunicorn is the WSGI server that calls the Django python code
echo Starting Gunicorn
exec gunicorn cwopp.wsgi:application \
        --bind unix:/srv/code/django_app.sock \
        --workers 3 \
        --log-level=info \
        --log-file=/srv/logs/gunicorn-error.log \
        --access-logfile=/srv/logs/gunicorn-access.log &

#Nginx is the web server that serves the static content directly, and sends the dynamic requests to Gunicorn
echo Starting nginx
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf
