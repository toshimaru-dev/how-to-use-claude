# Claude Code でスマホ・ウェブアプリ開発を始める

Claude Code と Codex CLI を組み合わせた、個人開発アプリの開発ワークフロー **スターターキット**。
要件定義・設計・評価は Claude Code が担い、実装（コーディング）は Codex に委任する役割分担で動きます。

## はじめかた（初回セットアップ）

### 1. Claude Code をインストール

Node.js がない場合は先に [nodejs.org](https://nodejs.org/) からインストールしてください。

```powershell
npm install -g @anthropic-ai/claude-code
```

### 2. このテンプレートからリポジトリを作成・クローン

GitHub の **「Use this template」** ボタンから新規リポジトリを作成し、クローンします。

```powershell
gh repo create my-app --template toshimaru-dev/how-to-use-claude --clone
cd my-app
```

### 3. Claude Code を起動して「セットアップして」と伝える

```powershell
claude
```

起動したら以下のように入力してください。

> **セットアップして**

`setup` スキルが起動し、Git・GitHub CLI・VS Code・Codex CLI のインストールから
Codex ログイン・MCP サーバー登録まで、ステップごとに案内します。

---

セットアップ完了後は、Claude Code を再起動すれば開発を始められます。

> **セットアップ確認して**

と伝えると `setup-check` スキルが各ツールの状態をまとめてレポートします。

## スキル一覧

Claude Code に話しかけるだけで各スキルが起動します。

| スキル | 起動する言葉の例 | 内容 |
|---|---|---|
| `setup` | 「セットアップして」「環境構築して」 | 開発ツール一式のインストールと設定を案内 |
| `setup-check` | 「セットアップ確認して」「環境チェック」 | 各ツールの状態をレポート |
| `dev-workflow` | 「〇〇機能を作りたい」「要件定義して」 | 要件定義→設計→実装委任→評価→リリース準備を一気通貫で進行 |
| `app-release-promo` | 「リリース告知素材を作って」 | SNS 投稿文・バナー・コンセプト画像を生成 |

## 役割分担

| フェーズ | 担当 | スキル |
|---|---|---|
| 要件定義・設計 | Claude Code | dev-workflow |
| 実装（コーディング） | Codex（MCP 経由） | dev-workflow |
| 評価・コードレビュー | Claude Code | dev-workflow |
| リリース準備 | Claude Code | dev-workflow |
| SNS 告知素材生成 | Codex | app-release-promo |

## 前提となるアカウント

| サービス | 用途 |
|---|---|
| Claude Pro / Max | Claude Code の利用 |
| ChatGPT（OpenAI） | Codex CLI の利用 |
| GitHub | リポジトリ管理・テンプレート利用 |

## リポジトリ構成

```
.claude/skills/
├── setup/                  # 初回セットアップ（ツールインストール・Codex 連携）
│   ├── SKILL.md
│   └── scripts/
├── setup-check/            # セットアップ状態の確認・レポート
│   └── SKILL.md
├── dev-workflow/           # 要件定義→設計→実装委任→評価→リリース準備
│   ├── SKILL.md
│   └── templates/
└── app-release-promo/      # SNS 告知素材（投稿文・バナー・コンセプト画像）生成
    ├── SKILL.md
    ├── templates/
    └── scripts/
docs/
└── index.html              # セットアップ・使い方ガイド（GitHub Pages で公開）
```

詳細は **[セットアップガイド](https://toshimaru-dev.github.io/how-to-use-claude/)** も参照してください。

## トラブルシューティング

| よくある症状 | 対処 |
|---|---|
| `claude` コマンドが認識されない | PowerShell を閉じて開き直す |
| `mcp__codex__codex` が見当たらない | `claude mcp add codex -s user -- codex mcp-server` 後に Claude Code 再起動 |
| Codex ログインで権限エラー | PowerShell（管理者）で `icacls "$env:USERPROFILE\.codex" /grant "$env:USERNAME:(OI)(CI)F"` |
