FROM ywfwj2008/php:5.4
MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV APACHE_INSTALL_DIR=/usr/local/apache \
    APACHE_VERSION=2.4.23 \
    PCRE_VERSION=8.39 \
    APR_VERSION=1.5.2 \
    APR_UTIL_VERSION=1.5.4 \
    RUN_USER=www \
    WWWROOT_DIR=/home/wwwroot \
    WWWLOGS_DIR=/home/wwwlogs \
    REMOTE_PATH=https://github.com/ywfwj2008/docker-php-apache/raw/master

RUN apt-get update && apt-get upgrade -yqq && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# install apache
RUN wget -c --no-check-certificate ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz && \
    wget -c --no-check-certificate http://archive.apache.org/dist/apr/apr-${APR_VERSION}.tar.gz && \
    wget -c --no-check-certificate http://archive.apache.org/dist/apr/apr-util-${APR_UTIL_VERSION}.tar.gz && \
    wget -c --no-check-certificate http://mirrors.linuxeye.com/apache/httpd/httpd-${APACHE_VERSION}.tar.gz && \
    tar xzf pcre-$PCRE_VERSION.tar.gz && \
    cd pcre-$PCRE_VERSION && \
    ./configure && \
    make && make install && \
    cd .. && \
    tar xzf httpd-$APACHE_VERSION.tar.gz && \
    tar xzf apr-$APR_VERSION.tar.gz && \
    tar xzf apr-util-$apr_util_version.tar.gz && \
    cd httpd-$APACHE_VERSION && \
    mkdir -p $APACHE_INSTALL_DIR && \
    /bin/cp -R ../apr-$APR_VERSION ./srclib/apr && \
    /bin/cp -R ../apr-util-$apr_util_version ./srclib/apr-util && \
    LDFLAGS=-ldl ./configure --prefix=$APACHE_INSTALL_DIR \
            --with-mpm=prefork \
            --with-included-apr \
            --enable-headers \
            --enable-deflate \
            --enable-so \
            --enable-dav \
            --enable-rewrite \
            --enable-ssl \
            --with-ssl \
            --enable-expires \
            --enable-static-support \
            --enable-suexec \
            --enable-modules=all \
            --enable-mods-shared=all && \
    make && make install && \
    unset LDFLAGS && \
    rm -rf /tmp/*

  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$APACHE_INSTALL_DIR/bin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $APACHE_INSTALL_DIR /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$APACHE_INSTALL_DIR/bin:\1@" /etc/profile
  . /etc/profile

  /bin/cp $APACHE_INSTALL_DIR/bin/apachectl /etc/init.d/httpd
  sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
  sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
  chmod +x /etc/init.d/httpd
  [ "$OS" == 'CentOS' ] && { chkconfig --add httpd; chkconfig httpd on; }
  [[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d httpd defaults

  sed -i "s@^User daemon@User $RUN_USER@" $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -i "s@^Group daemon@Group $RUN_USER@" $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -i "s@#AddHandler cgi-script .cgi@AddHandler cgi-script .cgi .pl@" $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -ri 's@^#(.*mod_suexec.so)@\1@' $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -ri 's@^#(.*mod_vhost_alias.so)@\1@' $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -ri 's@^#(.*mod_rewrite.so)@\1@' $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -ri 's@^#(.*mod_deflate.so)@\1@' $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -ri 's@^#(.*mod_expires.so)@\1@' $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -ri 's@^#(.*mod_ssl.so)@\1@' $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -i "s@^DocumentRoot.*@DocumentRoot \"$WWWROOT_DIR/default\"@" $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -i "s@^<Directory \"$APACHE_INSTALL_DIR/htdocs\">@<Directory \"$WWWROOT_DIR/default\">@" $APACHE_INSTALL_DIR/conf/httpd.conf
  sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" $APACHE_INSTALL_DIR/conf/httpd.conf

  #logrotate apache log
  cat > /etc/logrotate.d/apache << EOF
$WWWLOGS_DIR/*apache.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -f $APACHE_INSTALL_DIR/logs/httpd.pid ] && kill -USR1 \`cat $APACHE_INSTALL_DIR/logs/httpd.pid\`
  endscript
}
EOF

  mkdir $APACHE_INSTALL_DIR/conf/vhost
  cat > $APACHE_INSTALL_DIR/conf/vhost/0.conf << EOF
<VirtualHost *:$TMP_PORT>
  ServerAdmin admin@linuxeye.com
  DocumentRoot "$WWWROOT_DIR/default"
  ServerName $TMP_IP
  ErrorLog "$WWWLOGS_DIR/error_apache.log"
  CustomLog "$WWWLOGS_DIR/access_apache.log" common
<Directory "$WWWROOT_DIR/default">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  Require all granted
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
<Location /server-status>
  SetHandler server-status
  Order Deny,Allow
  Deny from all
  Allow from 127.0.0.1
</Location>
</VirtualHost>
EOF

  cat >> $APACHE_INSTALL_DIR/conf/httpd.conf <<EOF
<IfModule mod_headers.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
  <FilesMatch "\.(js|css|html|htm|png|jpg|swf|pdf|shtml|xml|flv|gif|ico|jpeg)\$">
    RequestHeader edit "If-None-Match" "^(.*)-gzip(.*)\$" "\$1\$2"
    Header edit "ETag" "^(.*)-gzip(.*)\$" "\$1\$2"
  </FilesMatch>
  DeflateCompressionLevel 6
  SetOutputFilter DEFLATE
</IfModule>

ServerTokens ProductOnly
ServerSignature Off
Include conf/vhost/*.conf
EOF

  if [ "$Nginx_version" != '4' -o -e "$web_install_dir/sbin/nginx" ]; then
    cat > $APACHE_INSTALL_DIR/conf/extra/httpd-remoteip.conf << EOF
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 127.0.0.1
EOF
    sed -i "s@Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf\nInclude conf/extra/httpd-remoteip.conf@" $APACHE_INSTALL_DIR/conf/httpd.conf
    sed -i "s@LogFormat \"%h %l@LogFormat \"%h %a %l@g" $APACHE_INSTALL_DIR/conf/httpd.conf
  fi
  ldconfig
  service httpd start
  popd



# ending
WORKDIR ${WWWROOT_DIR}
RUN mkdir -p ${WWWLOGS_DIR} && \
    mkdir -p ${WWWROOT_DIR}/default && \
    echo "Hello World!" > /${WWWROOT_DIR}/default/index.html && \
    echo "<?php phpinfo();" > /${WWWROOT_DIR}/default/phpinfo.php

# expose port
EXPOSE 80 443

# Set the entrypoint script.
ADD ${REMOTE_PATH}/entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Define the default command.
CMD ["nginx", "-g", "daemon off;"]
