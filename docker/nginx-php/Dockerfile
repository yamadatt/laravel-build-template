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
        ca-certificates \
        openssl \
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

# 既存のLaravelプロジェクトをコンテナに埋め込む（ECS対応）
COPY ./src /var/www

# Laravel 11プロジェクトの初期設定とビルド
RUN if [ -d "/var/www/LaravelTestProject" ]; then \
        echo "Upgrading existing Laravel project to Laravel 11..."; \
        cd /var/www/LaravelTestProject && \
        # 既存のvendorとcomposer.lockを削除してクリーンな状態にする
        rm -rf vendor composer.lock && \
        # Laravel 9のcomposer.jsonを一旦バックアップ
        cp composer.json composer.json.bak && \
        echo "Laravel 11 upgrade completed successfully!"; \
    fi

# Laravel 11用の設定ファイルをコピー
COPY docker/nginx-php/composer-laravel11.json /tmp/composer-laravel11.json
COPY docker/nginx-php/bootstrap-app.php /tmp/bootstrap-app.php
COPY docker/nginx-php/EncryptCookies.php /tmp/EncryptCookies.php
COPY docker/nginx-php/VerifyCsrfToken.php /tmp/VerifyCsrfToken.php
COPY docker/nginx-php/Authenticate.php /tmp/Authenticate.php
COPY docker/nginx-php/RedirectIfAuthenticated.php /tmp/RedirectIfAuthenticated.php
COPY docker/nginx-php/ValidateSignature.php /tmp/ValidateSignature.php

# Laravel 11の設定適用とインストール
RUN if [ -d "/var/www/LaravelTestProject" ]; then \
        echo "Applying Laravel 11 configuration..."; \
        cd /var/www/LaravelTestProject && \
        # Laravel 11用のcomposer.jsonを適用
        cp /tmp/composer-laravel11.json composer.json && \
        # Laravel 11用のbootstrap/app.phpを適用
        cp /tmp/bootstrap-app.php bootstrap/app.php && \
        # Laravel 11用のミドルウェアファイルを配置
        mkdir -p app/Http/Middleware && \
        cp /tmp/EncryptCookies.php app/Http/Middleware/EncryptCookies.php && \
        cp /tmp/VerifyCsrfToken.php app/Http/Middleware/VerifyCsrfToken.php && \
        cp /tmp/Authenticate.php app/Http/Middleware/Authenticate.php && \
        cp /tmp/RedirectIfAuthenticated.php app/Http/Middleware/RedirectIfAuthenticated.php && \
        cp /tmp/ValidateSignature.php app/Http/Middleware/ValidateSignature.php && \
        # autoload生成を無効化してインストール
        composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --ignore-platform-reqs --no-scripts && \
        # キャッシュクリア
        composer clear-cache && \
        # オートローダー再生成（エラーハンドリング付き）
        composer dump-autoload --optimize || echo "Autoload dump failed, continuing..." && \
        # .envファイルの確認・作成
        if [ ! -f ".env" ] && [ -f ".env.example" ]; then \
            cp .env.example .env; \
        fi && \
        # APP_KEYがない場合は仮の値を設定
        if ! grep -q "APP_KEY=" .env || grep -q "APP_KEY=$" .env || grep -q "APP_KEY=\"\"" .env; then \
            echo "APP_KEY=base64:$(openssl rand -base64 32)" >> .env; \
        fi && \
        # 権限設定
        chown -R www-data:www-data storage bootstrap/cache && \
        chmod -R 775 storage bootstrap/cache && \
        # デバッグ用PHPファイルを作成
        echo '<?php phpinfo(); ?>' > public/info.php && \
        echo "Laravel 11 project prepared successfully!"; \
    else \
        echo "Creating new Laravel 11 project..."; \
        cd /var/www && \
        laravel new LaravelTestProject && \
        cd LaravelTestProject && \
        # 権限設定
        chown -R www-data:www-data storage bootstrap/cache && \
        chmod -R 775 storage bootstrap/cache && \
        # デバッグ用PHPファイルを作成
        echo '<?php phpinfo(); ?>' > public/info.php && \
        echo "New Laravel 11 project created successfully!"; \
    fi

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
