#!/bin/bash

# PHP-FPMのソケットディレクトリを作成
mkdir -p /run/php

# Laravelプロジェクトが存在しない場合は作成（ECS対応で主に既存プロジェクトを使用）
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
else
    echo "Existing Laravel project found!"
    cd /var/www/LaravelTestProject
    
    # 既存プロジェクトの設定確認と必要な場合のみ更新
    if [ -f "composer.json" ]; then
        echo "Configuring existing Laravel project..."
        
        # .env ファイルがない場合は作成
        if [ ! -f ".env" ] && [ -f ".env.example" ]; then
            cp .env.example .env
        fi
        
        # APP_KEYがない場合は生成を試行
        if ! grep -q "APP_KEY=" .env || grep -q "APP_KEY=$" .env || grep -q "APP_KEY=\"\"" .env; then
            echo "Generating APP_KEY..."
            php artisan key:generate --no-interaction --force || echo "Key generation failed, continuing..."
        fi
        
        # Laravel バージョン確認
        echo "Laravel project version:"
        php artisan --version || echo "Laravel version check failed, continuing..."
        
        # キャッシュクリア（必要に応じて）
        php artisan config:clear 2>/dev/null || true
        php artisan route:clear 2>/dev/null || true
        php artisan view:clear 2>/dev/null || true
        
        echo "Existing Laravel project configured successfully!"
    fi
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
