#!/usr/bin/env python3
"""
banner_template.html にプレースホルダーを差し込んで出来上がった「完成済みHTMLファイル」を
スクリーンショットしてPNGとして保存する。

テンプレートへの値の差し込み（{{APP_NAME}} 等の置換）はこのスクリプトの責務ではない。
呼び出し側（Claude）が templates/banner_template.html を読み込み、プレースホルダーを
実際の値に置き換えたHTMLを一時ファイルとして書き出し、そのパスをこのスクリプトに渡す。

使い方:
    python render_banner.py --html /path/to/filled_banner.html --output /path/to/banner.png \
        [--width 1200] [--height 630]
"""
import argparse
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="HTMLファイルをスクリーンショットしてPNG化する")
    parser.add_argument("--html", required=True, help="差し込み済みのHTMLファイルパス")
    parser.add_argument("--output", required=True, help="出力PNGファイルパス")
    parser.add_argument("--width", type=int, default=1200, help="ビューポート幅(px)")
    parser.add_argument("--height", type=int, default=630, help="ビューポート高さ(px)")
    args = parser.parse_args()

    html_path = Path(args.html).resolve()
    output_path = Path(args.output).resolve()

    if not html_path.exists():
        print(f"エラー: HTMLファイルが見つかりません: {html_path}", file=sys.stderr)
        return 1

    output_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print(
            "エラー: playwrightがインストールされていません。\n"
            "このスキル専用の仮想環境を使ってください:\n"
            "  <skill_dir>/.venv/bin/python render_banner.py ...",
            file=sys.stderr,
        )
        return 1

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={"width": args.width, "height": args.height})
        page.goto(html_path.as_uri())
        page.screenshot(path=str(output_path))
        browser.close()

    print(f"保存しました: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
