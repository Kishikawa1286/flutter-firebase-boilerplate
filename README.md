# flutter-firebase-boilerplate

Flutter (主に Web) + Firebase のプロジェクトを容易に作成するためのボイラープレートです.

## 実行環境

このプロジェクトは基本的に [VSCode Devcontainer](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) または [GitHub Codespaces](https://marketplace.visualstudio.com/items?itemName=GitHub.codespaces) で実行することを想定しています.

基本的には Flutter Web + Firebase アプリのセットアップを容易に行うことを想定しています.

iOS, Android 開発を行う場合のみローカルでプロジェクトを開きます.

## 初期設定

### ログイン等

ログインなどの必要な初期設定はプロジェクトルートの `init.sh` を実行することでまとめて行うことができます.

```bash
bash init.sh
```

### `.firebaserc` の設定

通常通り `firebase/.firebaserc` を設定します.

例）

```json
{
  "projects": {
    "prod": "project-id",
    "dev": "develop-project-id"
  }
}
```

### Fluter 関連設定

`firebase/.firebaserc` の設定を参照し, [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) を使用します.

先に先述の作業を行ってください.

プロジェクトルートの `setup-flutter.sh` を実行することで Flutter の Firebase 関連をまとめて設定します.

- `dart_defines` の json ファイル自動生成
- `firebase_options.dart` 自動生成

```bash
bash setup-flutter.sh
```

## Flutter デバッグ実行

`flutter/` に移動して次のコマンドを実行することでもデバッグできます.

```bash
fvm flutter run -d web-server --dart-define-from-file=dart_defines/dev.json
```

## デプロイ

`flutter/` に移動して通常通りに Firebase CLI からデプロイします.

```bash
firebase deploy
```

predeploy スクリプトが実行され, `firebase ues` で設定しているプロジェクトを読み取って自動で Flutter Web のビルド設定が切り替わります.

## アプリ開発

`flutter/` 下に iOS や Android 用の設定ファイルを追加することで Web 以外の開発にも使えます.

`firebase_options.dart` の自動生成は Web, iOS, Android に対応しています.

ただし, Web 以外の開発はコンテナ内で行うことができません. 別途環境構築が必要です.
