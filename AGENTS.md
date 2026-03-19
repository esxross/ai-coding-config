# AGENTS.md - Next.js AI App

## Project Context
- Stack: Next.js 14, TypeScript, Tailwind CSS, Claude API
- Architecture: App Router + Server Components
- Testing: Jest + React Testing Library

## Agent Rules

### 必須ルール
- テストなしのPRは出さない
- `main` への直接 push 禁止
- APIキーをコードにハードコードしない

### コード生成ルール
- コンポーネントは関数コンポーネントで記述する
- `useState` より `useReducer` を複雑な状態管理に使う
- エラーバウンダリを適切に設置する
- Loading / Error / Empty の3状態を必ず考慮する

### Claude API 使用ルール
- ストリーミングレスポンスを基本とする
- トークン数・コストを意識してモデルを選択する
  - 軽量タスク: `claude-haiku-4-5`
  - 標準タスク: `claude-sonnet-4-6`
  - 複雑なタスク: `claude-opus-4-6`

## Agent Role Design
```
Lead Agent (Opus)      → アーキテクチャ判断・コードレビュー
Teammate Agents (Haiku) → UI実装・テスト生成・ドキュメント
```
