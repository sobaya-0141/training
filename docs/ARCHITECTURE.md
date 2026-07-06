# アーキテクチャ

このプロジェクトは、単一 Flutter アプリのまま feature-first な構成で管理します。

```text
lib/
  main.dart
  src/
    app.dart
    service_locator.dart
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
- 依存関係の登録は `service_locator.dart`(get_it)に寄せ、`app.dart` は表示の組み立てに専念する
- get_it の参照は composition root(main / app / router の登録)に限定し、Widget へはコンストラクタで渡す
- 永続化や外部依存は repository を介して扱う

## テンプレートとの差分

参照元テンプレートは中規模以上の開発を想定した Melos workspace と複数 package 構成です。このアプリでは現時点の規模に合わせ、過剰な package 分割はせず、CI、PR/Issue テンプレート、ドキュメント、テーマ責務の分離から取り込みます。
