# Laravel 11 Docker Development Environment

Laravel 11 アプリケーション用のDocker開発環境テンプレートです。

## 概要

このプロジェクトは、Laravel 11 アプリケーションを Docker で簡単に開発できる環境を提供します。PHP 8.2、MySQL 5.7、Nginx を使用した完全な開発スタックが含まれています。

## 技術スタック

- **PHP**: 8.2-FPM
- **Laravel**: 11.x
- **MySQL**: 5.7.36
- **Nginx**: latest
- **Docker**: Docker Compose

## ディレクトリ構成

```
.
├── docker/                    # Docker設定ファイル
│   ├── nginx/
│   │   └── default.conf      # Nginx設定
│   └── php/
│       ├── Dockerfile        # PHP-FPMコンテナ設定
│       ├── entrypoint.sh     # 初期化スクリプト
│       └── php.ini          # PHP設定
├── src/                      # アプリケーションコード
│   └── LaravelTestProject/   # Laravelプロジェクト
├── docker-compose.yml        # Docker Compose設定
└── README.md                # このファイル
```

## クイックスタート

### 1. 前提条件

- Docker がインストールされていること
- Docker Compose がインストールされていること

### 2. 環境構築

```bash
# リポジトリのクローン
git clone <repository-url>
cd <project-directory>

# Docker環境の起動
docker-compose up -d
```

初回起動時は自動的にLaravelプロジェクトが作成されます。

### 3. Laravel設定

```bash
# PHPコンテナに接続
docker-compose exec php bash

# Laravelディレクトリに移動
cd LaravelTestProject

# 依存関係のインストール
composer install

# 環境設定
cp .env.example .env
php artisan key:generate

# データベースマイグレーション
php artisan migrate
```

### 4. アクセス確認

- **Webアプリケーション**: http://localhost
- **データベース**: localhost:3306

## サービス詳細

### MySQL Database
- **ポート**: 3306
- **データベース名**: mysql_test_db
- **ユーザー**: admin
- **パスワード**: secret
- **rootパスワード**: root

### PHP-FPM
- **バージョン**: PHP 8.2
- **タイムゾーン**: Asia/Tokyo
- **文字エンコーディング**: UTF-8
- **拡張機能**: zip, pdo_mysql

### Nginx
- **ポート**: 80
- **ドキュメントルート**: /var/www/LaravelTestProject/public

## 開発コマンド

### Artisan コマンド
```bash
docker-compose exec php php artisan <command>

# 例：
docker-compose exec php php artisan make:controller UserController
docker-compose exec php php artisan migrate
docker-compose exec php php artisan tinker
```

### Composer コマンド
```bash
docker-compose exec php composer <command>

# 例：
docker-compose exec php composer install
docker-compose exec php composer require package-name
```

### テスト実行
```bash
docker-compose exec php php artisan test
# または
docker-compose exec php vendor/bin/phpunit
```

## ログとデバッグ

### ログの確認
```bash
# 全サービスのログ
docker-compose logs

# 特定のサービス
docker-compose logs php
docker-compose logs nginx
docker-compose logs db

# リアルタイムログ
docker-compose logs -f
```

### コンテナの状態確認
```bash
docker-compose ps
```

## トラブルシューティング

### 権限エラー
```bash
# Laravel ストレージディレクトリの権限修正
docker-compose exec php chown -R www-data:www-data /var/www/LaravelTestProject/storage
docker-compose exec php chown -R www-data:www-data /var/www/LaravelTestProject/bootstrap/cache
docker-compose exec php chmod -R 775 /var/www/LaravelTestProject/storage
docker-compose exec php chmod -R 775 /var/www/LaravelTestProject/bootstrap/cache
```

### コンテナの再構築
```bash
# 完全な再構築
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### データベースのリセット
```bash
# ボリュームも含めて削除
docker-compose down -v
docker-compose up -d
```

## カスタマイズ

### PHP設定の変更
`docker/php/php.ini` を編集してコンテナを再構築

### Nginx設定の変更
`docker/nginx/default.conf` を編集してコンテナを再起動

### MySQL設定の変更
`docker-compose.yml` の環境変数を編集

## 本番環境への展開

このテンプレートは開発環境用です。本番環境では以下を検討してください：

- セキュリティ設定の強化
- 環境変数の適切な管理
- SSL/TLS証明書の設定
- パフォーマンス最適化
- ログ管理の改善

## ライセンス

MIT License

## 貢献

プルリクエストやイシューの報告を歓迎します。

## サポート

問題が発生した場合は、以下を確認してください：

1. Docker と Docker Compose が正しくインストールされているか
2. ポート 80, 3306 が他のサービスで使用されていないか
3. 十分なディスク容量があるか

詳細なログを確認して問題を特定してください。