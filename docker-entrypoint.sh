#!/bin/bash

#Attempt to make Django migrations against the database
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
echo "from django.contrib.auth.models import User; User.objects.filter(email='admin@example.com').delete(); User.objects.create_superuser('admin', 'admin@example.com', 'Admin123')" | python3 manage.py shell
python3 manage.py collectstatic --clear --noinput
python3 manage.py collectstatic --noinput


touch /srv/logs/gunicorn.log
touch /srv/logs/access.log
chmod +w /srv/logs/*.log

#Nginx won't run until it can put its pid file in this directory
mkdir -p /run/nginx/

#Gunicorn is the WSGI server that calls the Django python code
echo Starting Gunicorn
exec gunicorn guest_portal.wsgi:application \
	--bind unix:/srv/code/django_app.sock \
	--workers 3 \
	--log-level=info \
	--log-file=/srv/logs/gunicorn.log \
	--access-logfile=/srv/logs/access.log &

#Nginx is the web server that serves the static content directly, and sends the dynamic requests to Gunicorn
echo Starting nginx
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf
