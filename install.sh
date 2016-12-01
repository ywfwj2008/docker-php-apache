#!/bin/bash

APACHE_INSTALL_DIR=/usr/local/apache
RUN_USER=www
WWWROOT_DIR=/home/wwwroot
WWWLOGS_DIR=/home/wwwlogs

[ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$APACHE_INSTALL_DIR/bin:\$PATH" >> /etc/profile
[ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $APACHE_INSTALL_DIR /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$APACHE_INSTALL_DIR/bin:\1@" /etc/profile
source /etc/profile
/bin/cp $APACHE_INSTALL_DIR/bin/apachectl /etc/init.d/httpd
chmod +x /etc/init.d/httpd
ldconfig

# httpd.conf
sed -i "s@^User daemon@User $RUN_USER@" $APACHE_INSTALL_DIR/conf/httpd.conf
sed -i "s@^Group daemon@Group $RUN_USER@" $APACHE_INSTALL_DIR/conf/httpd.conf
sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' $APACHE_INSTALL_DIR/conf/httpd.conf
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
<VirtualHost *:80>
  ServerAdmin admin@admin.com
  DocumentRoot "$WWWROOT_DIR/default"
  ServerName 127.0.0.1
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
