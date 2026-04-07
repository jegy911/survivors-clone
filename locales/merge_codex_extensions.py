#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""codex_extensions_<lang>.json içeriğini locales/<lang>.json → codex altına ekler."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCES = ROOT / "codex_sources"


def main() -> None:
    for lang in ("en", "tr", "zh_CN"):
        main_path = ROOT / f"{lang}.json"
        ext_path = SOURCES / f"codex_extensions_{lang}.json"
        data = json.loads(main_path.read_text(encoding="utf-8"))
        extra = json.loads(ext_path.read_text(encoding="utf-8"))
        for key, val in extra.items():
            data["codex"][key] = val
        main_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print("merged", lang, list(extra.keys()))


if __name__ == "__main__":
    main()
