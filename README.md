FROM php:7.1-apache
LABEL maintainer="FCV Interactive"

Tagged: localdev:web-php71-drupal-dev

Note: Drupal v8.4.x is not PHP v7.2 ready. They did try. 

INCLUDES...
 - apache 2.4; ssl, rewrite, proxy, proxy_http, headers
 - php 7.1; xdebug, memcache, opcache, gd, bcmath
 - composer
 - drush launcher
 - drupal console
 - tideways profiler
 - new relic
