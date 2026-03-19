#!/bin/bash
# SessionStart Hook: 共通リポジトリの自動同期

SHARED_REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)/ai-coding-config"

if [ ! -d "$SHARED_REPO_DIR/.git" ]; then
  echo "⚠ ai-coding-config が見つかりません: $SHARED_REPO_DIR"
  exit 0
fi

cd "$SHARED_REPO_DIR" || exit 0

git fetch --quiet 2>/dev/null || { echo "⚠ fetch失敗（オフライン？）"; exit 0; }

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")

[ -z "$REMOTE" ] && { echo "⚠ upstreamが未設定です"; exit 0; }
[ "$LOCAL" = "$REMOTE" ] && { echo "✓ 共通ルールは最新です"; exit 0; }

git pull --ff-only --quiet 2>/dev/null \
  && echo "✓ 共通ルールを更新しました" \
  || echo "⚠ pull失敗（競合の可能性）"
