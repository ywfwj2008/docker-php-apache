FROM php:5.6-apache
MAINTAINER ywfwj2008 <ywfwj2008@163.com>

ENV WWWROOT_DIR=/var/www/html \
    PHP_INSTALL_DIR=/usr/local/bin \
    PHP_CONFIG_DIR=/usr/local/etc/php

RUN apt-get update && apt-get install -y wget \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2-dev \
        libmemcached-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt xml \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# install ImageMagick
RUN wget -c --no-check-certificate http://www.imagemagick.org/download/ImageMagick.tar.gz && \
    tar xzf ImageMagick.tar.gz && \
    cd ImageMagick* && \
    ./configure --enable-shared --enable-static && \
    make -j$(nproc) && make install && \
    rm -rf ImageMagick*

RUN pecl install \
        imagick \
        memcache \
        memcached \
        redis-2.2.8 \
        swoole \
    && docker-php-ext-enable imagick memcache memcached redis swoole opcache

RUN echo "memcached.use_sasl=1" >> ${PHP_CONFIG_DIR}/conf.d/docker-php-ext-memcached.ini

# install composer
RUN curl -sS https://getcomposer.org/installer | ${PHP_INSTALL_DIR}/php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer

RUN echo "Hello World!" > ${WWWROOT_DIR}/index.html && \
    echo "<?php phpinfo();" > ${WWWROOT_DIR}/phpinfo.php

