---
name: app-release-promo
description: >
  自作アプリのリリース告知用に、SNS投稿文（Instagram/Threads）・告知バナー画像・
  コンセプト画像を生成する。個人開発アプリのリリースやアップデート、機能追加を告知したい時に使う。
  トリガー: リリース告知、SNS投稿文作って、告知バナー作って、リリース素材作って、
  アプリの宣伝素材、Instagram/Threadsの投稿文、アプリアイコンでバナー作りたい、といった依頼があれば
  ユーザーが明示的に「スキルを使って」と言っていなくても積極的にこのスキルを使うこと。
allowed-tools: Bash(codex:*) Bash(mkdir:*) Bash(ls:*) Bash(pwd:*) Bash(cp:*) Read Write
---

# app-release-promo

個人開発アプリのリリース告知素材（SNS投稿文・バナー画像・コンセプト画像）を一式生成するスキル。
人間は「選ぶ・微調整する」だけで済む状態まで初稿を仕上げるのが目的。

## スコープ

生成するのは次の3点のみ。

1. **SNS投稿文** — Instagram用・Threads用、それぞれ2〜3案
2. **告知バナー画像** — アプリアイコン＋キャッチコピーのテンプレートベース画像（コード生成、PNG化）
3. **コンセプト画像** — Codex CLI（ChatGPTログイン認証）経由のAI画像生成（必要な場合のみ）

実機スクリーンショットの自動取得や、Instagram/Threadsへの実投稿（API呼び出し）はこのスキルの範囲外。
App Store Connect向けメタデータ生成（説明文・キーワード等）も対象外（将来のPhase 2）。

## 進め方

### 1. 前提環境の確認

以下が揃っているか確認し、揃っていなければユーザーに知らせてから進める（このスキル自体のインストール時に
セットアップ済みのはずだが、別マシンや初回実行時は未整備の可能性がある）。

```bash
codex login status   # "Logged in using ChatGPT" が出ればOK
```

出ない場合は次を案内する:

```bash
npm i -g @openai/codex
codex login
```

`Failed to create session: Operation not permitted` のようなエラーが出た場合:

```bash
sudo chown -R $(whoami) ~/.codex
```

バナー画像生成にはこのスキル同梱の仮想環境（`<skill_dir>/.venv`）にPlaywrightを導入済み。
`render_banner.py` は自動的にこの仮想環境のPythonで実行すること（後述）。もし `.venv` が存在しない場合は
以下でセットアップする。

```bash
cd <skill_dir>
python3 -m venv .venv
./.venv/bin/pip install playwright
./.venv/bin/python -m playwright install chromium
```

### 2. インプットのヒアリング（聞きすぎない）

以下のうち、会話やプロジェクトのコンテキスト（README、package.json、Info.plist等）から拾えないものだけを
まとめて1回で質問する。必須項目が全て揃うまで何度も聞き返さない。

| 項目 | 必須/任意 | 備考 |
|---|---|---|
| アプリ名 | 必須 | |
| 一言コンセプト | 必須 | |
| リリース種別 | 必須 | 新規リリース / アップデート / 機能追加 |
| 訴求ポイント（3つ程度） | 必須 | |
| トンマナ・文体 | 任意 | 未指定なら「カジュアル」をデフォルトにする |
| アプリアイコン画像パス | 任意 | バナー生成に使う。なければプレースホルダーで代替 |
| ブランドカラー | 任意 | 未指定なら `#4A90D9` をデフォルトにする |
| ストア掲載URL | 任意 | 投稿文に含めるかはユーザーに軽く確認 |
| ハッシュタグ方針 | 任意 | 固定タグの有無・個数目安 |

任意項目が未確定でも止まらず、デフォルト値で仮生成して進める。後から差し替え可能なことをユーザーに伝える。

### 3. 出力先ディレクトリ

```
./release-assets/{app_name}/{yyyy-mm-dd}/
    ├── captions/
    │   ├── instagram.md
    │   └── threads.md
    ├── banner.png
    └── concept_image.png   # 生成した場合のみ
```

`{yyyy-mm-dd}` は実行日。`mkdir -p` で作成してから各成果物を書き込む。

### 4. SNS投稿文の生成

`templates/caption_templates.md` を読み、指定（またはデフォルト）のトンマナに沿って
Instagram用・Threads用をそれぞれ2〜3案作成する。テンプレートは「型」であり、そのまま
コピペで済ませず、訴求ポイント・アプリ名を活かした自然な文章に仕上げること。

