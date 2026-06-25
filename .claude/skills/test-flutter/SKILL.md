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
  - `bloc_test` パッケージが使える場合は `blocTest()` を活用

### Cubit テスト例

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/training/state/training_cubit.dart';

void main() {
  group('TrainingCubit', () {
    late TrainingCubit cubit;

    setUp(() {
      cubit = TrainingCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const TrainingState());
    });

    blocTest<TrainingCubit, TrainingState>(
      'emits updated state when startTraining is called',
      build: () => TrainingCubit(),
      act: (cubit) => cubit.startTraining(),
      expect: () => [
        isA<TrainingState>().having((s) => s.isRunning, 'isRunning', true),
      ],
    );
  });
}
```
