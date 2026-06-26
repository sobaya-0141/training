# ブランチ運用

GitHub Flow を基本にします。

## 基本ルール

- `main` は常に動く状態を保つ
- 変更は `main` から短命ブランチを作成して行う
- 1 つの PR は 1 つの目的に絞る
- PR には関連 Issue を紐付ける
- マージ前に CI とローカル確認を通す

## ブランチ名

以下のような命名を推奨します。

```text
feat/<short-description>
fix/<short-description>
refactor/<short-description>
docs/<short-description>
ci/<short-description>
```

Codex が作業する場合は `codex/<short-description>` を使います。
