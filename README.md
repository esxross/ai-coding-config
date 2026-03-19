# ai-coding-config

Claude Code をはじめとするAIコーディングツール向けの共通ルール・スキル管理リポジトリ。

## 構成

| ディレクトリ | 内容 |
|---|---|
| `rules/core/` | 言語設定・Git規約・セッション基本動作 |
| `rules/quality/` | コードレビュー・テスト・セキュリティ |
| `rules/workflow/` | タスク管理・Issue・リリース |
| `skills/` | 再利用可能なスキル定義 |
| `hooks/` | SessionStart等のHookスクリプト |
| `templates/` | 各リポジトリ用のひな形 |

## 対応ツール

- Claude Code（主）
- Cursor（`.cursor/rules/` 対応予定）

## セットアップ
```bash
# 各リポジトリの親ディレクトリに clone する
cd ~/projects
git clone https://github.com/YOUR_USERNAME/ai-coding-config.git
```

各リポジトリからのシンボリックリンク設定は `templates/setup.sh` を参照。
