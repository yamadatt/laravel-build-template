# ===== Build Stage =====
FROM php:8.2-fpm-alpine as builder

# ビルドに必要なパッケージをインストール（Alpine用）
RUN apk add --no-cache --virtual .build-deps \
        libzip-dev \
        zlib-dev \
        curl \
        unzip \
    && apk add --no-cache \
        libzip \
        mysql-client \
    && docker-php-ext-install zip pdo_mysql \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Composer install（軽量化、バージョン固定）
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=2.6.6

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# Laravel Package install（エラーハンドリング強化）
RUN mkdir -p /composer \
    && composer global require "laravel/installer" --no-interaction --quiet \
    && composer clear-cache

# ===== Production Stage =====
FROM php:8.2-fpm-alpine

# 本番環境用の必要なパッケージのみインストール
RUN apk add --no-cache \
        nginx \
        supervisor \
        mysql-client \
        libzip \
        tzdata \
        bash \
    && rm -rf /var/cache/apk/*

# タイムゾーンを設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ビルドステージから必要なファイルをコピー
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer
COPY --from=builder /composer /composer

# PHP設定をコピー
COPY docker/php/php.ini /usr/local/etc/php/

# Nginx設定をコピー（Alpine用のパス）
COPY docker/nginx-php/nginx.conf /etc/nginx/http.d/default.conf

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

# nginxとphp-fpmのディレクトリを作成（Alpine用）
RUN mkdir -p \
        /run/nginx \
        /var/log/nginx \
        /var/log/php \
        /run/php \
        /var/log/supervisor

# 最終的なクリーンアップ
RUN rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && find /usr/local/lib/php/extensions -name "*.a" -delete 2>/dev/null || true

# ポート80を開放
EXPOSE 80

# エントリーポイントを設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
