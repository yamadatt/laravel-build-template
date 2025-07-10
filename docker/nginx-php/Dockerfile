# Dockerimage の指定（nginx と PHP-FPM の両方を含む）
FROM php:8.2-fpm

# 必要なパッケージとnginxをインストール
RUN apt-get update \
    && apt-get install -y \
        zlib1g-dev \
        mariadb-client \
        vim \
        libzip-dev \
        nginx \
        supervisor \
        cron \
    && docker-php-ext-install zip pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PHP設定をコピー
COPY docker/php/php.ini /usr/local/etc/php/

# Nginx設定をコピー
COPY docker/nginx-php/nginx.conf /etc/nginx/sites-available/default

# Supervisor設定をコピー
COPY docker/nginx-php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

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

# Laravel Package install
RUN composer global require "laravel/installer"

# エントリーポイントスクリプトをコピー
COPY docker/nginx-php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# デバッグ用のPHPファイルを作成
RUN echo '<?php phpinfo(); ?>' > /tmp/info.php

# nginxとphp-fpmのデフォルトディレクトリを作成
RUN mkdir -p /var/run/nginx /var/log/nginx /var/log/php /var/run/php

# nginxのデフォルト設定を削除
RUN rm -f /etc/nginx/sites-enabled/default

# ポート80を開放
EXPOSE 80

# エントリーポイントを設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
