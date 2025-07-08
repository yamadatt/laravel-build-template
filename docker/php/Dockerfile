# Dockerimage の指定
FROM php:8.2-fpm
COPY docker/php/php.ini /usr/local/etc/php/

# Package & Library install
RUN apt-get update \
    && apt-get install -y zlib1g-dev mariadb-client vim libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# WorkDir Path setting
WORKDIR /var/www

# Laravelプロジェクトはvolumeでマウントされるため、COPYは不要

# Laravel Package install
RUN composer global require "laravel/installer"

# エントリーポイントスクリプトをコピー
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# エントリーポイントを設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]