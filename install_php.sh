#!/bin/sh

#  fetch php
cd /tmp

curl -L  "http://nz2.php.net/get/php-7.0.5.tar.bz2/from/this/mirror" > php-7.0.5.tar.bz2
tar -xvjf php-7.0.5.tar.bz2
cd php-7.0.5

# can't find ldap libs for some reason
ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ 
ln -s /usr/lib/x86_64-linux-gnu/libldap_r.so /usr/lib/
ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/
ln -s /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 /usr/lib/
ln -s /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2.10.3 /usr/lib/

# Configure, Compile and Install
./configure --with-apxs2=/usr/local/apache2/bin/apxs --without-pear  --enable-mbstring --with-openssl --with-ldap --with-gd --with-zlib
make 
make install

# Add to apache
cp -p .libs/*.so /usr/local/apache/modules/

# Clean up
rm -rf /tmp/php*



