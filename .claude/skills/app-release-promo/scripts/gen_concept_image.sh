#!/usr/bin/env bash
# Codex CLI (ChatGPTログイン認証) 経由でコンセプト画像を生成するラッパー。
#
# API keyベースの運用に切り替えたい場合は、このファイル内の `codex exec` 呼び出し部分だけを
# 差し替えれば良いように、呼び出しをこの1ファイルに閉じ込めている。
#
# 使い方:
#   ./gen_concept_image.sh "<画像生成プロンプト>" <出力先PNGパス>
#
# 例:
#   ./gen_concept_image.sh "友達同士でお金を貸し借りする様子を描いたフラットデザインのイラスト..." \
#       ./release-assets/KashiKari/2026-07-21/concept_image.png

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "使い方: $0 <プロンプト> <出力先PNGパス>" >&2
  exit 1
fi

PROMPT="$1"
OUTPUT_PATH="$2"
OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"
OUTPUT_NAME="$(basename "$OUTPUT_PATH")"

mkdir -p "$OUTPUT_DIR"

if ! command -v codex >/dev/null 2>&1; then
  echo "エラー: codex コマンドが見つかりません。" >&2
  echo "  npm i -g @openai/codex  でインストールし、 codex login  でログインしてください。" >&2
  exit 1
fi

if ! codex login status >/dev/null 2>&1; then
  echo "エラー: Codex CLIがChatGPTアカウントでログインされていません。" >&2
  echo "  codex login  を実行してください。" >&2
  echo "  権限エラー(Operation not permitted)が出る場合は: sudo chown -R \$(whoami) ~/.codex" >&2
  exit 1
fi

codex exec -C "$OUTPUT_DIR" -s workspace-write --skip-git-repo-check \
  "以下の内容で画像を1枚生成し、./${OUTPUT_NAME} に保存して。既存ファイルがあれば上書きしてよい。

${PROMPT}"

if [ -f "$OUTPUT_PATH" ]; then
  echo "保存しました: $OUTPUT_PATH"
else
  echo "警告: 期待した出力パスに画像が見つかりません: $OUTPUT_PATH" >&2
  echo "codexの出力ログを確認し、実際の保存先からこのパスへコピーしてください。" >&2
  exit 1
fi
