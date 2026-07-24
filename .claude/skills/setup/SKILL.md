---
name: setup
description: >
  Windows 環境でこのリポジトリを使うための初回セットアップを行う。Node.js・Git・GitHub CLI・
  VS Code・Codex CLI のインストール確認から、Codex ログイン、MCP サーバー（codex）登録まで
  一気通貫で案内・実行する。
  「セットアップして」「環境構築して」「初回セットアップ」「ツールをインストールして」
  「開発環境を整えて」といった依頼があれば積極的にこのスキルを使うこと。
allowed-tools: PowerShell Read
---

# setup スキル

Windows PC でこのリポジトリの開発ワークフローを使えるようにするための
初回セットアップを、チェック → インストール → 再確認の順で進める手順書。

## 前提

このスキルは Claude Code が既に起動している状態（= Claude Code 自体はインストール済み）で使う。
「Node.js・Git など基盤ツール」と「Codex 連携」の2段階をカバーする。

## ステップ 1: 現状確認

まずチェックスクリプトを実行して現在の状態を把握する。

```powershell
powershell -ExecutionPolicy Bypass -File ".claude\skills\setup\scripts\check-setup.ps1"
```

スクリプトの出力（`[OK]` / `[NG]` 行と末尾の JSON ブロック）を読み取り、
`Ok: false` の項目を特定する。結果をユーザーに日本語で表示し、何が不足しているかを伝える。

## ステップ 2: 管理者権限が必要なツールのインストール

Node.js・Git・GitHub CLI・VS Code が未インストールの場合、Claude Code 自身は実行できないため
ユーザーに以下を依頼する。

> **PowerShell（管理者）** を開いて、以下のコマンドを実行してください。
> 終わったら PowerShell を閉じて開き直し、「続けて」と入力してください。

```powershell
# 未インストールのものだけ実行（インストール済みはスキップされる）
winget install -e --id OpenJS.NodeJS.LTS
winget install -e --id Git.Git
winget install -e --id GitHub.cli
winget install -e --id Microsoft.VisualStudioCode
```

ユーザーから「続けて」の返答があったらステップ 3 へ進む。
（winget でインストール済みのものは自動スキップされるので、4行まとめて実行して問題ない）

## ステップ 3: Codex CLI のインストール

Codex CLI が未インストールの場合は Claude Code が直接実行する。

```powershell
npm install -g @openai/codex
```

インストール後、バージョンを確認する。

```powershell
codex --version
```

## ステップ 4: Codex ログイン

Codex がログイン済みかを確認する。

```powershell
codex login status
```

未ログインの場合はユーザーに以下を依頼する（ブラウザが開くため Claude Code では実行できない）。

> ターミナルで `codex login` を実行し、ブラウザで ChatGPT にログインしてください。
> 完了したら「続けて」と入力してください。

## ステップ 5: MCP サーバー（codex）登録

MCP が未登録の場合は Claude Code が直接実行する。

```powershell
claude mcp add codex -s user -- codex mcp-server
```

## ステップ 6: 最終確認

すべての処理が終わったら、再度チェックスクリプトを実行して全項目が OK になっているか確認する。

```powershell
powershell -ExecutionPolicy Bypass -File ".claude\skills\setup\scripts\check-setup.ps1"
```

全項目 OK になっていれば、ユーザーに以下を伝えてスキルを終了する。

> セットアップが完了しました！
> MCP の反映には **Claude Code の再起動**が必要です。
> いったん Claude Code を終了し、プロジェクトディレクトリで `claude` を再実行してください。

未完了項目が残っている場合は、その項目の対処方法をユーザーに案内する。

## 注意事項

- **winget コマンドは管理者権限が必要**なため、Claude Code から直接実行しない。
  ユーザーが管理者 PowerShell で実行するよう案内すること。
- **codex login はブラウザ認証**が必要なため、Claude Code から直接実行しない。
- MCP 登録後は Claude Code の**再起動が必要**。再起動前に `mcp__codex__codex` が
  見えなくても正常（再起動すると反映される）。

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| winget が認識されない | Windows 10 の場合は App Installer を Microsoft Store からインストール |
| `npm install -g` で権限エラー | PowerShell（管理者）で実行 |
| `codex login` で `Operation not permitted` | PowerShell（管理者）で `icacls "$env:USERPROFILE\.codex" /grant "$env:USERNAME:(OI)(CI)F"` |
| MCP 登録後も `mcp__codex__codex` が見えない | Claude Code を再起動する |
| スクリプトが `ExecutionPolicy` エラーで実行できない | `-ExecutionPolicy Bypass` を付けて実行しているか確認 |
