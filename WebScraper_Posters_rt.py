# WebScraper_Posters_rt.py
import os
import json
import warnings
from pathlib import Path
from typing import Optional

import requests
import urllib3
from bs4 import BeautifulSoup

from Reviews_Urls import movies          # list[dict]: {"url", "name"}
from utils import normalize_title        # safe filenames / keys

# ── suppress LibreSSL warning ───────────────────────────────────────────
warnings.filterwarnings("ignore",
                        category=urllib3.exceptions.NotOpenSSLWarning)

HEADERS = {"User-Agent": "Mozilla/5.0"}   # pretend we're a browser
POSTER_DIR = Path("Images/posters")       # download target
JSON_DIR   = Path("Jsons")                # new output folder
JSON_PATH  = JSON_DIR / "posters.json"    # mapping output


def get_poster_src(soup: BeautifulSoup) -> Optional[str]:
    """Return the poster <img> source, trying RT first then og:image."""
    tag = soup.find("rt-img", {"data-qa": "sidebar-poster-img"})
    if tag and tag.get("src"):
        return tag["src"]

    og = soup.find("meta", property="og:image")
    return og["content"] if og and og.get("content") else None


def main() -> None:
    # 1️⃣  ensure folders exist
    POSTER_DIR.mkdir(parents=True, exist_ok=True)
    JSON_DIR.mkdir(parents=True, exist_ok=True)

    poster_records: list[dict[str, str]] = []

    for movie in movies:
        print(f"➡️  Processing: {movie['name']}")
        html = requests.get(movie["url"], headers=HEADERS, timeout=20).text
        soup = BeautifulSoup(html, "html.parser")

        img_url = get_poster_src(soup)
        if not img_url:
            print(f"   ✗ Poster not found\n")
            continue

        filename = f"{normalize_title(movie['name'])}.jpg"
        filepath = POSTER_DIR / filename

        img_bytes = requests.get(img_url, headers=HEADERS, timeout=20).content
        filepath.write_bytes(img_bytes)

        try:
            rel_path = filepath.resolve().relative_to(Path.cwd())
        except ValueError:
            rel_path = filepath.resolve()

        print(f"   ✓ Saved → {rel_path}\n")

        poster_records.append(
            {"name": movie["name"], "poster_file": str(filepath)}
        )

    # 3️⃣  dump JSON into Jsons/posters.json
    JSON_PATH.write_text(json.dumps(poster_records, indent=2, ensure_ascii=False),
                         encoding="utf-8")
    print(f"📄 Poster map written → {JSON_PATH}")


if __name__ == "__main__":
    main()
