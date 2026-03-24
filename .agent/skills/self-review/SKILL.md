---
name: self-review
description: 特性の異なる3つのレビュアーエージェントを並列実行し、全レビュー完了後に批判的精査→自動修正まで一貫して行うスキル。reviewer（多角的品質）・codex-reviewer（別モデル視点）・simplify-reviewer（可読性・過剰設計検出）を並列起動する。
---

# Self-Review スキル

## 概要

3つの特性の異なるレビュアーエージェントを**並列**で起動し、全レビュー結果を統合した後、
`fix-review-comments` スキルで批判的精査・自動修正まで一気通貫で実行するスキルです。

## 実行フロー

```
/self-review 実行
    ↓
Phase 1: 差分取得
  git diff を実行してレビュー対象テキストを取得する
    ↓
Phase 2: 並列レビュー（3エージェント同時実行）
  ├─ reviewer          → 品質・セキュリティ・パフォーマンス・バグ
  ├─ codex-reviewer    → 別モデル視点での客観的レビュー
  └─ simplify-reviewer → 可読性・一貫性・過剰設計の検出
    ↓（全エージェント完了を待機）
Phase 3: 批判的精査・自動修正
  fix-review-comments スキルを実行
  妥当な指摘のみ修正 + 却下理由を付記
    ↓
レビューレポート + 修正結果を出力
```

---

## 実行手順

### Step 1: 差分テキストの取得

まず `git diff` を実行し、差分テキストを取得する。
**この差分テキストを以降のステップで各エージェントに渡す。**

```bash
# ローカルの未コミット変更をレビューする場合
git diff HEAD

# 特定ブランチとの差分をレビューする場合
git fetch origin
git diff origin/main...HEAD
```

差分テキストが空の場合はコミット済みの変更を確認する：

```bash
# 直近のコミットをレビューする場合
git diff HEAD~1 HEAD
```

### Step 2: 3エージェントを並列起動

**必ず1つのメッセージで3つの Agent ツール呼び出しを同時に行う。逐次実行しない。**

以下の3つを同時に呼び出す。各エージェントの prompt には Step 1 で取得した差分テキストを
そのまま埋め込む（プレースホルダーではなく実際のテキスト）。

**エージェント名**: `reviewer`
**prompt**:
```
以下のコード差分を、品質・セキュリティ・パフォーマンス・バグの観点で多角的にレビューしてください。

## レビュー対象の差分
{Step 1 で取得した git diff の全テキスト}

## 出力形式
以下の形式で返してください。指摘が0件の場合も明示してください。

## reviewer レビュー結果
### [HIGH/MEDIUM/LOW] 指摘タイトル
- **ファイル**: パス#L行番号
- **内容**: 問題の説明と影響・リスク
- **修正提案**: 具体的な修正方法
```

**エージェント名**: `codex-reviewer`
**prompt**:
```
以下のコード差分を、codex review コマンドを使うか、別モデルの視点で客観的にレビューしてください。

## レビュー対象の差分
{Step 1 で取得した git diff の全テキスト}

## 出力形式
以下の形式で返してください。

## codex-reviewer レビュー結果
### [HIGH/MEDIUM/LOW] 指摘タイトル
- **ファイル**: パス#L行番号
- **内容**: 問題の説明と影響
- **修正提案**: 具体的な修正方法
```

**エージェント名**: `simplify-reviewer`
**prompt**:
```
以下のコード差分を、可読性・一貫性・保守性・過剰設計の観点でレビューしてください。
AI生成コード特有の「やりすぎ」（過剰な抽象化、不要な複雑さ、一度しか使わないヘルパー等）を特に検出してください。

## レビュー対象の差分
{Step 1 で取得した git diff の全テキスト}

## 出力形式
以下の形式で返してください。

## simplify-reviewer レビュー結果
### [HIGH/MEDIUM/LOW] 指摘タイトル
- **ファイル**: パス#L行番号
- **内容**: 何が複雑すぎるか・なぜ簡略化すべきか
- **修正提案**: 削除・簡略化の具体的な方法
```

### Step 3: 全エージェント完了を確認

3つのエージェントが全て完了したことを確認し、結果を集約する。
複数のエージェントが同じ箇所を指摘している場合は、優先度が高い指摘として扱う。

```
⏺ 3 agents finished
   ├─ reviewer: X件
   ├─ codex-reviewer: Y件
   └─ simplify-reviewer: Z件

合計: N件の指摘
```

### Step 4: fix-review-comments スキルの実行

以下の順で `fix-review-comments` のスキルファイルを探し、最初に見つかったものを読み込む：

1. `.claude/skills/fix-review-comments/SKILL.md`
2. `skills/fix-review-comments/SKILL.md`
3. `.agent/skills/fix-review-comments/SKILL.md`

読み込んだスキルの手順に従い、3エージェントの全レビュー結果テキストを渡して批判的精査・修正を実行する。

---

## 前提条件（各プロジェクトで必要な設定）

以下の3つのエージェント定義が `.claude/agents/` に存在すること：

```
.claude/agents/
├── reviewer.md
├── codex-reviewer.md
└── simplify-reviewer.md
```

セットアップ方法はリポジトリの README を参照。

---

## 出力形式

```markdown
## Self-Review 完了レポート

### Phase 1 (並列レビュー) 結果
| エージェント | 指摘件数 |
| --- | --- |
| reviewer | X件 |
| codex-reviewer | Y件 |
| simplify-reviewer | Z件 |
| 合計 | N件 |

### Phase 2 (批判的精査・修正) 結果
対応: M件 / 却下: K件

（fix-review-comments の詳細出力が続く）
```
