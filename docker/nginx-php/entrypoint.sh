#!/bin/bash

# PHP-FPMのソケットディレクトリを作成
mkdir -p /run/php

# Laravelプロジェクトが存在しない場合は作成
if [ ! -d "/var/www/LaravelTestProject" ]; then
    echo "Creating Laravel 11 project..."
    cd /var/www
    
    # Composerを使用してLaravel 11を直接作成（最適化版）
    echo "Creating Laravel 11 project with Composer..."
    composer create-project laravel/laravel LaravelTestProject "^11.0" --no-interaction --prefer-dist --no-dev --optimize-autoloader
    
    # Laravel 11 用の初期設定
    cd LaravelTestProject
    if [ -f "composer.json" ]; then
        echo "Configuring Laravel 11 project..."
        
        # .env ファイルがない場合は作成
        if [ ! -f ".env" ]; then
            cp .env.example .env
            php artisan key:generate --no-interaction
        fi
        
        # キャッシュクリア
        composer clear-cache
        
        echo "Laravel project version:"
        php artisan --version
    fi
    
    echo "Laravel 11 project created successfully!"
fi

# デバッグ用PHPファイルを作成
if [ -d "/var/www/LaravelTestProject/public" ]; then
    echo '<?php phpinfo(); ?>' > /var/www/LaravelTestProject/public/info.php
    echo "Debug PHP file created successfully!"
fi

# 権限設定
if [ -d "/var/www/LaravelTestProject" ]; then
    echo "Setting permissions..."
    chown -R www-data:www-data /var/www/LaravelTestProject/storage /var/www/LaravelTestProject/bootstrap/cache 2>/dev/null || true
    chmod -R 775 /var/www/LaravelTestProject/storage /var/www/LaravelTestProject/bootstrap/cache 2>/dev/null || true
    echo "Permissions set successfully!"
fi

# ログディレクトリを作成
mkdir -p /var/log/supervisor /var/log/php /var/log/nginx

# nginxの設定確認（Alpine用）
if [ -f "/etc/nginx/http.d/default.conf" ]; then
    echo "Nginx configuration found and ready!"
else
    echo "Warning: Nginx configuration not found"
fi

# 元のコマンドを実行
exec "$@"
