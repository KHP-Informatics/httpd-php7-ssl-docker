# httpd-php7-ssl

This container has apache set up with php5 and ssl, but it doesn't have any application data.


### TO BUILD:

docker build -t whomever/httpd-php7-ssl:0.1 .

### TO RUN:

Create a data container. Set up your application data, make any necessary changes
to configuration files. Exit the container. 
Use volumes to ensure that changes you make to application data or configuration
settings persist:


VOLUMES:

/var/www/php-app
  Where apache looks for your php application data. 


/usr/local/apache2/conf
  Apache config files. Has functional default settings.
  Provides a self-signed SSL cert in /usr/local/apache2/conf/ssl but replace
  with a real one if you have one.


/etc/ssmtp/ssmtp.conf
  I you want to send mail through php the container has ssmtp installed, but 
  you'll need to provide a valid config file with details of your smtp server.
  There is no default provided. Something like this should work:

  hostname=my.server.com
  mailhub=smtp.gmail.com:587
  UseSTARTTLS=YES
  AuthUser=someuser@gmail.com
  AuthPass=somepass

  If you're using a Google account with 2-factor authentication then you will 
  need to generate an app password for AuthPass which you can do at
  https://security.google.com/settings/security/apppasswords



So, run your data container something like:

    docker run -it --name=php-app-data \
    -v /var/www/php-app \
    -v /usr/local/apache2/conf \
    -v /tmp/ssmtp.conf:/etc/ssmtp/ssmtp.conf\
    cassj/httpd-php7-ssl:0.1  /bin/bash

      cd /var/www/php-app
      printf "<?php\nphpinfo();\n?>\n" > index.php 
      chown apache:apache index.php
      exit


Now you can start an instance of the webserver that will use this
data volume (the environment variables are optional - they have default
values)

  docker run --name=php-app\
              -p 80:80\
              -p 443:443\
              -d\
              -e PORT=80\
              -e SSLPORT=443\
              -e ADMINEMAIL=foo@bar.com\
              -e SERVERNAME=localhost\
              --volumes-from php-app-data\
              cassj/httpd-php7-ssl:0.1

