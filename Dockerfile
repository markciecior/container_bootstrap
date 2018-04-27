# Set the base image to use to Ubuntu
FROM alpine:3.6

#Disable buffering to stdin/stdout
ENV PYTHONUNBUFFERED 1

# Set the file maintainer
MAINTAINER Carrier Access IT

# Set env variables used in this Dockerfile (add a unique prefix, such as DOCKYARD)
# Local directory with project source
ENV DOCKYARD_SRC=code/guest_portal
# Directory in container for all project files
ENV DOCKYARD_SRVHOME=/srv
# Directory in container for project source files
ENV DOCKYARD_SRVPROJ=$DOCKYARD_SRVHOME/$DOCKYARD_SRC

# Update the default application repository sources list
RUN apk add --no-cache --update \
    python3 \
    nginx \
    nano \
    libpq \
    py3-psycopg2 \
    bash

# Create application subdirectories
WORKDIR $DOCKYARD_SRVHOME
RUN mkdir media static logs

# Copy application source code to SRCDIR
COPY $DOCKYARD_SRC $DOCKYARD_SRVPROJ

# Install Python dependencies
RUN pip3 install --no-cache-dir -r $DOCKYARD_SRVPROJ/requirements.txt

# Port to expose
EXPOSE 80

# Copy entrypoint script into the image
WORKDIR $DOCKYARD_SRVPROJ
COPY ./docker-entrypoint.sh /
COPY ./django_nginx.conf /etc/nginx/sites-available/
COPY ./nginx.conf /etc/nginx/
RUN mkdir -p /etc/nginx/sites-enabled/
RUN ln -s /etc/nginx/sites-available/django_nginx.conf /etc/nginx/sites-enabled/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
