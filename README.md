# Claude Code でスマホ・ウェブアプリ開発を始める

Claude Code と Codex CLI を組み合わせた、個人開発アプリの開発ワークフロー **スターターキット**。
**Windows PC の開発未経験環境** からセットアップできるよう設計されています。

## ドキュメント

**[📄 セットアップガイド (docs/index.html)](docs/index.html)**
— ツールのインストールから開発ワークフローの使い方まで、すべて HTML ガイドで解説。
ブラウザで開いてください。

## 前提となる環境

| 前提 | 内容 |
|---|---|
| OS | Windows 10 / 11 |
| 開発環境 | **未セットアップでも OK**（Node.js・Git・VS Code 含め手順内でインストール） |
| アカウント | Claude Pro または Max、ChatGPT、GitHub アカウントが必要 |

## クイックスタート（概要）

詳細手順は **[docs/index.html](docs/index.html)** を参照してください。

### 1. 開発ツールを一括インストール（PowerShell 管理者で実行）

```powershell
winget install -e --id OpenJS.NodeJS.LTS
winget install -e --id Git.Git
winget install -e --id GitHub.cli
winget install -e --id Microsoft.VisualStudioCode
```

### 2. Claude Code をインストール

```powershell
npm install -g @anthropic-ai/claude-code
```

### 3. Codex CLI をインストール・ログイン

```powershell
npm install -g @openai/codex
codex login
```

### 4. MCP サーバーを登録（マシンごとに一度だけ）

```powershell
claude mcp add codex -s user -- codex mcp-server
claude mcp list   # codex が "✔ Connected" になっていれば OK
```

### 5. このテンプレートから新規プロジェクトを作成

```powershell
gh auth login   # 初回のみ
gh repo create my-app --template toshimaru-dev/phoneapp-dev-harness --clone
cd my-app
npm install
```

### 6. Claude Code を起動

```powershell
claude
```

## 役割分担

| フェーズ | 担当 | 手段 |
|---|---|---|
| 要件定義・設計 | Claude Code | dev-workflow スキル |
| 実装（コーディング） | Codex | `mcp__codex__codex`（MCP 経由） |
| 評価・コードレビュー | Claude Code | dev-workflow スキル |
| リリース準備 | Claude Code | dev-workflow スキル |
| SNS 告知素材生成 | Codex | app-release-promo スキル経由 |

## リポジトリ構成

```
.claude/skills/
├── dev-workflow/           # 要件定義→設計→実装委任→評価→リリース準備
│   ├── SKILL.md
│   └── templates/
└── app-release-promo/      # SNS 告知素材（投稿文・バナー・コンセプト画像）生成
    ├── SKILL.md
    ├── templates/
    └── scripts/
docs/
├── index.html              # Windows 向けセットアップ・使い方ガイド
└── skill-spec.md           # スキル設計仕様書（設計背景）
```

## トラブルシューティング

`docs/index.html` の「トラブルシューティング」セクションを参照してください。

| よくある症状 | 対処 |
|---|---|
| コマンドが認識されない | PowerShell を閉じて開き直す |
| `mcp__codex__codex` が見当たらない | `claude mcp add codex -s user -- codex mcp-server` 後に Claude Code 再起動 |
| Codex ログインで権限エラー | PowerShell（管理者）で `icacls "$env:USERPROFILE\.codex" /grant "$env:USERNAME:(OI)(CI)F"` |
