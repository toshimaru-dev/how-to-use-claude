---
name: setup-check
description: >
  開発環境のセットアップが完了しているかを確認し、各ツールの状態をレポートする。
  Node.js・Git・GitHub CLI・VS Code・Claude Code・Codex CLI のインストール状況、
  Codex ログイン状態、MCP codex 登録状況をまとめてチェックする。
  「セットアップ確認して」「環境チェック」「ツールが入ってるか確認」「セットアップ状態を見て」
  「何が足りないか教えて」といった依頼があれば積極的にこのスキルを使うこと。
allowed-tools: PowerShell Read
---

# setup-check スキル

開発環境の現状を一括チェックしてレポートするスキル。
インストール・設定は行わない（それは `setup` スキルの役割）。

## 実行手順

チェックスクリプトを実行する。

```powershell
powershell -ExecutionPolicy Bypass -File ".claude\skills\setup\scripts\check-setup.ps1"
```

スクリプトは `[OK]` / `[NG]` の行と末尾の JSON ブロックを出力する。
JSON を解析して未完了項目を特定し、ユーザーへ日本語でレポートする。

## 結果の読み取りと報告

スクリプトの出力（人間向けテキスト＋JSON）を読み取り、以下の形式でユーザーに報告する。

### 全項目 OK の場合

> 開発環境はすべて整っています。いつでも開発を始められます。

### 未完了項目がある場合

未完了の項目を列挙し、それぞれ何をすればよいかを簡潔に伝える。

- **管理者権限が必要なツール**（Node.js / Git / GitHub CLI / VS Code）が未インストール
  → `setup` スキルで案内するか、PowerShell（管理者）で `winget` コマンドを実行するよう伝える
- **Codex CLI** が未インストール
  → `npm install -g @openai/codex` で対応可能と伝える
- **Codex ログイン** が未完了
  → `codex login` を実行するよう伝える
- **MCP codex** が未登録
  → `claude mcp add codex -s user -- codex mcp-server` で対応可能と伝える

未完了項目が1つでもある場合は、`setup` スキルを使えばステップごとに案内できることを伝える。

## チェック項目一覧

| 項目 | 確認方法 | OK の条件 |
|---|---|---|
| Node.js | `node --version` | コマンドが存在する |
| Git | `git --version` | コマンドが存在する |
| GitHub CLI | `gh --version` | コマンドが存在する |
| VS Code | `code --version` | コマンドが存在する |
| Claude Code | `claude --version` | コマンドが存在する |
| Codex CLI | `codex --version` | コマンドが存在する |
| Codex ログイン | `codex login status` | "Logged in" が含まれる |
| MCP codex 登録 | Claude 設定ファイルを確認 | codex エントリが存在する |
