# ai-coding-config

Claude Code をはじめとするAIコーディングツール向けの共通ルール・スキル管理リポジトリ。

## 構成

| ディレクトリ | 内容 |
| --- | --- |
| `rules/core/` | 言語設定・Git規約・セッション基本動作 |
| `rules/quality/` | コードレビュー・テスト・セキュリティ |
| `rules/workflow/` | タスク管理・Issue・リリース |
| `skills/` | 再利用可能なスキル定義（Claude Code 用） |
| `skills/code-review/` | コードレビュースキル（SKILL.md + 指摘品質例） |
| `skills/self-review/` | 3エージェント並列レビュー→批判的精査→自動修正 |
| `skills/fix-review-comments/` | レビュー指摘の批判的評価・妥当なものだけ修正 |
| `skills/security-review/` | PR差分のセキュリティレビュー（OWASP Top 10・信頼度0.8+のみ報告） |
| `.agent/skills/` | エージェント用スキル定義（上記と同内容） |
| `hooks/` | SessionStart等のHookスクリプト |
| `templates/` | 各リポジトリ用のひな形 |
| `templates/agents/` | カスタムエージェント定義テンプレート（reviewer・codex-reviewer・simplify-reviewer） |

## 対応ツール

- Claude Code（主）
- Cursor（`.cursor/rules/` 対応予定）

## セットアップ

### 1. このリポジトリを clone する

各プロジェクトの **親ディレクトリ** に clone する。

```bash
cd ~/Project   # 例: ~/Project/my-app と同じ階層
git clone https://github.com/esxross/ai-coding-config.git
```

### 2. 新しいプロジェクトに導入する

```bash
cd ~/Project/my-app   # 対象プロジェクトへ移動

# .claude ディレクトリを作成
mkdir -p .claude/rules/core .claude/hooks

# 共通ルールをシンボリックリンクで参照
ln -s ../../ai-coding-config/rules/core/communication.md .claude/rules/core/communication.md
ln -s ../../ai-coding-config/rules/core/git-workflow.md  .claude/rules/core/git-workflow.md
ln -s ../../ai-coding-config/rules/core/session-start.md .claude/rules/core/session-start.md
ln -s ../../ai-coding-config/hooks/session-start.sh      .claude/hooks/session-start.sh

# テンプレートから CLAUDE.md と settings.json をコピー
cp ../ai-coding-config/templates/CLAUDE.md.template    CLAUDE.md
cp ../ai-coding-config/templates/settings.json.template .claude/settings.json
```

### 3. CLAUDE.md をプロジェクト用にカスタマイズする

`CLAUDE.md` の `[リポジトリ名]` 以下を埋める。

```markdown
# my-app CLAUDE.md

## 共通ルール
@.claude/rules/core/communication.md
@.claude/rules/core/git-workflow.md
@.claude/rules/core/session-start.md

---

## このリポジトリ固有の情報

### 技術スタック
- Next.js 14 / TypeScript / Tailwind CSS

### よく使うコマンド
- 開発サーバー起動: npm run dev
- テスト実行:       npm test
- ビルド:           npm run build
```

### 4. コードレビュースキルの導入（任意）

`/self-review`・`/fix-review-comments`・`/code-review`・`/security-review` を使う場合は追加で設定する。

```bash
cd ~/Project/my-app

# エージェント定義を .claude/agents/ にコピー
mkdir -p .claude/agents
cp ../ai-coding-config/templates/agents/reviewer.agent.md        .claude/agents/reviewer.md
cp ../ai-coding-config/templates/agents/codex-reviewer.agent.md  .claude/agents/codex-reviewer.md
cp ../ai-coding-config/templates/agents/simplify-reviewer.agent.md .claude/agents/simplify-reviewer.md

# スキルをシンボリックリンクで参照
mkdir -p .claude/skills
ln -s ../../../ai-coding-config/skills/code-review         .claude/skills/code-review
ln -s ../../../ai-coding-config/skills/self-review         .claude/skills/self-review
ln -s ../../../ai-coding-config/skills/fix-review-comments .claude/skills/fix-review-comments
ln -s ../../../ai-coding-config/skills/security-review     .claude/skills/security-review
```

設定後のディレクトリ構成：

```text
my-app/
└── .claude/
    ├── agents/
    │   ├── reviewer.md           ← コピー
    │   ├── codex-reviewer.md     ← コピー
    │   └── simplify-reviewer.md  ← コピー
    └── skills/
        ├── code-review/          ← symlink
        ├── self-review/          ← symlink
        ├── fix-review-comments/  ← symlink
        └── security-review/      ← symlink
```

使い方：

```bash
/code-review          # 単体レビュー
/self-review          # 3並列レビュー → 批判的精査 → 自動修正
/fix-review-comments  # レビュー指摘の精査・修正のみ
/security-review      # PR差分のセキュリティレビュー（OWASP Top 10）
```

#### `/security-review` の設計について

[sabakan1/claude-security-skills](https://zenn.dev/sabakan1/articles/57ca07f4b277b4) の記事を参考に、以下の2点を取り込んだ：

**信頼度スコアによる偽陽性の抑制**
各指摘に 0.0〜1.0 の信頼度スコアを付与し、**0.8未満は出力しない**。
既存のバリデーション層やフレームワークの保護が機能している場合はスコアを下げて報告しない。
これにより「たぶん大丈夫だが念のため」という低品質な指摘を除外できる。

**git diff 限定のスコープ**
プロジェクト全体ではなく PR の差分のみを対象にすることでコストと実行時間を抑える。
全体スキャンが必要な場面（リリース前等）は `npm audit` / `trivy` 等の専用ツールを併用する。

> カバレッジの限界: コードの静的パターン検査のため、ビジネスロジック欠陥・ランタイム脆弱性は検出不可。
> OWASP Top 10 の実カバレッジは 65〜70% 程度と見積もる（記事の実測値より）。

### 5. SessionStart Hook の動作確認

Claude Code を起動すると `session-start.sh` が自動実行される。

- `✓ 共通ルールは最新です` → 正常
- `✓ 共通ルールを更新しました` → GitHubから最新ルールを自動取得
- `⚠ ai-coding-config が見つかりません` → clone 先のパスを確認

---

## ディレクトリ構成の前提

```text
~/Project/
├── ai-coding-config/   ← このリポジトリ
├── my-app/
│   ├── CLAUDE.md
│   └── .claude/
│       ├── settings.json
│       ├── hooks/
│       │   └── session-start.sh  (symlink)
│       └── rules/core/           (symlinks)
└── another-project/
```

---

## 共通ルールを更新したとき

`ai-coding-config` を編集して push するだけ。
次回セッション起動時に各プロジェクトが自動で pull する。

```bash
cd ~/Project/ai-coding-config
# rules/ や hooks/ を編集
git add . && git commit -m "feat: ルール更新"
git push
```
