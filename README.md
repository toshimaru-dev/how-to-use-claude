# phoneapp-dev-harness

個人開発アプリの開発サイクルを Claude Code + Codex CLI で回すための **Claude Code Skills 一式**。
このリポジトリを GitHub の Template repository として新規プロジェクトを作れば、
セットアップ済みの開発ワークフローがそのまま使える状態になる。

## 役割分担

| フェーズ | 担当 | 手段 |
|---|---|---|
| 要件定義・設計 | Claude Code | 対話 + `dev-workflow` スキル |
| 実装（コーディング） | Codex | `mcp__codex__codex`（MCP経由） |
| 評価（コードレビュー・テスト・受け入れ基準・セキュリティ） | Claude Code | `dev-workflow` スキル |
| リリース準備 | Claude Code | `dev-workflow` スキル |
| SNS告知素材（投稿文・バナー・コンセプト画像） | Codex | `codex exec`（`app-release-promo` スキル経由） |

Claude Code はプロダクションコードを直接書かず、要件定義・設計・評価・リリース準備に専念する。
実装は常に Codex に委任する。詳細な手順は各スキルの `SKILL.md` を参照。

## 含まれるもの

```
.claude/skills/
├── dev-workflow/         # 要件定義→設計→実装委任→評価→リリース準備の一連の手順
│   ├── SKILL.md
│   └── templates/        # 要件定義書・設計書・評価レポートのテンプレート
└── app-release-promo/    # SNS告知素材（投稿文・バナー画像・コンセプト画像）生成
    ├── SKILL.md
    ├── templates/
    └── scripts/
```

## 前提セットアップ（このマシンで一度だけ）

このリポジトリをテンプレートから作成しただけでは動かない部分がある。以下はリポジトリ単位ではなく
**マシン単位**の設定なので、初めてこのハーネスを使うマシンごとに一度だけ実行する。

### 1. Codex CLI のインストールとログイン

```bash
npm i -g @openai/codex
codex login
codex login status   # "Logged in using ChatGPT" と表示されればOK
```

`Failed to create session: Operation not permitted` が出た場合:

```bash
sudo chown -R $(whoami) ~/.codex
```

### 2. Codex MCP サーバーをユーザースコープで登録

`dev-workflow` スキルは `mcp__codex__codex` / `mcp__codex__codex-reply` ツールを使って実装を
Codex に委任する。プロジェクトごとの `.mcp.json` ではなく、ユーザースコープ（マシン全体）で
一度登録すれば、このハーネスから作った全プロジェクトで共通して使える。

```bash
claude mcp add codex -s user -- codex mcp-server
claude mcp list   # codex が "✔ Connected" になっていればOK
```

### 3. `app-release-promo` 用の Playwright（初回利用時に自動 or 手動でセットアップ）

バナー画像のHTML→PNG変換に Playwright を使う。スキル同梱の仮想環境として、初回利用時に
以下を実行する（`app-release-promo/SKILL.md` の手順内でも案内される）。

```bash
cd .claude/skills/app-release-promo
python3 -m venv .venv
./.venv/bin/pip install playwright
./.venv/bin/python -m playwright install chromium
```

## 使い方

### 新規プロジェクトの作成

GitHub上で **Use this template** ボタンから新規リポジトリを作成するか、CLIなら:

```bash
gh repo create <new-repo-name> --template toshimaru-dev/phoneapp-dev-harness --clone
cd <new-repo-name>
```

前提セットアップ（上記）が済んでいるマシンであれば、`claude` を起動してそのまま使える。

### ワークフローの実行

Claude Code のセッション内で、機能追加や新規開発の依頼を通常どおり話しかければ
`dev-workflow` スキルが自動的にトリガーされる（例:「〇〇機能を実装したい」「この要件で開発を進めて」）。

1. 要件定義（`docs/dev-workflow/{機能名}/requirements.md` を作成、内容を確認）
2. 設計（`docs/dev-workflow/{機能名}/design.md` を作成、Codexへの実装指示を含む）
3. 実装をCodexに委任（`mcp__codex__codex` 呼び出し、完了までポーリングではなく1回の呼び出しで待機）
4. 評価（コードレビュー・テスト・受け入れ基準・セキュリティレビュー。不合格なら3へ差し戻し）
5. リリース準備（CHANGELOG・PR説明の下書きなど）

リリース告知素材が必要な場合は「リリース告知素材作って」のように話しかければ
`app-release-promo` スキルがトリガーされる。

## トラブルシューティング

各スキルの `SKILL.md` 末尾にトラブルシューティング表がある。マシン単位のセットアップに関する
問題は主に上記「前提セットアップ」を参照。

## 設計背景

このハーネスの元になった設計インプットは [`docs/skill-spec.md`](docs/skill-spec.md) に残している
（`app-release-promo` スキルの詳細設計仕様書）。
