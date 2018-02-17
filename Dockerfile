FROM marklabrecque/webdev:latest
LABEL maintainer="Mark Labrecque"

# Install Drush (PHP/Drupal) - version 9 is minimum for latest version of Drupal
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

RUN php --version
RUN composer --version
RUN drush version
RUN drupal --version