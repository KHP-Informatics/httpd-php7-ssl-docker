FROM httpd
MAINTAINER Cass Johnston <cassjohnston@gmail.com>

RUN apt-get update && apt-get install -q -y  vim unzip curl bison git openssl libssl-dev pkg-config libpng12-0 libpng12-dev libldap-2.4-2 libldap2-dev bzip2 gcc libapr1-dev libaprutil1-dev libxml2-dev build-essential rsync wget mysql-client ssmtp mailutils && apt-get clean 


# Create a user & group (used in httpd.conf)
RUN groupadd --system apache
RUN useradd --system -g apache apache 

# Install PHP for this Apache
COPY install_php.sh /tmp/install_php.sh
RUN chmod +x /tmp/install_php.sh
RUN /tmp/install_php.sh

## PHP & Apache configuration
COPY php.ini /usr/local/lib/php.ini
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
COPY httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

## Create a location for your application data
RUN mkdir -p /var/www/php-app && chown apache:apache /var/www/php-app

## Install your application's static files at this point, 
## before the location is declared to be a volume


## Make the application dir a volume
VOLUME '/var/www/php-app'

## And create self-signed ssl keys for test purposes (bind mount proper ones to running container)
RUN openssl req -new -x509 -nodes -out /usr/local/apache2/conf/server.pem -keyout /usr/local/apache2/conf/server.key -days 3650 -subj '/CN=localhost'

# http and httpd ports. You can map these to whatever host ports you want with -p
EXPOSE 80
EXPOSE 443

# Default env vars for httpd. You can override these at runtime if you want to
ENV SERVERNAME localhost
ENV ADMINEMAIL root@localhost



