#!/bin/bash

# 既存のLaravelプロジェクトを削除してLaravel 11を再作成するスクリプト

echo "Removing existing Laravel project..."
docker-compose down
docker-compose exec web rm -rf /var/www/LaravelTestProject 2>/dev/null || true

echo "Rebuilding container with Laravel 11..."
docker-compose build --no-cache

echo "Starting container and creating Laravel 11 project..."
docker-compose up -d

echo "Waiting for Laravel 11 project creation..."
sleep 30

echo "Checking Laravel version..."
docker-compose exec web php artisan --version

echo "Laravel 11 setup completed!"
echo "Access your application at: http://localhost:8080"
