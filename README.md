# Laravel 11 Docker Development Environment

Laravel 11 アプリケーション用のDocker開発環境テンプレートです。

## 概要

このプロジェクトは、Laravel 11 アプリケーションを Docker で簡単に開発できる環境を提供します。PHP 8.2、MySQL 5.7、Nginx を使用した完全な開発スタックが含まれています。

**特徴:**
- 🚀 nginx + PHP-FPM の統合コンテナ
- 📦 マルチステージビルドによる軽量イメージ（約300-400MB）
- 🔧 Laravel 9 → 11 への自動アップグレード機能
- 🐳 Docker Compose による簡単な環境構築
- ⚡ Laravel 11の新機能をサポート（Health Check、Pest testing framework等）
- 🎯 ECS対応（srcディレクトリをイメージに埋め込み）

## 技術スタック

- **PHP**: 8.2-FPM (Alpine Linux)
- **Laravel**: 11.x
- **MySQL**: 5.7.36
- **Nginx**: latest (Alpine Linux)
- **Docker**: Docker Compose with Multi-stage build

## ディレクトリ構成

```
.
├── docker/                          # Docker設定ファイル
│   ├── nginx-php/                   # 統合コンテナ設定
│   │   ├── Dockerfile               # マルチステージビルド設定
│   │   ├── nginx.conf               # Nginx設定
│   │   ├── supervisord.conf         # Supervisor設定
│   │   ├── entrypoint.sh            # 初期化スクリプト
│   │   ├── composer-laravel11.json  # Laravel 11用composer.json
│   │   └── bootstrap-app.php        # Laravel 11用bootstrap/app.php
│   └── php/
│       └── php.ini                  # PHP設定
├── src/                             # アプリケーションコード
│   └── LaravelTestProject/          # Laravelプロジェクト（Laravel 9→11自動アップグレード）
├── .dockerignore                    # Docker build除外設定
├── docker-compose.yml               # Docker Compose設定
└── README.md                        # このファイル
```

## アーキテクチャ

### 統合コンテナ設計
- **1つのコンテナ**: nginx と PHP-FPM を統合
- **Supervisor**: プロセス管理でnginxとPHP-FPMを同時実行
- **TCP通信**: PHP-FPMとnginx間の通信にTCP接続を使用
- **ECS対応**: srcディレクトリをイメージに埋め込み、外部ボリュームマウント不要

### マルチステージビルド
- **Build Stage**: 開発ツールとComposerを使用してビルド
- **Production Stage**: 本番環境用の軽量イメージを作成
- **サイズ最適化**: 不要なファイルを削除して約300-400MBに削減

## クイックスタート

### 1. 前提条件

- Docker がインストールされていること
- Docker Compose がインストールされていること

### 2. 環境構築

```bash
# リポジトリのクローン
git clone <repository-url>
cd laravel11-build-template

# Docker環境の起動（初回ビルド）
docker-compose up --build

# バックグラウンドで起動
docker-compose up -d --build
```

初回起動時は自動的にLaravelプロジェクトが作成されます。

**Laravel 9 → 11 自動アップグレード:**
既存のLaravel 9プロジェクトがsrcディレクトリにある場合、自動的にLaravel 11にアップグレードされます。

### 3. アクセス確認

- **Webアプリケーション**: http://localhost:8080
- **PHP情報**: http://localhost:8080/info.php （デバッグ用）
- **データベース**: localhost:3306

### 4. Laravel設定（オプション）

```bash
# 統合コンテナに接続
docker-compose exec web bash

# Laravelディレクトリに移動
cd LaravelTestProject

# 環境設定
cp .env.example .env
php artisan key:generate

# データベースマイグレーション
php artisan migrate
```

## サービス詳細

### Web (nginx + PHP-FPM)
- **ポート**: 8080
- **PHP バージョン**: 8.2
- **Document Root**: /var/www/LaravelTestProject/public
- **プロセス管理**: Supervisor
- **通信方式**: TCP (127.0.0.1:9000)

### MySQL Database
- **ポート**: 3306
- **データベース名**: mysql_test_db
- **ユーザー**: admin
- **パスワード**: secret
- **rootパスワード**: root

### Supervisor 設定
- **PHP-FPM**: 自動起動・自動再起動
- **Nginx**: 自動起動・自動再起動
- **ログ**: /var/log/php/, /var/log/nginx/

## 開発コマンド

