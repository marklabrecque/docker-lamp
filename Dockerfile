FROM php:7.1-apache
LABEL maintainer="FCV Interactive"


# INCLUDES...
#  - apache 2.4; ssl, rewrite, proxy, proxy_http, headers
#  - php 7.1; xdebug, memcache, opcache, gd, bcmath
#  - composer
#  - drush launcher
#  - drupal console
#  - tideways profiler
#  - new relic

# For space saving reasons source is compressed, thus...
RUN docker-php-source extract


# Essentials
RUN apt-get update \
  && apt-get install -y \
   nano \
   vim \
   wget \
   rsync \
   build-essential \
   git \
   zlibc zlib1g zlib1g-dev \
   bzip2 \
   zip \
   unzip \
   sudo \
    \
   mysql-client \
    \
   libgd2-xpm-dev \
   libfreetype6-dev \
   libjpeg62-turbo-dev \
   libpng-dev \
   libz-dev \
   libmemcached-dev \
   libmemcached11 \
   libmemcachedutil2 \
    \
   gnupg2

COPY files/php/php.ini /usr/local/etc/php/

## XDEBUG current in beta1 release as of 2017-12-28; works with PHP 7.2.
RUN git clone https://github.com/xdebug/xdebug.git \
  && cd xdebug \
  && ./rebuild.sh
RUN docker-php-ext-enable xdebug
RUN cd ../ && rm -rf ./xdebug

# Install PHP Redis
# RUN pecl install redis && docker-php-ext-enable redis

# Enable MySQL
RUN docker-php-ext-install pdo_mysql

# Enable GD (with jpeg and freetype support)
RUN pecl install memcached \
  && echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-install opcache \
  && docker-php-ext-install bcmath

# Enable mod_rewrite
RUN a2enmod rewrite

# Enable Proxy
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod ssl
RUN a2enmod headers


# User managment, use regular use "appuser"
RUN useradd -ms /bin/bash appuser


# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

# Install Composer
#RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=1.3.1 && rm -rf /tmp/composer-setup.php
RUN php /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer \
  && rm /tmp/composer-setup.php

# Install Drush (PHP/Drupal)
# Drush 9 has to be installed in Drupal project.
RUN composer global require drush/drush ^9.0.0-rc2

# Install Drush Launcher
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest \
 && chmod +x drush.phar \
 && mv drush.phar /usr/local/bin/drush \
 && drush init

# Install Drupal Console
RUN curl https://drupalconsole.com/installer -L -o drupal.phar \
  && chmod +x drupal.phar \
  && mv drupal.phar /usr/local/bin/drupal \
  && drupal init --yes --no-interaction --destination /root/.console/ --autocomplete --ansi --no-interaction \
  && echo 'source "/root/.console/console.rc" 2>/dev/null' >> ~/.bashrc


# Install Tideways
RUN echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list \
  && wget -qO - https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - \
  && apt-get update \
  && apt-get install tideways-php tideways-daemon \
  && docker-php-ext-enable tideways


# Install NewRelic
RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
  && wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install newrelic-php5 \
  && bash newrelic-install install \
  && mkdir -p /var/log/newrelic \
  && mkdir -p /var/run/newrelic


# Copy fake SSL certs for dev site.
COPY ./files/ssl/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil.key
COPY ./files/ssl/ssl-cert-snakeoil.pem /etc/ssl/certs/ssl-cert-snakeoil.pem


COPY ./files/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./files/sites-available/001-default-ssl.conf /etc/apache2/sites-available/001-default-ssl.conf

# enable the SSL dev site
RUN a2ensite 001-default-ssl

# install the certs
COPY ./files/sf_bundle-g2-g1.crt /usr/local/share/ca-certificates
RUN chmod 644 /usr/local/share/ca-certificates/sf_bundle-g2-g1.crt

RUN update-ca-certificates

## Try fix aufs file permission issue
# - https://github.com/moby/moby/issues/6047
RUN rm -rf /var/www/web \
  && mkdir -p /var/www/web/sites/default \
  && chmod a+x /var/www/web/sites/default \
  && chown www-data:www-data -R /var/www/web

RUN usermod -aG www-data appuser
RUN usermod -aG appuser www-data

# Create mount point for sites/default/files
VOLUME /var/www/web/sites/default/files

ENV HOME /home/appuser
WORKDIR /var/www

EXPOSE 80 443

#COPY ./files/run /usr/local/bin/run
#RUN chmod +x /usr/local/bin/run

#CMD ["/usr/local/bin/run"]

# Clean up - delete exploded source to save space
RUN docker-php-source delete

RUN php --version
RUN composer --version
RUN drush version
RUN drupal --version
