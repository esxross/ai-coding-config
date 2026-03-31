---
name: freeze
description: Edit/Write 操作を指定ディレクトリに限定するスキル。デバッグ中に Claude が「関連するから直しておきますね」と意図しないファイルを変更するのを防ぐ。/unfreeze で解除。セキュリティ境界ではなく誤操作防止の便宜機能。
---

# /freeze スキル

## 概要

Edit・Write 操作を指定ディレクトリ内のファイルのみに限定します。
Read・Bash・Glob・Grep は引き続き使用できます。

**用途**: デバッグ中・特定機能の修正中に、Claude が「関連するから直しておきますね」と
意図しない範囲のファイルを変更するのを防ぐ。

**注意**: 便宜機能であり、セキュリティ境界ではありません（sed 等での迂回は可能）。

---

## 使い方

```
/freeze src/validators/
```

引数なしの場合はカレントディレクトリ（`./`）に固定：

```
/freeze
```

---

## 有効化時の動作

有効化後、以下を実行する：

```bash
# 絶対パスに解決して状態ファイルに保存
FREEZE_DIR=$(realpath "${1:-.}")
echo "$FREEZE_DIR" > /tmp/claude-freeze-$(pwd | md5).flag
echo "freeze: $FREEZE_DIR に固定しました"
```

有効化後は、Edit・Write を実行しようとする際に以下を確認する：

1. 対象ファイルのパスが freeze ディレクトリ以下か確認
2. 範囲外の場合は実行せず、以下を表示：

```
🧊 FREEZE モード: {ファイルパス} は freeze 範囲外です
freeze 範囲: {freeze ディレクトリ}
このファイルを変更するには /unfreeze してください。
```

3. 範囲内の場合は通常通り実行

---

## 解除

```
/unfreeze
```

```bash
rm -f /tmp/claude-freeze-$(pwd | md5).flag
echo "unfreeze: 編集制限を解除しました"
```

---

## 使用例

```bash
# validators/ のデバッグ中、他のファイルを誤変更したくない場合
/freeze src/validators/

# 特定ファイルのみ修正する場合（ディレクトリを絞る）
/freeze src/components/LoginForm/

# 解除
/unfreeze
```