### Artisan コマンド
```bash
docker-compose exec web php artisan <command>

# 例：
docker-compose exec web php artisan make:controller UserController
docker-compose exec web php artisan migrate
docker-compose exec web php artisan tinker

# Laravel 11 新機能
docker-compose exec web php artisan about
docker-compose exec web php artisan health:check
docker-compose exec web php artisan reverb:start
```

### Composer コマンド
```bash
docker-compose exec web composer <command>

# 例：
docker-compose exec web composer install
docker-compose exec web composer require package-name
```

## Laravel 9 → 11 アップグレード詳細

### 自動アップグレード処理
Dockerビルド時に以下の処理を自動実行：

1. **依存関係の更新**
   - Laravel 9のcomposer.jsonを11用に置換
   - vendor/composer.lockを削除
   - 新しい依存関係のインストール

2. **アプリケーション構造の更新**
   - Laravel 11用のbootstrap/app.phpを配置
   - 新しいアプリケーションブートストラップ構造に対応

3. **設定ファイルの調整**
   - .envファイルの確認・作成
   - APP_KEYの自動生成
   - 権限設定の調整

### 手動アップグレード（必要に応じて）
```bash
# コンテナ内で実行
docker-compose exec web bash

cd /var/www/LaravelTestProject

# 設定ファイルの更新
php artisan config:cache --env=production
php artisan route:cache
php artisan view:cache

# データベースマイグレーション
php artisan migrate --force
```

### テスト実行
```bash
# PHPUnit (従来)
docker-compose exec web php artisan test
docker-compose exec web vendor/bin/phpunit

# Pest (Laravel 11 推奨)
docker-compose exec web vendor/bin/pest
```

### プロセス管理
```bash
# Supervisorの状態確認
docker-compose exec web supervisorctl status

# プロセスの再起動
docker-compose exec web supervisorctl restart nginx
docker-compose exec web supervisorctl restart php-fpm
```

## Laravel 11 新機能

### Health Check
```bash
# ヘルスチェック実行
docker-compose exec web php artisan health:check

# カスタムヘルスチェック作成
docker-compose exec web php artisan make:health-check DatabaseHealthCheck
```

### Reverb (WebSocket サーバー)
```bash
# Reverb サーバー起動
docker-compose exec web php artisan reverb:start

# Reverb 設定
docker-compose exec web php artisan reverb:install
```

### Pest Testing Framework
```bash
# Pest のインストール
docker-compose exec web composer require pestphp/pest --dev

# Pest の初期化
docker-compose exec web vendor/bin/pest --init

# テスト実行
docker-compose exec web vendor/bin/pest
```

## ECS (Amazon Elastic Container Service) 対応

このプロジェクトはECSでの本番運用に最適化されています。

### ECS対応の特徴

#### 1. コンテナ化されたソースコード
- **埋め込み式**: ソースコードはDockerイメージに埋め込まれており、外部Volumeに依存しません
- **Laravel 9 → 11 自動アップグレード**: 既存のLaravel 9プロジェクトを自動的に11にアップグレード
- **不変性**: イメージのバージョン管理により、どの環境でも同じコードが実行されます
- **高速起動**: Volumeマウントが不要なため、コンテナの起動が高速です

#### 2. 本番環境用設定
- **Alpine Linux**: 軽量なベースイメージで高速デプロイ
- **マルチステージビルド**: 本番環境では不要なツールを除外
- **セキュリティ**: 最小限の依存関係とシステムパッケージ
- **最適化されたComposer**: 本番環境用の依存関係のみインストール

#### 3. Laravel 11 自動アップグレード機能
- **ビルド時アップグレード**: Laravel 9プロジェクトを11に自動変換
- **依存関係の更新**: composer.jsonを11用に自動置換
- **設定ファイルの生成**: bootstrap/app.phpなどの必要ファイルを自動配置
- **互換性の確保**: 既存のコードベースを保持しながらフレームワークを更新

#### 4. 環境変数対応
```bash
# ECS用の環境変数設定例
APP_ENV=production
APP_DEBUG=false
DB_HOST=your-rds-endpoint.amazonaws.com
DB_DATABASE=your_production_db
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### ECS デプロイ手順

#### 1. ECR（Amazon Elastic Container Registry）への登録

```bash
# ECRリポジトリの作成
aws ecr create-repository --repository-name laravel11-app --region ap-northeast-1

# Docker認証
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com

# イメージのビルド
docker build -t laravel11-app .

