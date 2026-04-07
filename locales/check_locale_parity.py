# -*- coding: utf-8 -*-
"""Tüm locales/*.json dosyalarının düz anahtar kümesini en.json ile karşılaştırır.

Çıkış kodu: 0=tamam, 1=fark var.
Kullanım (repo kökünden): python locales/check_locale_parity.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path


def flatten_keys(obj: object, prefix: str = "") -> set[str]:
	if isinstance(obj, dict):
		out: set[str] = set()
		for k, v in obj.items():
			sub = f"{prefix}.{k}" if prefix else str(k)
			out |= flatten_keys(v, sub)
		return out
	return {prefix}


def main() -> int:
	root = Path(__file__).resolve().parent
	ref_path = root / "en.json"
	if not ref_path.is_file():
		print(f"Referans eksik: {ref_path}", file=sys.stderr)
		return 1
	ref_keys = flatten_keys(json.loads(ref_path.read_text(encoding="utf-8")))

	ok = True
	for p in sorted(root.glob("*.json")):
		if p.name == "en.json":
			continue
		data = json.loads(p.read_text(encoding="utf-8"))
		keys = flatten_keys(data)
		only_loc = sorted(keys - ref_keys)
		only_en = sorted(ref_keys - keys)
		if only_loc or only_en:
			ok = False
			print(f"\n=== {p.name} vs en.json ===", file=sys.stderr)
			if only_loc:
				print("Yalnızca bu dosyada:", file=sys.stderr)
				for k in only_loc:
					print(f"  + {k}", file=sys.stderr)
			if only_en:
				print("Yalnızca en.json'da:", file=sys.stderr)
				for k in only_en:
					print(f"  + {k}", file=sys.stderr)
			print(
				f"Özet: {p.name}={len(keys)} en={len(ref_keys)}",
				file=sys.stderr,
			)

	if ok:
		others = [p.name for p in root.glob("*.json") if p.name != "en.json"]
		print(f"OK: tüm dosyalar en.json ile {len(ref_keys)} ortak anahtarda — {', '.join(others)}")
		return 0
	return 1


if __name__ == "__main__":
	sys.exit(main())
