# Laravel 9 Docker Development Environment

Laravel 9 アプリケーション用のDocker開発環境テンプレートです。

## 概要

このプロジェクトは、Laravel 9 アプリケーションを Docker で簡単に開発できる環境を提供します。PHP 8.2、MySQL 5.7、Nginx を使用した完全な開発スタックが含まれています。

**特徴:**
- 🚀 nginx + PHP-FPM の統合コンテナ
- 📦 マルチステージビルドによる軽量イメージ（約300-400MB）
- 🔧 開発用の自動Laravel プロジェクト作成
- 🐳 Docker Compose による簡単な環境構築

## 技術スタック

- **PHP**: 8.2-FPM
- **Laravel**: 9.x
- **MySQL**: 5.7.36
- **Nginx**: latest
- **Docker**: Docker Compose with Multi-stage build

## ディレクトリ構成

```
.
├── docker/                          # Docker設定ファイル
│   ├── nginx-php/                   # 統合コンテナ設定
│   │   ├── Dockerfile               # マルチステージビルド設定
│   │   ├── nginx.conf               # Nginx設定
│   │   ├── supervisord.conf         # Supervisor設定
│   │   └── entrypoint.sh            # 初期化スクリプト
│   └── php/
│       └── php.ini                  # PHP設定
├── src/                             # アプリケーションコード
│   └── LaravelTestProject/          # Laravelプロジェクト（自動作成）
├── .dockerignore                    # Docker build除外設定
├── docker-compose.yml               # Docker Compose設定
└── README.md                        # このファイル
```

## アーキテクチャ

### 統合コンテナ設計
- **1つのコンテナ**: nginx と PHP-FPM を統合
- **Supervisor**: プロセス管理でnginxとPHP-FPMを同時実行
- **TCP通信**: PHP-FPMとnginx間の通信にTCP接続を使用

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
cd laravel9-build-template

# Docker環境の起動（初回ビルド）
docker-compose up --build

# バックグラウンドで起動
docker-compose up -d --build
```

初回起動時は自動的にLaravelプロジェクトが作成されます。

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
```

### Composer コマンド
```bash
docker-compose exec web composer <command>

# 例：
docker-compose exec web composer install
docker-compose exec web composer require package-name
```

### テスト実行
```bash
docker-compose exec web php artisan test
# または
docker-compose exec web vendor/bin/phpunit
```

### プロセス管理
```bash
# Supervisorの状態確認
docker-compose exec web supervisorctl status

# プロセスの再起動
docker-compose exec web supervisorctl restart nginx
docker-compose exec web supervisorctl restart php-fpm
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
docker images laravel9-build-template_web

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
docker images | grep laravel9-build-template

# レイヤー分析
docker history laravel9-build-template_web
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

## 更新履歴

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