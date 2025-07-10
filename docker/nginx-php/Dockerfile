# ===== Build Stage =====
FROM php:8.2-fpm as builder

# 必要なパッケージをインストール（ビルド用）
RUN apt-get update \
    && apt-get install -y \
        zlib1g-dev \
        libzip-dev \
        unzip \
        curl \
    && docker-php-ext-install zip pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# Laravel Package install
RUN composer global require "laravel/installer"

# ===== Production Stage =====
FROM php:8.2-fpm

# 必要なパッケージのみインストール（本番用）
RUN apt-get update \
    && apt-get install -y \
        libzip4 \
        mariadb-client \
        nginx \
        supervisor \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /tmp/* \
        && rm -rf /var/tmp/*

# ビルドステージから必要なファイルをコピー
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer
COPY --from=builder /composer /composer

# PHP設定をコピー
COPY docker/php/php.ini /usr/local/etc/php/

# Nginx設定をコピー
COPY docker/nginx-php/nginx.conf /etc/nginx/sites-available/default

# Supervisor設定をコピー
COPY docker/nginx-php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# WorkDir Path setting
WORKDIR /var/www

# エントリーポイントスクリプトをコピー
COPY docker/nginx-php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# デバッグ用のPHPファイルを作成
RUN echo '<?php phpinfo(); ?>' > /tmp/info.php

# nginxとphp-fpmのデフォルトディレクトリを作成
RUN mkdir -p /var/run/nginx /var/log/nginx /var/log/php /var/run/php

# nginxのデフォルト設定を削除
RUN rm -f /etc/nginx/sites-enabled/default

# 不要なファイルを削除してサイズを削減
RUN apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /usr/share/man/* \
    && rm -rf /usr/share/doc/*

# ポート80を開放
EXPOSE 80

# エントリーポイントを設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
