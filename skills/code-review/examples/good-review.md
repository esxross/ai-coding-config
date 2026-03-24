# 良いレビュー指摘の例

このドキュメントは、レビューで出すべき適切な指摘のパターンを示します。

---

## 例1: HIGH — ループ内のDBアクセス

---
### [HIGH] backend/src/modules/task/task.service.ts#L32-L38

- **ルール**: B-8（ループ内のDBアクセス禁止）
- **内容**: `for` ループ内で `taskRepository.update()` を毎回呼び出しています。タスク数が多い場合にDBへの負荷が増大し、パフォーマンス劣化や接続枯渇が発生するリスクがあります。
- **修正提案**: トランザクション内でバルクアップデートを使用してください。

```typescript
// 修正前（NG）
for (const task of tasks) {
  await this.taskRepository.update(task.id, { status: 'done' })
}

// 修正後（OK）
await this.dataSource.transaction(async (em) => {
  await em.getRepository(Task).update(
    { id: In(tasks.map(t => t.id)) },
    { status: 'done' }
  )
})
```
---

**良い点**:
- 行番号の範囲を示している
- パフォーマンスへの具体的な影響（DB負荷・接続枯渇）を説明している
- ルールIDを明示している
- 修正前後のコード例を提示している

---

## 例2: HIGH — TypeScript型エラー（import元の誤り）

---
### [HIGH] backend/src/modules/user/user.controller.ts#L5

- **ルール**: TypeScript コンパイルエラー（型の整合性）
- **内容**: `IUserProfile` を `user.interface.ts` から import しているが、このインターフェースは `profile.interface.ts` にのみ定義されている。`user.interface.ts` には `IUserProfile` は存在しないため、TypeScript コンパイルエラーが発生する。
- **確認**: `git grep -n "IUserProfile"` で確認済み。`profile.interface.ts:L18` のみに定義されており、他の正しい利用箇所（`profile.controller.ts`）も `profile.interface` から import している。
- **修正提案**: import元を修正する。

```typescript
// 修正前（NG）
import { IUserProfile } from './user.interface'

// 修正後（OK）
import { IUserProfile } from '../profile/profile.interface'
```
---

**良い点**:
- git grep による調査結果を根拠として示している
- 正しい利用箇所と比較している
- コンパイルエラーになる旨を明記している

---

## 例3: MEDIUM — トランザクション内での外部API呼び出し

---
### [MEDIUM] backend/src/modules/payment/payment.service.ts#L55-L72

- **ルール**: B-12（トランザクション内での外部API呼び出し禁止）
- **内容**: DB トランザクション内で外部決済APIを呼び出しています。外部APIのレスポンスが遅延した場合にトランザクションが長時間ロックされ、デッドロックやタイムアウトが発生するリスクがあります。
- **修正提案**: 外部API呼び出しをトランザクションの外に出し、API成功後にDB更新を行う設計に変更してください。
---

---

## 例4: LOW — クラス名が責務を示していない

---
### [LOW] backend/src/modules/notification/notification.service.ts#L1

- **ルール**: `backend.instructions.md` — クラス設計「クラス名は具体的な目的が分かる名前にすること」
- **内容**: `NotificationService` はエンティティ名のみのクラス名であり、クラス内部の実装（メール送信・プッシュ通知の振り分け）を見ると「通知の送信」という責務が主体であることが分かる。
- **修正提案**: `SendNotificationService` または `NotificationDispatchService` に変更することを推奨する。クラス内に複数の責務が混在している場合はクラス分割も検討する。
---

**良い点**:
- 単に「名前を変えろ」ではなく、クラス内実装を確認した上で責務を特定している
- 具体的な候補名を提示している
- NG例（`NotificationService`）がどのパターンに該当するかを示している
