# CI

このプロジェクトでは、PR ごとに以下のチェックを通すことを基準にします。

```sh
./scripts/check.sh
```

チェック内容は以下です。

- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`

## GitHub Actions へ移行する場合

GitHub Actions の workflow を追加するには、push に使用する GitHub token に `workflow` scope が必要です。権限がある環境では、以下のような workflow を `.github/workflows/check-pr.yaml` として追加します。

```yaml
name: check-pr

on:
  pull_request:
  push:
    branches:
      - main

concurrency:
  group: check-pr-${{ github.ref }}
  cancel-in-progress: true

jobs:
  flutter:
    runs-on: ubuntu-24.04
    timeout-minutes: 20

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Check format
        run: dart format --output=none --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test
```
