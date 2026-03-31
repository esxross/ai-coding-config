#!/bin/bash
# pre-tool-use-guard.sh
#
# PreToolUse フックとして機能するガードスクリプト。
# /guard または /careful が有効なセッションで、
# 危険な Bash コマンドを検知したら警告を出す。
#
# 設定方法（.claude/settings.json）:
#   {
#     "hooks": {
#       "PreToolUse": [
#         {
#           "matcher": "Bash",
#           "hooks": [{ "type": "command", "command": ".claude/hooks/pre-tool-use-guard.sh" }]
#         }
#       ]
#     }
#   }
#
# プロジェクト固有の危険パターンは DANGEROUS_PATTERNS に追加する。

set -euo pipefail

# --- 設定 ---
SESSION_KEY=$(pwd | md5)
CAREFUL_FLAG="/tmp/claude-careful-${SESSION_KEY}.flag"
FREEZE_FLAG="/tmp/claude-freeze-${SESSION_KEY}.flag"

# 危険パターン（プロジェクト固有のものは追記する）
DANGEROUS_PATTERNS=(
  "rm -rf"
  "rm -r "
  "git push --force"
  "git push -f"
  "git reset --hard"
  "git clean -f"
  "git branch -D"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE"
  "kubectl delete"
  "docker rm -f"
  "docker rmi -f"
  "terraform destroy"
)

# --- ツール入力の読み込み ---
# Claude Code は stdin に JSON でツール入力を渡す
TOOL_INPUT=$(cat)
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
COMMAND=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" 2>/dev/null || echo "")

# --- careful フラグの確認 ---
if [[ ! -f "$CAREFUL_FLAG" ]]; then
  # careful モードが無効 → スルー
  exit 0
fi

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# --- 危険パターンの検査 ---
MATCHED_PATTERN=""
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    MATCHED_PATTERN="$pattern"
    break
  fi
done

if [[ -z "$MATCHED_PATTERN" ]]; then
  # 危険パターンなし → スルー
  exit 0
fi

# --- 警告出力 ---
# Claude Code の PreToolUse フックは stderr に出力すると
# Claude へのメッセージとして扱われる
cat >&2 <<EOF
⚠ CAREFUL モード: 破壊的操作を検知しました

コマンド : $COMMAND
検知パターン: $MATCHED_PATTERN

このコマンドは不可逆な変更を引き起こす可能性があります。
本当に実行する場合は "yes" と入力してください。
キャンセルする場合は "no" または Enter を押してください。
EOF

# フックが exit 1 を返すと Claude はユーザーに確認を求める
exit 1
