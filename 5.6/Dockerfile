FROM ywfwj2008/php:5.6
MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV NGINX_INSTALL_DIR=/usr/local/nginx \
    NGINX_VERSION=1.10.2 \
    PCRE_VERSION=8.39 \
    OPENSSL_VERSION=1.0.2j \
    RUN_USER=www \
    WWWROOT_DIR=/home/wwwroot \
    WWWLOGS_DIR=/home/wwwlogs \
    REMOTE_PATH=https://github.com/ywfwj2008/docker-php-nginx/raw/master

RUN apt-get update && apt-get upgrade -yqq && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# install tengine
RUN wget -c --no-check-certificate ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz && \
    wget -c --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    wget -c --no-check-certificate http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar xzf pcre-${PCRE_VERSION}.tar.gz && \
    tar xzf openssl-${OPENSSL_VERSION}.tar.gz && \
    tar xzf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    # Modify Nginx version
    #sed -i 's@#define NGINX_VERSION.*$@#define NGINX_VERSION      "1.2"@' src/core/nginx.h
    #sed -i 's@#define NGINX_VER.*NGINX_VERSION$@#define NGINX_VER          "nginx/" NGINX_VERSION@' src/core/nginx.h
    #sed -i 's@Server: nginx@Server: unknow@' src/http/ngx_http_header_filter_module.c
    # close debug
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc && \
    ./configure \
        --prefix=${NGINX_INSTALL_DIR} \
        --user=${RUN_USER} --group=${RUN_USER} \
        --with-http_stub_status_module \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-ipv6 \
        --with-http_gzip_static_module \
        --with-http_realip_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-openssl=/tmp/openssl-${OPENSSL_VERSION} \
        --with-pcre=/tmp/pcre-${PCRE_VERSION} \
        --with-pcre-jit \
        --with-ld-opt='-ljemalloc' && \
    make && make install && \
    mkdir -p ${NGINX_INSTALL_DIR}/conf/rewrite && \
    touch ${NGINX_INSTALL_DIR}/conf/rewrite/none.conf && \
    rm -rf /tmp/*

ADD ${REMOTE_PATH}/conf/nginx.conf ${NGINX_INSTALL_DIR}/conf/nginx.conf
ADD ${REMOTE_PATH}/conf/proxy.conf ${NGINX_INSTALL_DIR}/conf/proxy.conf
ADD ${REMOTE_PATH}/etc/init.d/nginx /etc/init.d/nginx
ADD ${REMOTE_PATH}/etc/logrotate.d/nginx /etc/logrotate.d/nginx

RUN sed -i "s@/usr/local/nginx@$NGINX_INSTALL_DIR@g" /etc/init.d/nginx && \
    chmod +x /etc/init.d/nginx && \
    update-rc.d nginx defaults && \
    ln -s ${NGINX_INSTALL_DIR}/sbin/nginx /usr/sbin/nginx && \
    ldconfig

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
