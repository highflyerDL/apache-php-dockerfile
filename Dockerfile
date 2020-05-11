FROM alpine:3.9.6

ENV HTTPD_VERSION=2.4.43 \
    APR_VERSION=1.7.0 \
    APR_UTIL_VERSION=1.6.1 \
    PHP_VERSION=7.4.5

LABEL maintainer="Minh Cao <duyminh2301@gmail.com>"

# Install system dependencies
RUN apk add --update \
    alpine-sdk \
    pcre-dev \
    expat-dev \
    libxml2-dev \
    sqlite-dev \
    openssl-dev \
    autoconf \
    perl

# Download and extract packages
RUN wget http://mirror.netinch.com/pub/apache//httpd/httpd-$HTTPD_VERSION.tar.gz \
 && wget https://www.nic.funet.fi/pub/mirrors/apache.org//apr/apr-$APR_VERSION.tar.gz \
 && wget https://www.nic.funet.fi/pub/mirrors/apache.org//apr/apr-util-$APR_UTIL_VERSION.tar.gz \
 && wget https://www.php.net/distributions/php-$PHP_VERSION.tar.gz \
 && tar -xf php-$PHP_VERSION.tar.gz \
 && tar -xf httpd-$HTTPD_VERSION.tar.gz \
 && mkdir -p /httpd-$HTTPD_VERSION/srclib/apr \
 && mkdir -p /httpd-$HTTPD_VERSION/srclib/apr-util \
 && tar -xf apr-$APR_VERSION.tar.gz --strip-components 1 -C /httpd-$HTTPD_VERSION/srclib/apr \
 && tar -xf apr-util-$APR_UTIL_VERSION.tar.gz --strip-components 1 -C /httpd-$HTTPD_VERSION/srclib/apr-util \
 && rm /*.tar.gz

# Compile and install Apache
RUN cd /httpd-$HTTPD_VERSION/ \
 && ./configure --enable-so --with-included-apr \
 && make && make install \
 && rm -rf /httpd-$HTTPD_VERSION

# Configure Apache
RUN echo "ServerName localhost" >> /usr/local/apache2/conf/httpd.conf \
 && echo -e '<FilesMatch "\.php$">\nSetHandler application/x-httpd-php\n</FilesMatch>' >> /usr/local/apache2/conf/httpd.conf \
 && echo "DirectoryIndex disabled" >> /usr/local/apache2/conf/httpd.conf \
 && echo "DirectoryIndex index.php index.phtml index.html index.htm" >> /usr/local/apache2/conf/httpd.conf

# Compile and install PHP
RUN cd /php-$PHP_VERSION \
 && ./configure --with-apxs2=/usr/local/apache2/bin/apxs --with-pear --with-openssl \
 && make && make install \
 && cp php.ini-development /usr/local/lib/php.ini \
 && rm -rf /php-$PHP_VERSION

# Install PHP extensions
RUN pecl install redis && echo "extension=redis.so" >> /usr/local/lib/php.ini
RUN pecl install xdebug && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-zts-20190902/xdebug.so" >> /usr/local/lib/php.ini

# Configure logs
RUN echo "error_log = /var/log/php-scripts.log" >> /usr/local/lib/php.ini \
 && echo 'ErrorLog "/var/log/httpd-error.log"' >> /usr/local/apache2/conf/httpd.conf \
 && echo 'CustomLog "/var/log/httpd-access.log" "%h %l %u %t \"%r\" %>s %b"' >> /usr/local/apache2/conf/httpd.conf

COPY index.php /usr/local/apache2/htdocs/index.php

EXPOSE 80 80
CMD ["/usr/local/apache2/bin/apachectl", "-D", "FOREGROUND"]