- **Instagram**: キャプション上限は長め（実際に読まれるのは冒頭2〜3行）。改行を多めに。
  ハッシュタグは本文末尾にまとめる（目安5〜15個、個数指定があればそれに従う）。
- **Threads**: 500字制限。テンポの良い短文。ハッシュタグは控えめ（0〜3個）。会話的なトーンが伸びやすい。

生成した投稿文は `captions/instagram.md` / `captions/threads.md` に書き出す。

### 5. バナー画像の生成

1. `templates/banner_template.html` を読む。
2. プレースホルダーを実際の値に置換する。
   - `{{APP_NAME}}` → アプリ名
   - `{{CATCHPHRASE}}` → 訴求ポイントから作った短いキャッチコピー（1文、20〜30字目安）
   - `{{BRAND_COLOR}}` → ブランドカラー（未指定時は `#4A90D9`）
   - `{{RELEASE_BADGE}}` → 「NEW RELEASE」「UPDATE」等リリース種別に応じた短い英語/日本語ラベル。
     不要なら `<div class="badge">...</div>` の要素ごと削除してよい。
   - `{{ICON_IMG}}` → アイコンパスが指定されていれば `<img class="icon" src="<絶対パス>">`、
     なければ `<div class="icon-placeholder"></div>`。画像パスは file:// で解決されるよう
     **絶対パス**で埋め込むこと。
3. 置換済みHTMLを出力先ディレクトリ配下の一時ファイル（例: `banner_filled.html`）として保存する。
4. スキル同梱のPlaywright環境でPNG化する。

```bash
<skill_dir>/.venv/bin/python <skill_dir>/scripts/render_banner.py \
  --html ./release-assets/{app_name}/{date}/banner_filled.html \
  --output ./release-assets/{app_name}/{date}/banner.png
```

5. 一時HTMLファイルは残しておいて構わない（再調整の際に便利）。

### 6. コンセプト画像の生成（必要な場合のみ）

ユーザーが「コンセプト画像も」「イメージビジュアルも」のように求めた場合、または訴求ポイントを
視覚的に伝える画像があった方が良いと判断した場合に生成する。不要と言われたら省略してよい。

プロンプト組み立てルール（訴求ポイント→ビジュアル要素への変換）:

- 一言コンセプトを主題（Subject）に変換する（例:「友達同士の貸し借りを記録するアプリ」→
  「2人の人物がスマホを見せ合いながら気軽にやり取りしている場面」）
- 訴求ポイントのうち視覚化しやすいもの（シンプルUI、通知機能など）を構図・小道具のヒントに変換する
- トンマナに応じてスタイルを指定する（カジュアル→明るいフラットイラスト、落ち着いた→
  ミニマルな配色、エンジニア向け→シンプルなアイソメトリック等）
- テキストや文字を画像内に入れない（バナー側でテキストは扱うため、コンセプト画像は視覚のみ）
- ブランドカラーを配色のヒントとして含める

```bash
<skill_dir>/scripts/gen_concept_image.sh \
  "<組み立てたプロンプト>" \
  ./release-assets/{app_name}/{date}/concept_image.png
```

このスクリプトは内部で `codex exec` を呼び出す。ChatGPTログイン認証が前提。API keyベースの運用に
切り替えたくなった場合は、このスクリプト内の呼び出し部分だけを差し替えれば良いよう疎結合にしてある。

### 7. 成果物の提示

全て生成し終えたら、保存したファイルパス一覧をユーザーに提示し、レビュー・選択を促す。
選ばれた投稿文・画像を使ったSNSへの実投稿は、このスキルの範囲外（別スキルで対応）であることを伝える。

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| `codex: command not found` | `npm i -g @openai/codex` |
| `codex login status` が失敗する | `codex login` を実行しブラウザでChatGPT認証 |
| `Failed to create session: Operation not permitted` | `sudo chown -R $(whoami) ~/.codex` |
| `render_banner.py` で `ModuleNotFoundError: playwright` | `<skill_dir>/.venv` を使わず素の `python3` で実行している。`.venv/bin/python` 経由で呼び出す |
| Playwrightのブラウザが見つからないエラー | `<skill_dir>/.venv/bin/python -m playwright install chromium` |
| コンセプト画像が期待したパスに保存されない | `gen_concept_image.sh` のログを確認。codexの応答メッセージに実際の保存先が書かれているのでそこから手動コピーする |

## 拡張ポイント（将来のPhase 2・今回は実装しない）

App Store Connect提出用メタデータ（説明文、キーワード、What's New等）の生成を、同じスキル群の
延長として追加できるように、投稿文生成ロジック（トンマナ別テンプレート）は流用しやすい形にしてある。
