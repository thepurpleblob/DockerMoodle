FROM php:8.1-fpm

RUN apt-get update && apt-get install -y zlib1g-dev libpng-dev libjpeg-dev libxml2-dev libzip-dev libxslt-dev libldap-dev locales
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install pdo pdo_mysql mysqli gd soap intl zip xsl opcache ldap
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
RUN localedef -c -i en_AU -f UTF-8 en_AU.UTF-8

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY ./moodlephp.ini "$PHP_INI_DIR/conf.d/moodlephp.ini"
COPY ./moodlephpfpm.conf "/usr/local/etc/php-fpm.d"
