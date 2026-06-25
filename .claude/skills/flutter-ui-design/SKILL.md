---
name: flutter-ui-design
description: Flutter UI実装のアーキテクチャ規約・コンポーネント分割・状態管理ガイド（Bloc/Cubit版）
disable-model-invocation: true
allowed-tools: Bash(flutter:*), Bash(dart:*), Read, Write, Edit, Glob, Grep
---

# Flutter UI 実装規約

## アーキテクチャ概要

SSOT (Single Source of Truth) + UDF (Unidirectional Data Flow) に基づく設計。

### データフローパターン

- **Path A (Query)**: Cubit/Bloc → Widget (BlocBuilder/BlocListener)
  - サーバー状態、永続化データ、共有状態
  - BlocProvider を通じて単方向に流れる
- **Path B (Command)**: Widget → Cubit method → State emit
  - ユーザーアクション、API呼び出し
  - Cubit のメソッド経由で状態を変更
- **Path C (Local)**: StatefulWidget / useState
  - テキスト入力、スクロール位置、展開状態等の一時的UI状態

## Widget 分割ルール

### 禁止パターン

```dart
// NG: プライベートメソッドでのWidget分割
class MyScreen extends StatefulWidget {
  Widget _buildHeader() { ... }
  Widget _buildBody() { ... }
  Widget _buildFooter() { ... }
}
```

### 推奨パターン

```dart
// OK: 独立したWidgetクラスに分割
class MyScreenHeader extends StatelessWidget { ... }
class MyScreenBody extends StatelessWidget { ... }
class MyScreenFooter extends StatelessWidget { ... }
```

### 分割の判断基準

- 20行以上のbuildメソッド内ブロック → 独立Widgetに
- 独自のCubitを持つ → 独立Widget + BlocProvider
- BlocBuilder を含む → 独立Widget
- 表示のみ → StatelessWidget

## 状態管理

### Cubit パターン

```dart
class TrainingTimerCubit extends Cubit<TrainingTimerState> {
  TrainingTimerCubit({required this.workSeconds, ...})
      : super(TrainingTimerState(/* 初期値 */));

  void startOrPause() {
    // Command (Path B)
    emit(state.copyWith(phase: TimerPhase.preparing));
  }
}
```

### BlocListener の使い分け

- **BlocBuilder**: UIの再描画が必要な場合
- **BlocListener**: 副作用（ナビゲーション、SnackBar表示等）のみの場合
- **BlocConsumer**: 両方必要な場合

## ファイル構成

### feature-first 構造

```
lib/src/features/<feature>/
├── <feature>_screen.dart           # 画面Widget
├── <feature>_cubit.dart            # Cubit + State
└── widgets/
    ├── <component_a>.dart          # 独立Widget
    └── <component_b>.dart
```

実際の例（`lib/src/features/timer/`）:
```
lib/src/features/timer/
├── timer_screen.dart
├── timer_cubit.dart        # TrainingTimerCubit / TrainingTimerState
├── timer_cue_player.dart
└── (widgets/ は必要に応じて追加)
```

### 命名規約

| 種別 | 命名 | 例 |
|------|------|-----|
| 画面 | `*_screen.dart` | `training_screen.dart` |
| 状態 | `*_state.dart` | `training_state.dart` |
| Cubit | `*_cubit.dart` | `training_cubit.dart` |
| Widget | 機能を表す名前 | `timer_display.dart` |

## Flutter ベストプラクティス

### パフォーマンス

- **build()内で重い処理をしない**: ネットワーク呼び出し・複雑な計算はbuild()の外で行う
- **ListView.builder / SliverList**: 長いリストは必ずbuilder系コンストラクタで遅延生成する
- **constコンストラクタ**: Widget・build()内で可能な限り `const` を使いリビルドを削減する
- **Isolate**: JSON解析等の重い処理は `compute()` で別Isolateに逃がす

### Dartコーディング

- **Null Safety**: ! (bang operator) は値がnon-nullと保証できる場合のみ使用。安易に使わない
- **exhaustive switch**: switch文/式は網羅的に書く
- **パターンマッチング**: コードを簡潔にできる箇所ではパターンマッチングを活用する
- **アロー関数**: 1行で済む関数はアロー構文 (`=>`) を使う
- **関数の長さ**: 1関数20行未満を目指す。超える場合は分割を検討

### レイアウト

- **Expanded / Flexible**: 同一Row/Column内での混在禁止
- **Wrap**: Row/Columnで溢れる要素はWrapで折り返す
- **SingleChildScrollView**: 固定サイズでビューポートを超えるコンテンツに使用
- **FittedBox**: 子Widgetを親のサイズに合わせてスケーリング
- **LayoutBuilder**: レスポンシブレイアウトでの利用可能スペースに基づく分岐

### テーマ・スタイリング

- **ThemeExtension**: 標準ThemeDataに無いカスタムスタイルはThemeExtensionで定義する
- **ColorScheme.fromSeed()**: シードカラーからLight/Dark両テーマを生成
- **WidgetStateProperty**: ボタン等の状態別スタイルは `resolveWith` で定義

### アクセシビリティ

- **コントラスト比**: テキストは背景に対して4.5:1以上（大きいテキストは3:1以上）
- **Semantics**: スクリーンリーダー向けに `Semantics` Widgetで説明ラベルを付与
- **動的テキストスケーリング**: システムフォントサイズ変更時にUIが崩れないことを確認

## チェックリスト

実装完了時に確認:

- [ ] `_buildXxx()` メソッドが残っていないこと
- [ ] BlocBuilder/BlocListenerが適切に使い分けられていること
- [ ] `dart analyze` がクリーン
- [ ] `dart format` が適用済み
- [ ] 既存テストがパス (`flutter test`)
- [ ] build()内に重い処理（ネットワーク、複雑な計算）がないこと
- [ ] 可能な箇所でconstコンストラクタが使われていること
