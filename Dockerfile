FROM ubuntu:16.04
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	software-properties-common && LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	apache2 apt-utils zip curl git php7.1 php7.1-curl php7.1-dev php7.1-mbstring php7.1-xml php7.1-intl php7.1-gd php7.1-mysql php7.1-pgsql php-imagick php7.1-sqlite3 pkg-config build-essential libmemcached-dev zlib1g-dev dos2unix
WORKDIR /root/install

RUN git clone --depth 1 https://github.com/php-memcached-dev/php-memcached.git && \
	cd php-memcached && \
	phpize && \
	./configure && \
	make && \
	mv modules/ /usr/local/memcached/ 

RUN cp /usr/bin/php7.1 /usr/bin/php && \
	curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer &&\
	composer global require "fxp/composer-asset-plugin:~1.4.2" &&\
	composer global require hirak/prestissimo

RUN \
 sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf && \
 sed -i "s/opcache.enable_cli=.*$/opcache.enable_cli=1/" /etc/php/7.1/apache2/php.ini && \
 echo "extension=/usr/local/memcached/memcached.so" >> /etc/php/7.1/apache2/php.ini&& \
 sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 40M/" /etc/php/7.1/apache2/php.ini && \
 sed -i "s/post_max_size = 8M/post_max_size = 40M/" /etc/php/7.1/apache2/php.ini && \
 sed -i "s/memory_limit = 128M/memory_limit = 256M/" /etc/php/7.1/apache2/php.ini && \
 sed -i "s/DocumentRoot.*/DocumentRoot \/var\/www\/web/" /etc/apache2/sites-available/000-default.conf

ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    FRONTEND = frontend.test \
    BACKEDN = backend.test

COPY ./conf/conf-available/* /etc/apache2/conf-available/
COPY ./conf/mods-available/* /etc/apache2/mods-available/
COPY /conf/000-default.conf /etc/apache2/sites-available/
COPY ./scripts/boot.sh /root/scripts/boot.sh
COPY ./auth.json /root/.composer/auth.json
RUN dos2unix /root/scripts/boot.sh && chmod +x /root/scripts/*
RUN a2enmod remoteip && a2enconf remoteip && a2enmod rewrite && a2enmod php7.1
RUN rm -rf /var/www/html/ && \
	chown -R www-data:www-data /var/www/ &&\
	chown -R www-data:www-data /var/lib/php
ADD http://download.icu-project.org/files/icu4c/60.1/icu4c-60_1-Ubuntu16.04-x64.tgz /root/install
RUN tar -xzf /root/install/icu4c-60_1-Ubuntu16.04-x64.tgz -C /root/install && cp -r /root/install/icu/usr / && rm -rf /root/install
WORKDIR /var/www
EXPOSE 80
CMD ["/root/scripts/boot.sh"]