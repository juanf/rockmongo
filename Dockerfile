FROM php:7.2.6-cli-alpine3.7

# Install RockMongo
RUN cd /root && wget --no-check-certificate https://github.com/juanf/rockmongo/archive/php70.zip -O rockmongo.zip
RUN cd /root && unzip rockmongo.zip -d /var/ && rm -fr /var/www && mv /var/rockmongo-php70/ /var/www
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /var/www
# RUN docker-php-ext-install mongodb
# RUN pecl install mongodb
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && apk del $PHPIZE_DEPS
RUN cd /var/www && php composer.phar install
RUN cd /var/www && cp config.sample.php config.php \
    && cp app/configs/rplugin.sample.php app/configs/rplugin.php
EXPOSE 8000
CMD cd /var/www && php -S 0.0.0.0:8000 -d display_errors=0 -d expose_php=0