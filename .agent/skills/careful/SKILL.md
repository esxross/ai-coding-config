---
name: careful
description: 破壊的・不可逆なコマンドの実行前に警告を出すセーフガード。rm -rf・DROP TABLE・force-push などを検知し、実行前に確認を求める。セッションスコープで有効、/uncareful で解除。
---

# /careful スキル

## 概要

危険な操作の前に警告を出し、確認を求めるセーフガードです。
セッション中有効で、`/uncareful` で解除できます。

---

## 有効化

```
/careful を実行しました。
以下の操作を検知した場合、実行前に確認を求めます。
```

有効化後、以下を実行する：

```bash
echo "careful" > /tmp/claude-careful-$(pwd | md5).flag
```

---

## 警告対象パターン

### 必ず確認する操作

**ファイル・ディレクトリ操作**
- `rm -rf` / `rm -r` / `rimraf`
- `git clean -f` / `git checkout -- .` / `git restore .`
- `find ... -delete`

**Git 操作**
- `git push --force` / `git push -f`
- `git reset --hard`
- `git rebase` （--onto 含む）
- ブランチの強制削除 `git branch -D`

**データベース操作**
- `DROP TABLE` / `DROP DATABASE` / `DROP SCHEMA`
- `TRUNCATE`
- `DELETE FROM` （WHERE 句なし）
- `UPDATE` （WHERE 句なし）
- migration の rollback / reset

**インフラ操作**
- `kubectl delete`
- `docker rm -f` / `docker rmi -f`
- `terraform destroy`

### プロジェクト固有パターンの追加

`CLAUDE.md` に以下を追記することでプロジェクト固有の危険パターンを追加できる：

```markdown
## /careful 追加パターン
- supabase db reset
- {プロジェクト固有の危険コマンド}
```

---

## 警告メッセージ形式

```
⚠ CAREFUL モード: 破壊的操作を検知しました

操作: {コマンド}
リスク: {何が起きるか・影響範囲}

本当に実行しますか？ [yes/no]
```

`yes` と入力された場合のみ実行する。`no` または無回答の場合はキャンセル。

---

## 解除

```
/uncareful
```

```bash
rm -f /tmp/claude-careful-$(pwd | md5).flag
```