# タグ付け
docker tag laravel11-app:latest <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/laravel11-app:latest

# プッシュ
docker push <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/laravel11-app:latest
```

#### 2. ECS タスク定義例

```json
{
  "family": "laravel11-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::account-id:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "laravel11-app",
      "image": "<account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/laravel11-app:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "APP_ENV",
          "value": "production"
        },
        {
          "name": "APP_DEBUG",
          "value": "false"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/laravel11-app",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

#### 3. 本番環境の注意点

- **RDS使用**: MySQLは別途RDSを使用
- **セッション管理**: Redis等を使用（デフォルトのファイル保存は不適切）
- **ログ管理**: CloudWatch Logsを使用
- **環境変数**: AWS Systems Manager Parameter Storeまたは Secrets Manager を使用

### ローカル環境での ECS 相当テスト

```bash
# 本番環境相当での動作確認
docker build -t laravel11-app-production .
docker run -d -p 8080:80 \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  --name laravel11-production \
  laravel11-app-production

# 動作確認
curl http://localhost:8080

# コンテナの削除
docker stop laravel11-production
docker rm laravel11-production
```

## ログとデバッグ

### ログの確認
```bash
# 全サービスのログ
docker-compose logs

# 特定のサービス
docker-compose logs web
docker-compose logs db

# リアルタイムログ
docker-compose logs -f web
```

### コンテナ内のログ確認
```bash
# Nginx ログ
docker-compose exec web tail -f /var/log/nginx/error.log
docker-compose exec web tail -f /var/log/nginx/access.log

# PHP-FPM ログ
docker-compose exec web tail -f /var/log/php/php-fpm.log

# Supervisor ログ
docker-compose exec web tail -f /var/log/supervisor/supervisord.log
```

### デバッグ情報
```bash
# コンテナの状態確認
docker-compose ps

# イメージサイズ確認
docker images laravel11-build-template_web

# nginx設定テスト
docker-compose exec web nginx -t

# PHP情報確認
curl http://localhost:8080/info.php
```

## トラブルシューティング

### 502 Bad Gateway エラー
```bash
# プロセスの状態確認
docker-compose exec web supervisorctl status

# PHP-FPM が起動していない場合
docker-compose exec web supervisorctl start php-fpm

# nginx の設定確認
docker-compose exec web nginx -t
```

### 権限エラー
```bash
# Laravel ストレージディレクトリの権限修正
docker-compose exec web chown -R www-data:www-data /var/www/LaravelTestProject/storage
docker-compose exec web chown -R www-data:www-data /var/www/LaravelTestProject/bootstrap/cache
docker-compose exec web chmod -R 775 /var/www/LaravelTestProject/storage
docker-compose exec web chmod -R 775 /var/www/LaravelTestProject/bootstrap/cache
```

### コンテナの再構築
```bash
# 通常の再構築
docker-compose down
docker-compose up --build

# 完全な再構築（キャッシュなし）
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### イメージサイズの確認
```bash
# ビルド前後のサイズ比較
docker images | grep laravel11-build-template

# レイヤー分析
docker history laravel11-build-template_web
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
`docker/nginx-php/nginx.conf` を編集してコンテナを再構築

### Supervisor設定の変更
`docker/nginx-php/supervisord.conf` を編集してコンテナを再構築

### MySQL設定の変更
`docker-compose.yml` の環境変数を編集

### ポート番号の変更
`docker-compose.yml` の ports 設定を変更
```yaml
ports:
  - "8080:80"  # ホスト:コンテナ
```

## パフォーマンス最適化

### Docker イメージサイズ
- **マルチステージビルド**: 開発ツールを本番イメージから除外
- **不要ファイル削除**: マニュアル、キャッシュ、一時ファイルを削除
- **レイヤー最適化**: RUNコマンドを統合してレイヤー数を削減

### 実行時最適化
- **TCP通信**: PHP-FPMとnginx間の安定した通信
- **Supervisor**: プロセス管理による堅牢な運用
- **ログ管理**: 適切なログレベルとローテーション

## 本番環境への展開

このテンプレートは開発環境用です。本番環境では以下を検討してください：

### セキュリティ
- 環境変数の適切な管理
- データベースの認証情報の強化
- 不要なデバッグファイルの削除
- SSL/TLS証明書の設定

### パフォーマンス
- PHP-FPMのワーカー数調整
- OPcacheの有効化
- nginxの圧縮設定
- データベースの最適化

### 運用
- ログ管理の改善
- ヘルスチェックの実装
- 監視システムの導入
- バックアップ戦略の策定

### 推奨構成
```yaml
# 本番環境用のdocker-compose.prod.yml例
version: '3.8'
services:
  web:
    build:
      context: .
      dockerfile: ./docker/nginx-php/Dockerfile
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
    # デバッグ用ポートやファイルを削除
```

## 技術的な詳細

### マルチステージビルドの仕組み
1. **Build Stage**: 開発ツール（Composer、Laravel installer）をインストール
2. **Production Stage**: 本番環境用の軽量イメージを作成
3. **最適化**: 必要なファイルのみをコピーし、不要なファイルを削除

### Supervisor設定
```ini
[program:php-fpm]
command=php-fpm -F
priority=10

[program:nginx]
command=nginx -g "daemon off;"
priority=20
```

### 統合コンテナの利点
- **デプロイ簡素化**: 1つのコンテナで完結
- **リソース効率**: メモリ使用量の削減
- **設定管理**: 一元的な設定管理

## よくある質問 (FAQ)

### Q: イメージサイズが大きいのはなぜですか？
A: マルチステージビルドにより約300-400MBに最適化されています。従来の単一ステージビルドと比較して大幅にサイズを削減しています。

### Q: 502 Bad Gateway エラーが発生します
A: PHP-FPMとnginxの通信に問題がある可能性があります。`docker-compose exec web supervisorctl status`でプロセスの状態を確認してください。

### Q: Laravel プロジェクトが自動作成されません
A: 初回起動時に時間がかかる場合があります。`docker-compose logs web`でログを確認してください。

### Q: ポート8080が使用できません
A: `docker-compose.yml`の ports 設定を変更してください：
```yaml
ports:
  - "8081:80"  # 8081など他のポートに変更
```

### Q: 開発用のパッケージを追加したい
A: `docker/nginx-php/Dockerfile`のBuild Stageに追加してください。

### Q: Laravel 11 の新機能を使用するには？
A: 以下のコマンドで新機能を利用できます：
- Health Check: `php artisan health:check`
- Reverb: `php artisan reverb:start`
- Pest: `vendor/bin/pest`

### Q: Laravel 9 から Laravel 11 への移行は？
A: 主な変更点：
- 最小 PHP バージョンが 8.2 になりました
- 新しい健全性チェック機能
- WebSocket サポート（Reverb）
- Pest テストフレームワーク推奨

### Q: 既存のLaravel 9プロジェクトはどうなりますか？
A: 自動的にLaravel 11にアップグレードされます：
- composer.jsonが11用に置換されます
- 必要なファイル（bootstrap/app.php等）が自動配置されます
- 既存のコードベースは保持されます

### Q: ECSでの本番運用で注意すべき点は？
A: 以下の点を確認してください：
- 環境変数の設定（APP_ENV=production等）
- RDSなどの外部データベースとの接続
- ロードバランサーの設定
- ログの適切な管理

## 更新履歴

### v3.0.0
- Laravel 11 対応
- Laravel 9 → 11 自動アップグレード機能
- ECS本番運用対応（srcディレクトリ埋め込み）
- Health Check 機能の追加
- Reverb (WebSocket) サーバー対応
- Pest Testing Framework サポート
- 新しい Artisan コマンドの対応

### v2.0.0
- nginx + PHP-FPM 統合コンテナ化
- マルチステージビルド導入
- イメージサイズ最適化（約300-400MB）
- Supervisor によるプロセス管理
- デバッグ機能の追加

### v1.0.0
- 初期リリース
- 分離コンテナ構成（nginx、PHP-FPM、MySQL）

## ライセンス

MIT License

## 貢献

プルリクエストやイシューの報告を歓迎します。

## サポート

問題が発生した場合は、以下を確認してください：

1. Docker と Docker Compose が正しくインストールされているか
2. ポート 8080, 3306 が他のサービスで使用されていないか
3. 十分なディスク容量があるか
4. `docker-compose logs web`で詳細なエラーログを確認

### 関連リンク
- [Docker 公式ドキュメント](https://docs.docker.com/)
- [Laravel 公式ドキュメント](https://laravel.com/docs)
- [PHP-FPM 設定ガイド](https://www.php.net/manual/ja/install.fpm.php)
- [Nginx 設定ガイド](https://nginx.org/en/docs/)