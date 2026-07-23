# CLAUDE.md

このファイルは、このリポジトリで作業する Claude Code 向けのガイダンス。

## このリポジトリについて

`phoneapp-dev-harness` は、個人開発アプリの開発サイクル（要件定義→設計→実装→評価→リリース準備）を
Claude Code と Codex CLI の役割分担で回すための Skills 一式のテンプレートリポジトリ。
GitHub の Template repository から作られた新規プロジェクトでは、このリポジトリの
`.claude/skills/` 一式がそのままコピーされている状態になる。

セットアップの詳細・前提条件は [README.md](README.md) を参照。役割分担や各フェーズの詳しい手順は
[`.claude/skills/dev-workflow/SKILL.md`](.claude/skills/dev-workflow/SKILL.md) と
[`.claude/skills/app-release-promo/SKILL.md`](.claude/skills/app-release-promo/SKILL.md) を参照。

## 役割分担の原則（最重要）

- **要件定義・設計・評価・リリース準備は Claude Code が行う。**
- **実装（プロダクションコードを書くこと）は Codex に委任する。** `mcp__codex__codex` /
  `mcp__codex__codex-reply` ツールを使う。Claude Code自身がアプリケーションコードを直接
  書き換えることは、事前にユーザーの明示的な許可がない限り避ける。
- **SNS告知素材の画像生成は Codex（`codex exec` 経由）に任せる。** `app-release-promo` スキルが
  その入出力を担う。

この原則は、このリポジトリ自体（ハーネスのSkillファイルやドキュメントの編集）には適用されない。
`.claude/skills/*/SKILL.md` やテンプレート、`README.md`、このファイル自体を編集するのは
通常のドキュメント作業として Claude Code が直接行ってよい。原則が適用されるのは、
このハーネスから作られた**アプリケーションプロジェクトの実装コード**に対して。

## 開発の進め方

新機能・変更の依頼を受けたら、単発の小さな修正でない限り `dev-workflow` スキルを使う。
スキルが自動トリガーしない場合でも、要件定義から評価まで一気通貫で進めたい依頼であれば
積極的にこのスキルを使ってよい。

生成物の置き場所:

```
docs/dev-workflow/{機能名}/
    ├── requirements.md
    ├── design.md
    └── evaluation.md
```

## Codex MCP 連携について

Codex MCPサーバーはプロジェクト単位の `.mcp.json` ではなく、ユーザースコープ
（`claude mcp add codex -s user -- codex mcp-server`）で登録する運用にしている。
これは意図的な設計判断（[README.md](README.md) 参照）: このハーネスから作った全プロジェクトで
再設定不要にするため。プロジェクト直下に `.mcp.json` を追加する変更は行わないこと。

`mcp__codex__codex` ツールが見当たらない場合は、`.mcp.json` の問題ではなく
ユーザースコープの登録漏れ、またはセッション再起動が必要な状態を疑う。
