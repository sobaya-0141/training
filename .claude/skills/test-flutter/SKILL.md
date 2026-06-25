---
name: test-flutter
description: Flutter App のテスト実行・静的解析・フォーマット・テスト記述ガイド
disable-model-invocation: true
allowed-tools: Bash(flutter:*), Bash(dart:*), Read, Glob, Grep
---

# Flutter App テスト

## 実行手順

以下を順番に実行し、全てパスすることを確認する。

### 1. 静的解析

```bash
dart analyze
```

warning 以上は修正する。info レベルは必要に応じて対応。

### 2. フォーマット

```bash
dart format lib test
```

### 3. ユニットテスト

```bash
flutter test
```

特定ファイルのみ:
```bash
flutter test test/<filename>_test.dart
```

## テスト記述規約

### ファイル配置・命名

- テストファイルは `test/` に配置
- 命名: `<対象の概念>_test.dart`
  - ウィジェットテスト例: `timer_display_test.dart`
  - ロジックテスト例: `training_cubit_test.dart`

### import

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/...';
```

### テスト構造

```dart
void main() {
  group('対象クラスまたは機能', () {
    test('動作の説明', () {
      // ロジックテスト
      expect(actual, expected);
    });

    testWidgets('UI動作の説明', (tester) async {
      // ウィジェットテスト
      await tester.pumpWidget(MaterialApp(home: TargetWidget()));
      expect(find.text('expected'), findsOneWidget);
    });
  });
}
```

- `group` で対象機能ごとにグルーピング
- ロジックテストは `test()`、UI テストは `testWidgets()` を使い分ける
- `setUp()` でテスト前の共通初期化を行う

### テスト対象の方針

- **ウィジェットテスト**: 画面の表示・インタラクション検証
  - `pumpWidget` でウィジェット構築 → `find` で要素確認 → `tap`/`enterText` で操作
- **ロジックテスト**: Cubit・サービスの振る舞い検証
  - 純粋なDartクラスのメソッド呼び出しと結果確認

### Cubit テスト例

`test/timer_cubit_test.dart` のように `test()` + `expect()` でCubitの状態遷移を検証する。

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/timer/timer_cubit.dart';

void main() {
  group('TrainingTimerCubit', () {
    test('運動フェーズ中にskipすると休憩フェーズに進む', () {
      final cubit = TrainingTimerCubit(
        workSeconds: 20,
        restSeconds: 10,
        roundTitles: const ['種目1', '種目2'],
      );

      cubit.startOrPause(); // preparing
      cubit.skip();         // work
      cubit.skip();         // rest

      expect(cubit.state.phase, TimerPhase.rest);
      expect(cubit.state.remainingSeconds, 10);
      cubit.close();
    });
  });
}
```
