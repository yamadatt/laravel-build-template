#!/bin/bash

# PHP-FPMのソケットディレクトリを作成
mkdir -p /var/run/php

# Laravelプロジェクトが存在しない場合は作成
if [ ! -d "/var/www/LaravelTestProject" ]; then
    echo "Creating Laravel 11 project..."
    cd /var/www
    
    # Laravel installerを最新バージョンにアップデート
    echo "Updating Laravel installer..."
    composer global require "laravel/installer" --no-interaction
    
    # Laravel 11 プロジェクトを作成（明示的にバージョンを指定）
    echo "Creating Laravel 11 project with Composer..."
    composer create-project laravel/laravel LaravelTestProject "^11.0" --no-interaction --prefer-dist
    
    # Laravel 11 用の初期設定
    cd LaravelTestProject
    if [ -f "composer.json" ]; then
        echo "Configuring Laravel 11 project..."
        
        # Composer依存関係を最新に更新
        composer update --no-interaction
        
        # Pest テストフレームワークを追加（Laravel 11で推奨）
        composer require pestphp/pest --dev --no-interaction 2>/dev/null || true
        
        # .env ファイルがない場合は作成
        if [ ! -f ".env" ]; then
            cp .env.example .env
            php artisan key:generate --no-interaction
        fi
        
        echo "Laravel project version:"
        php artisan --version
    fi
    
    echo "Laravel 11 project created successfully!"
fi

# デバッグ用PHPファイルをコピー
if [ -f "/tmp/info.php" ] && [ -d "/var/www/LaravelTestProject/public" ]; then
    cp /tmp/info.php /var/www/LaravelTestProject/public/info.php
    echo "Debug PHP file copied successfully!"
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

# nginxのデフォルトサイトを無効化
rm -f /etc/nginx/sites-enabled/default

# 新しい設定を有効化
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# 元のコマンドを実行
exec "$@"
