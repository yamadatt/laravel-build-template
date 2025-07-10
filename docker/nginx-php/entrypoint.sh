#!/bin/bash

# PHP-FPMのソケットディレクトリを作成
mkdir -p /var/run/php

# Laravelプロジェクトが存在しない場合は作成
if [ ! -d "/var/www/LaravelTestProject" ]; then
    echo "Creating Laravel project..."
    cd /var/www
    laravel new LaravelTestProject
    echo "Laravel project created successfully!"
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
