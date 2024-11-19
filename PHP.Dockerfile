FROM php:8.1-fpm

RUN apt-get update && apt-get install -y zlib1g-dev libpng-dev libjpeg-dev libxml2-dev libzip-dev libxslt-dev libldap-dev locales graphviz
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install pdo pdo_mysql mysqli gd soap intl zip xsl opcache ldap
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN localedef -c -i en_AU -f UTF-8 en_AU.UTF-8

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY ./moodlephp.ini "$PHP_INI_DIR/conf.d/moodlephp.ini"
COPY ./moodlephpfpm.conf "/usr/local/etc/php-fpm.d"

# install the xhprof extension to profile requests
RUN curl "http://pecl.php.net/get/xhprof-2.3.10.tgz" -fsL -o ./xhprof-2.3.10.tgz && \
    mkdir /var/xhprof && tar xf ./xhprof-2.3.10.tgz -C /var/xhprof && \
    cd /var/xhprof/xhprof-2.3.10/extension && \
    phpize && \
    ./configure && \
    make && \
    make install

RUN docker-php-ext-enable xhprof

# custom settings for xhprof
COPY ./xhprof.ini /usr/local/etc/php/conf.d/xhprof.ini

#folder for xhprof profiles (same as in file xhprof.ini)
RUN mkdir -m 777 /profiles

#folder for www-data to write to
RUN chmod -R 0777 /var/cache/fontconfig
