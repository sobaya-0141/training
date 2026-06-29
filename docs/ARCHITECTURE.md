# アーキテクチャ

このプロジェクトは、単一 Flutter アプリのまま feature-first な構成で管理します。

```text
lib/
  main.dart
  src/
    app.dart
    features/
      calendar/
      counter/
      home/
      navigation/
      progress/
      timer/
      workout/
    theme/
    utils/
```

## 方針

- UI、状態、永続化は機能単位で近くに置く
- 複数機能で共有するものだけ `theme` や `utils` に置く
- アプリ全体の組み立ては `app.dart` に寄せる
- 永続化や外部依存は repository を介して扱う

## テンプレートとの差分

参照元テンプレートは中規模以上の開発を想定した Melos workspace と複数 package 構成です。このアプリでは現時点の規模に合わせ、過剰な package 分割はせず、CI、PR/Issue テンプレート、ドキュメント、テーマ責務の分離から取り込みます。
