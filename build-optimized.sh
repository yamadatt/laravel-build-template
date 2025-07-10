#!/bin/bash

echo "🚀 Building optimized Docker image for Laravel 11..."

# 既存のイメージとコンテナを削除
echo "🗑️  Cleaning up existing containers and images..."
docker-compose down
docker rmi laravel9-build-template_web 2>/dev/null || true

# キャッシュなしでビルド
echo "🔨 Building with no cache..."
docker-compose build --no-cache --pull

# イメージサイズを表示
echo "📊 Image size information:"
docker images laravel9-build-template_web

# レイヤー情報を表示
echo ""
echo "📋 Image layers:"
docker history laravel9-build-template_web --human --format "table {{.CreatedBy}}\t{{.Size}}"

# 起動テスト
echo ""
echo "🔍 Testing container startup..."
docker-compose up -d

# 少し待ってからステータス確認
sleep 10

echo ""
echo "✅ Container status:"
docker-compose ps

echo ""
echo "🎉 Build completed! Access your Laravel 11 application at:"
echo "   Web: http://localhost:8080"
echo "   PHP Info: http://localhost:8080/info.php"
echo ""
echo "📈 Size optimization tips applied:"
echo "   - Alpine Linux base image (~5MB vs ~130MB)"
echo "   - Multi-stage build"
echo "   - Removed development dependencies"
echo "   - Optimized Composer autoloader"
echo "   - Cleaned up package caches"
echo "   - Removed static libraries"
