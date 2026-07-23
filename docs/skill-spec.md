# スキル設計仕様書：app-release-promo（アプリリリース告知支援スキル）

> このドキュメントはClaude Codeに渡して、実際のSkill（SKILL.md + 補助スクリプト）を構築してもらうための設計インプットです。

---

## 1. 背景・目的

個人開発アプリ（KashiKari、KinLogなど）のリリース時に、SNS（Instagram / Threads）向けの告知素材を作るのが手間かつ苦手。Claude Codeに「アプリ名と概要を渡すだけ」で、投稿文・バナー画像・コンセプト画像の初稿一式を生成してもらい、人間は選ぶ・微調整するだけの状態にしたい。

**将来的な拡張構想（Phase 2、今回は対象外）：**
App Store Connect提出用のメタデータ（説明文、キーワード、Whatʼs Newなど）の生成も同じスキル群でカバーする。今回はPhase 1（SNS告知素材生成）のみに絞る。

---

## 2. Phase 1 スコープ

今回構築するのは以下の3点の生成に限定する。

| 生成物 | 内容 |
|---|---|
| ① SNS投稿文 | Instagram用・Threads用それぞれの文字数・トンマナに合わせたキャプション案（複数パターン） |
| ② 告知バナー画像 | アプリアイコン＋キャッチコピーを載せた告知用バナー（テンプレートベース、コード生成） |
| ③ コンセプト画像 | AI画像生成（Codex CLI経由のOpenAI Image-2）によるイメージビジュアル・挿絵 |

スクリーンショットの自動取得（実機/シミュレータ）は今回は対象外。ユーザーが手動で用意した画像を①③と組み合わせて使う想定。

---

## 3. 動作環境

- **実行環境**: Claude Code（ターミナル）
- **画像生成エンジン**: Codex CLI経由でOpenAI Image-2 (`gpt-image-2`) を呼び出す
  - OpenAI API keyは使わず、ChatGPTアカウントのログイン認証を利用
  - Claude Codeはbashを直接実行できるため、MCPブリッジは不要（Claude Code単体での利用が前提）

---

## 4. 環境構築手順（Claude Codeに実行してほしい前提セットアップ）

```bash
# 1. Codex CLIのインストール
npm i -g @openai/codex
# または: brew install --cask codex

# 2. ChatGPTアカウントでログイン
codex login
codex login status   # "Logged in using ChatGPT" と表示されればOK

# 3. 権限まわりの事前確認（トラブルシューティング用）
# もし "Failed to create session: Operation not permitted" が出たら:
sudo chown -R $(whoami) ~/.codex

# 4. 動作確認（最小実行）
mkdir -p ./images
codex exec -C "$(pwd)" -s workspace-write \
  --skip-git-repo-check \
  "テスト画像を1枚生成し、./images/test.png に保存して"
```

上記が通ることを確認してから、Skill本体の実装に進む。

---

## 5. ディレクトリ構成（案）

```
~/.claude/skills/app-release-promo/
├── SKILL.md                      # スキル本体（トリガー・手順定義）
├── templates/
│   ├── banner_template.html      # バナー画像用HTMLテンプレート（Playwright等でPNG化）
│   └── caption_templates.md      # 投稿文の型・トンマナ例
└── scripts/
    ├── generate_caption.py       # 投稿文生成ロジック（必要なら）
    ├── render_banner.py          # HTMLテンプレート→PNG変換スクリプト
    └── gen_concept_image.sh      # Codex CLI呼び出しラッパー

出力先（プロジェクトごと）:
./release-assets/{app_name}/{yyyy-mm-dd}/
    ├── captions/
    │   ├── instagram.md
    │   └── threads.md
    ├── banner.png
    └── concept_image.png
```

---

## 6. インプット項目（スキル呼び出し時にユーザーから受け取る情報）

スキルの対話フローで、以下を確認・収集する。

| 項目 | 例 | 必須/任意 |
|---|---|---|
| アプリ名 | KashiKari | 必須 |
| 一言コンセプト | 友達同士の貸し借りを記録するアプリ | 必須 |
| リリース種別 | 新規リリース / アップデート / 機能追加 | 必須 |
| 訴求ポイント（3つ程度） | 割り勘不要、通知機能、シンプルUI | 必須 |
| トンマナ・文体 | カジュアル / 落ち着いた / エンジニア向け | 任意（デフォルト:カジュアル） |
| アプリアイコン画像パス | ./assets/icon.png | 任意（バナー生成に使用） |
| ブランドカラー | #4A90D9 など | 任意（未指定ならテンプレート既定色） |
| ストア掲載URL | App StoreリンクURL | 任意（投稿文に含める場合） |
| ハッシュタグ方針 | 固定タグ有無、個数目安 | 任意 |

