FROM php:7.1-apache
LABEL maintainer="FCV Interactive"


INCLUDES...
 - apache 2.4; ssl, rewrite, proxy, proxy_http, headers
 - php 7.2; xdebug, memcache, opcache, gd, bcmath
 - composer
 - drush launcher
 - drupal console
 - tideways profiler
 - new relic
