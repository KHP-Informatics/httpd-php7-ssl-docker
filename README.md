# apache-php-ssl-docker

This container has apache set up with php5 and ssl, but it doesn't have any application data.

/var/www/php-app is a volume and is where apache will look for you php app.

If you want to edit the Dockerfile to grab your applicaiton files, make sure you do this
before the VOLUME line or they'll be over-written.


### TO BUILD:

docker build -t whatever/apache-php-ssl-docker:0.1 .

### TO RUN:

Run an instance as a data container and get your php application 
into the /var/www/php-app directory.  
curl, wget and git are all available.  

Once you're done, you can exit the container (unless you want to
use it to develop your app). It doesn't need to be running for 
us to access the volume from a second container. 

The container provides a self-signed SSL cert but if you have a 
proper one you can also bind-mount the key and cert files at 
this point

Similarly, if you want to send mail through php the container has ssmtp
installed, but you'll need to provide a valid config file with details
of your smtp server, e.g.:

  hostname=my.server.com
  mailhub=smtp.gmail.com:587
  UseSTARTTLS=YES
  AuthUser=someuser@gmail.com
  AuthPass=somepass

(
 note - if you're using a Google account with 2-factor authentication then
 you will need to generate an app password for AuthPass which you can do at
 https://security.google.com/settings/security/apppasswords
)

So, run your data container something like:

    docker run -it --name=php-app-data \
    -v /tmp/server.pem:/usr/local/apache2/conf/server.pem \
    -v /tmp/server.key:/usr/local/apache2/conf/server.key \
    -v /tmp/ssmtp.conf:/etc/ssmtp/ssmtp.conf\
    cassj/apache-php-ssl-docker:0.1  /bin/bash

      cd /var/www/php-app
      printf "<?php\nphpinfo();\n?>\n" > index.php 
      chown apache:apache test.php
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
              cassj/apache-php-ssl-docker:0.1



