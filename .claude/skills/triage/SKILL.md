---
name: triage
description: "GitHub Issue・PRのトリアージ。番号を渡すと、要望の要約・実現難易度・既存機能との重複チェック・対応判断を調査してレポートする。Issue/PRの番号が出てきたとき、トリアージ、優先度判断、対応判断と言われたときに使用する。"
---

# Issue / PR トリアージ

GitHub Issue または PR の番号を受け取り、コードベースを調査して対応判断に必要な情報をレポートする。

## 使い方

```
/triage 42
/triage #8
```

## トリアージ手順

### Phase 1: 情報収集

#### 1-1. Issue/PR の取得

まずPRとして取得を試み、失敗したらIssueとして取得する。
（`gh issue view` はPR番号でも成功するため、PR判定を先に行う必要がある）

```bash
# PRとして取得（失敗時は終了コード非0）
if gh pr view <番号> --json number,title,body,labels,state,files,comments,author,reviews,createdAt 2>/dev/null; then
  echo "PR として取得成功"
else
  # Issueとして取得
  gh issue view <番号> --json number,title,body,labels,state,comments,author,createdAt
fi
```

#### 1-2. コメント・議論の確認

```bash
# Issueのコメント
gh issue view <番号> --json comments --jq '.comments[].body'

# PRのレビューコメント
gh pr view <番号> --json reviews --jq '.reviews[].body'
```

#### 1-3. 種別の判定

IssueテンプレートやラベルからIssueの種別を判定する:

| 種別 | 判定基準 |
|------|---------|
| Bug Report | `bug` ラベル、テンプレートのフィールド |
| Feature Request | `enhancement` ラベル、Proposal セクション |
| Dependabot | author が `dependabot[bot]` |
| 外部PR | authorがリポジトリオーナー以外 |

### Phase 2: コードベース調査

要望の内容に基づいて、関連するコードを調査する。
利用可能な場合はサブエージェントを活用して並列に調査を進めると効率的。

#### 調査観点

1. **関連コード**: 変更が必要になりそうなファイル・モジュール
2. **既存機能**: 要望を既に満たしている（または部分的に満たしている）機能がないか
3. **影響範囲**: 変更した場合に影響を受ける他の機能・モジュール

#### PRの場合の追加調査

```bash
# 変更ファイル一覧
gh pr view <番号> --json files --jq '.files[].path'

# diff の取得
gh pr diff <番号>
```

- 変更内容がプロジェクトの規約に沿っているか
- テストが追加されているか

### Phase 3: 難易度・工数の見積もり

調査結果をもとに、実装の難易度を判定する。

| 難易度 | 基準 | 工数目安 |
|--------|------|---------|
| **Low** | 単一ファイルの修正、UIの微調整、既存パターンの踏襲 | ~1時間 |
| **Medium** | 複数ファイルの変更、新しいWidgetの追加、既存機能の拡張 | 数時間 |
| **High** | 新機能のフルスタック実装、アーキテクチャへの影響 | 1日以上 |
| **Very High** | アーキテクチャ変更、外部依存の追加 | 数日以上 |

判定の根拠を具体的なファイルパスや変更箇所とともに示す。

### Phase 4: レポート出力

以下のフォーマットで会話内にレポートを出力する。

```markdown
## Triage Report: #<番号> <タイトル>

### 概要
[1-2文で要望の要約]

### 種別
[Bug / Feature / Dependabot / 外部PR]

### 既存機能チェック
- [既に実現済みの機能があれば記載]
- [部分的に実現されている場合はその旨と差分]
- [完全に新規の場合は「該当なし」]

### 実現難易度: [Low / Medium / High / Very High]

**根拠:**
- [変更が必要なファイル・モジュール]
- [影響範囲]

### 対応判断

| 観点 | 評価 |
|------|------|
| ユーザー価値 | [高/中/低] — [理由] |
| 実装コスト | [高/中/低] — [理由] |
| リスク | [高/中/低] — [理由] |
| 推奨 | [対応する / 保留 / 見送り] |

### 推奨アクション
- [具体的な次のステップ]
```

## 種別ごとの判断基準

### Bug Report
- 再現手順が明確か
- 影響範囲（全ユーザー vs 特定環境）
- ワークアラウンドの有無

### Feature Request
- プロジェクトの方向性と合致するか
- 実装コストに対するユーザー価値
- 代替手段（既存機能で賄えないか）

### Dependabot PR
- breaking changesの有無
- CHANGELOGの確認
- CI が通っているか

### 外部PR
- テストの追加
- プロジェクト規約への準拠

## コメント投稿時の注意

- `gh issue comment` / `gh pr comment` で複数段落の本文を投稿する場合は、**必ず一時ファイルを作って `--body-file` で渡す**
- 改行・バッククォート・引用記号が崩れやすいため、`--body` への直接埋め込みは避ける

例:

```bash
cat <<'EOF' >/tmp/comment.md
First paragraph.

- bullet 1
- bullet 2
EOF

gh issue comment <number> --body-file /tmp/comment.md
```
