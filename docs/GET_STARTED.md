# 開発環境のセットアップ

このプロジェクトは単一 Flutter アプリとして管理します。`ymm-oss/flutter-mobile-project-template` の運用思想を参考にしつつ、現時点では Melos workspace へ移行しません。

## 必要なもの

- Flutter stable
- Dart SDK
- Xcode (iOS を確認する場合)
- Android Studio または Android SDK (Android を確認する場合)

## 初期セットアップ

```sh
flutter pub get
```

## アプリ起動

```sh
flutter run
```

## 品質チェック

PR 作成前にフォーマット、静的解析、テストをまとめて実行してください。

```sh
./scripts/check.sh
```