*ここが埋まっていない場合、スキルはデフォルト値で仮生成し、後から差し替え可能な形にする（毎回すべて聞くとUXが悪いため）。*

---

## 7. 動作フロー（想定シーケンス）

```
1. ユーザー: 「KashiKariのリリース告知素材作って」
2. Claude Code: 上記インプット項目のうち未確定分を質問（最小限に絞る）
3. 投稿文生成
   - Instagram用（最大2,200字目安、絵文字・改行多め、ハッシュタグ末尾）
   - Threads用（500字制限、テンポの良い短文、ハッシュタグ控えめ）
   - それぞれ2〜3案ずつ提示
4. バナー画像生成
   - templates/banner_template.html にアプリ名・キャッチコピー・アイコンを差し込み
   - Playwright等でスクリーンショットを撮ってPNG化 → release-assets配下に保存
5. コンセプト画像生成（必要な場合のみ）
   - codex exec 経由でOpenAI Image-2を呼び出し、イメージビジュアルを生成
   - プロンプトはユーザーの訴求ポイント・トンマナから自動組み立て
6. 生成物一式のパスを提示し、ユーザーがレビュー・選択
7. （このスキルの範囲外）選ばれた投稿文・画像を使って、別途Instagram/Threads投稿スキルで公開
```

---

## 8. SKILL.md 設計方針（Claude Codeへの実装依頼内容）

以下の要素を満たす形でSKILL.mdを構築してほしい。

```yaml
---
name: app-release-promo
description: >
  自作アプリのリリース告知用に、SNS投稿文（Instagram/Threads）・告知バナー画像・
  コンセプト画像を生成する。トリガー: リリース告知、SNS投稿文作って、
  告知バナー作って、リリース素材作って
allowed-tools: Bash(codex:*) Bash(mkdir:*) Bash(ls:*) Bash(pwd:*) Read Write
---
```

本文には以下を含める：
- インプット項目のヒアリング手順（セクション6を反映、聞きすぎない設計）
- 投稿文生成のトンマナ別テンプレート（カジュアル/落ち着いた等）
- Instagram/Threadsそれぞれの文字数・慣習上の注意点
  - Instagram: キャプション上限は長め、ハッシュタグは末尾にまとめる慣習
  - Threads: 500字制限、ハッシュタグは控えめ、会話的なトーンが伸びやすい
- banner_template.htmlへの差し込み〜PNG化までの具体的コマンド
- codex exec呼び出し時のプロンプト組み立てルール（訴求ポイント→ビジュアル要素への変換方針）
- 出力先ディレクトリ命名規則（`./release-assets/{app_name}/{date}/`）
- エラー時の代表的なトラブルシューティング（`~/.codex`権限エラーなど）

---

## 9. 非対象・注意事項（Claude Codeへの申し送り）

- 本スキルは**画像の生成・投稿文の生成まで**が範囲。Instagram/Threadsへの**実投稿（API呼び出し）は別スキルとして切り出す**（連携方法は今後別途設計）
- 実機スクリーンショットの自動取得は今回のスコープ外（手動配置した画像をテンプレートに組み込むだけ）
- App Store Connect関連のメタデータ生成はPhase 2として別スキルにする想定（本スキルの拡張ポイントとして設計だけ意識しておく）
- Codex CLI呼び出しはChatGPTアカウント認証前提。API keyベースの運用に切り替えたくなった場合は`scripts/gen_concept_image.sh`内の呼び出し部分だけ差し替えられるよう疎結合にしておく

---

## 10. Claude Codeへの依頼サマリ

> 上記1〜9を踏まえて、`~/.claude/skills/app-release-promo/` 配下にSKILL.mdと付随スクリプト一式を実装してください。まずはセクション4の環境構築手順が通ることを確認したうえで、セクション7の動作フローを満たす最小構成から着手し、動作確認後にテンプレートやプロンプトの精度を詰めていく進め方を想定しています。