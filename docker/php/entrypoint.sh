#!/bin/bash

# Laravelプロジェクトが存在しない場合は作成
if [ ! -d "/var/www/LaravelTestProject" ]; then
    echo "Creating Laravel project..."
    cd /var/www
    laravel new LaravelTestProject
    echo "Laravel project created successfully!"
fi

# 権限設定
if [ -d "/var/www/LaravelTestProject" ]; then
    echo "Setting permissions..."
    chown -R www-data:www-data /var/www/LaravelTestProject/storage /var/www/LaravelTestProject/bootstrap/cache 2>/dev/null || true
    chmod -R 775 /var/www/LaravelTestProject/storage /var/www/LaravelTestProject/bootstrap/cache 2>/dev/null || true
    echo "Permissions set successfully!"
fi

# 元のコマンドを実行
exec "$@"