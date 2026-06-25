---
name: sim-preview
description: iOSシミュレーターでFlutterアプリをビルド・起動して動作確認する。「シミュレーターで確認」「実装確認して」「UIを見せて」「シミュレーター起動」と言われたときに使用する。
---

# Simulator Preview

iOSシミュレーターでアプリを起動し、UIの動作を確認する。

## 手順

### 1. シミュレーター確認・起動

```bash
# 利用可能なiPhoneシミュレーターを確認
xcrun simctl list devices available | grep iPhone

# 起動済みシミュレーターを確認
xcrun simctl list devices booted
```

起動済みのシミュレーターがない場合:

```bash
# iPhone 16 Pro を起動（デバイス名は上記で確認した名前に合わせる）
xcrun simctl boot "iPhone 16 Pro"
```

### 2. アプリ起動

```bash
# デバッグモードで起動（hot reload が使える）
flutter run -d <シミュレーターのUDIDまたは "iPhone"でも可>
```

特定のシミュレーターを指定する場合:
```bash
flutter devices  # デバイスIDを確認
flutter run -d <device-id>
```

### 3. コード変更 → 確認ループ

アプリが起動中の状態でコードを変更した後:

- **Hot Reload**: `r` キーを押す（UIの微調整、state保持）
- **Hot Restart**: `R` キーを押す（state初期化、const変更に必要）

### 4. スクリーンショット撮影（任意）

```bash
xcrun simctl io booted screenshot /tmp/preview.png
open /tmp/preview.png
```

## Flutterデバイス一覧確認

```bash
flutter devices
```

## トラブルシュート

- **ビルドエラー**: `flutter clean && flutter pub get` してから再実行
- **シミュレーターが見つからない**: `xcrun simctl list devices available` で正確な名前を確認
- **起動が遅い**: 初回ビルドはXcodeのビルドが入るため数分かかる場合がある
- **ポート競合**: 別のFlutter実行が残っている場合は先に `q` で終了する
