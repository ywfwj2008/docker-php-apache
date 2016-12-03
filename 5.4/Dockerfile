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

WORKDIR /tmp

# install apache
RUN wget -c --no-check-certificate ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz && \
    wget -c --no-check-certificate http://archive.apache.org/dist/apr/apr-${APR_VERSION}.tar.gz && \
    wget -c --no-check-certificate http://archive.apache.org/dist/apr/apr-util-${APR_UTIL_VERSION}.tar.gz && \
    wget -c --no-check-certificate http://mirrors.linuxeye.com/apache/httpd/httpd-${APACHE_VERSION}.tar.gz && \
    tar xzf pcre-${PCRE_VERSION}.tar.gz && \
    cd pcre-${PCRE_VERSION} && \
    ./configure && \
    make && make install && \
    cd .. && \
    tar xzf httpd-${APACHE_VERSION}.tar.gz && \
    tar xzf apr-${APR_VERSION}.tar.gz && \
    tar xzf apr-util-${APR_UTIL_VERSION}.tar.gz && \
    cd httpd-${APACHE_VERSION} && \
    mkdir -p ${APACHE_INSTALL_DIR} && \
    /bin/cp -R ../apr-${APR_VERSION} ./srclib/apr && \
    /bin/cp -R ../apr-util-${APR_UTIL_VERSION} ./srclib/apr-util && \
    LDFLAGS=-ldl ./configure --prefix=${APACHE_INSTALL_DIR} \
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

# run install script
ADD $REMOTE_PATH/install.sh /tmp/install.sh
RUN chmod 777 install.sh && \
    bash install.sh && \
    rm -rf /tmp/*

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
CMD ["httpd", "-D", "FOREGROUND"]
