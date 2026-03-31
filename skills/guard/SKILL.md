---
name: guard
description: /careful + /freeze を同時有効化する統合安全モード。本番作業・migration実行・重要データ操作の前に宣言することで、破壊的コマンド警告と編集スコープ固定を一括適用する。ソロ開発者のメンタルロードを下げるのが主目的。
---

# /guard スキル

## 概要

`/careful`（破壊的コマンド警告）と `/freeze`（編集スコープ固定）を同時有効化します。
本番作業・migration 実行・重要データ操作の前に唱えるだけで最大安全モードになります。

---

## 使い方

```
/guard [ディレクトリ]
```

ディレクトリ省略時は `/careful` のみ有効化（`/freeze` は任意）：

```
/guard              # careful のみ
/guard src/         # careful + freeze src/
/guard supabase/    # careful + freeze supabase/（migration作業時など）
```

---

## 有効化時の動作

以下を順番に実行する：

1. **`/careful` を有効化**

```bash
echo "careful" > /tmp/claude-careful-$(pwd | md5).flag
```

2. **ディレクトリ引数がある場合は `/freeze` も有効化**

```bash
FREEZE_DIR=$(realpath "${1:-.}")
echo "$FREEZE_DIR" > /tmp/claude-freeze-$(pwd | md5).flag
```

3. **有効化を宣言**

```
🛡 GUARD モード 有効

  ✓ careful: 破壊的コマンドを検知したら確認を求めます
  ✓ freeze:  {ディレクトリ} 以外の Edit/Write をブロックします
             （ディレクトリ未指定の場合は freeze なし）

解除するには /unguard を実行してください。
```

---

## 解除

```
/unguard
```

`/careful` と `/freeze` を同時解除する：

```bash
rm -f /tmp/claude-careful-$(pwd | md5).flag
rm -f /tmp/claude-freeze-$(pwd | md5).flag
echo "🔓 GUARD モード解除"
```

---

## 推奨使用シーン

| 作業 | 推奨コマンド |
| --- | --- |
| 本番 DB の migration 実行 | `/guard supabase/migrations/` |
| 認証・決済コードの修正 | `/guard src/auth/` |
| 特定バグのデバッグ | `/guard src/該当ディレクトリ/` |
| `main` ブランチへのマージ前確認 | `/guard` |

---

## hooks との連携（自動発動）

`hooks/pre-tool-use-guard.sh` を PreToolUse フックに設定すると、
`/guard` を手動宣言しなくても危険操作を自動検知できる。

設定方法は `hooks/pre-tool-use-guard.sh` のコメントを参照。
