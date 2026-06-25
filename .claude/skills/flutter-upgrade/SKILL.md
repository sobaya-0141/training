---
name: flutter-upgrade
description: Flutter SDKバージョンアップグレード対応。新バージョンのリリースノート・Breaking Changes調査、コードベース影響分析、対応タスクリスト作成と実行。「Flutterアップグレード」「Flutter X.Y.Zがリリースされた」「Flutter最新化」「Flutter更新」と言われたとき、またはFlutterの新バージョンについて言及されたときに使用する。
---

# Flutter Upgrade

Flutter SDKの新バージョンへのアップグレードを体系的に進めるスキル。
リリースノート調査からコード修正・検証まで一貫して対応する。

## フェーズ1: 情報収集

### 1-1. リリースノート調査

WebSearch / WebFetch で以下を調査する:

- **Hotfix Issue**: `https://github.com/flutter/flutter/issues` で `[stable] [hotfix] Flutter Release Version X.Y.Z` を検索
- **Release Notes**: `https://docs.flutter.dev/release/release-notes/release-notes-X.Y.0`
- **Breaking Changes**: `https://docs.flutter.dev/release/breaking-changes`
- **Flutter blog**: `https://blog.flutter.dev` の What's new 記事
- **CHANGELOG**: `https://github.com/flutter/flutter/blob/master/CHANGELOG.md`

hotfix リリース (X.Y.1〜) の場合、メジャーリリース (X.Y.0) の Breaking Changes も含めて調査する。

### 1-2. 現在のプロジェクト状態を確認

```bash
# 現在のFlutterバージョン
flutter --version

# Dart SDK制約
grep -A1 'environment:' pubspec.yaml

# 現在の依存パッケージ
cat pubspec.yaml
```

## フェーズ2: プロジェクト影響分析

### 2-1. Breaking Changes のコードベースマッチング

リリースノートで見つかった Breaking Changes / 非推奨API それぞれについて、
`Grep` でコードベース内の使用箇所を検索する。

```
Grep pattern="<deprecated_api>" path="lib" glob="*.dart"
```

該当なし → 対応不要と明記。該当あり → ファイルと箇所数を記録。

### 2-2. パッケージ互換性

```bash
flutter pub outdated
```

非互換パッケージや更新可能なパッケージを確認する。
特に flutter_bloc、sqflite など主要パッケージのFlutter新バージョン対応状況を確認する。

### 2-3. Dart SDK 制約

- `pubspec.yaml` の `environment.sdk` が新バージョン同梱の Dart と互換か確認
- 非互換なら SDK 制約の更新も必要

## フェーズ3: 対応タスクリスト作成

調査結果を以下の形式でまとめる:

### テンプレート

```
## Flutter X.Y.Z アップグレード対応リスト

### 必須（アップグレードに必要）
1. Flutter SDK を X.Y.Z に更新 (`flutter upgrade` またはバージョン管理ツールで切り替え)
2. `flutter pub get`
3. `dart analyze` → `flutter test`
4. [Breaking Changes で必要な修正があればここに]

### 推奨（非推奨API解消）
- [非推奨APIの移行タスク]

### 確認（視覚的・動作確認）
- [テーマ色の変化、フォント描画の変化など]

### 棚卸し
- [更新可能なパッケージ]
```

影響がないものも「該当なし」と明記し、調査漏れがないことを示す。

## フェーズ4: 実行

ユーザーの確認を得てから実行に移る。

### 4-1. Flutter SDK 更新

```bash
# flutter upgrade で最新安定版に更新
flutter upgrade

# 特定バージョンに切り替える場合はプロジェクトのバージョン管理ツールに従う
# 例: fvm use X.Y.Z
```

### 4-2. ビルド・テスト

```bash
flutter pub get
dart analyze
flutter test
```

### 4-3. コード修正

Breaking Changes や非推奨API の修正を実施。

### 4-4. 検証

```bash
# 静的解析がクリーンであることを確認
dart analyze

# 全テストがパスすることを確認
flutter test

# iOSシミュレーターで動作確認（任意）
flutter run
```
