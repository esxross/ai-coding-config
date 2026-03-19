# ai-coding-config - Next.js AI App

## プロジェクト概要
- **スタック**: Next.js 14 (App Router), TypeScript, Tailwind CSS, Claude API
- **目的**: Claude Code をはじめとするAIコーディングツール向けの共通ルール・スキル管理リポジトリ。

## ディレクトリ構成
```
src/
├── app/          # Next.js App Router
├── components/   # 再利用可能なUIコンポーネント
├── lib/          # ユーティリティ・API クライアント
└── types/        # TypeScript 型定義
```

## コーディング規約
- コンポーネントは `src/components/` 配下に配置
- Server Components を優先し、必要な場合のみ `"use client"` を付ける
- API キーは `.env.local` で管理（コミットしない）
- 型は `any` を使わず、明示的に定義する

## AIエージェントへの指示
- 新機能追加前に `task.md` を更新してください。
- Claude API を使う処理は `src/lib/claude.ts` に集約してください。
- コンポーネント追加時は対応するテストも作成してください。
