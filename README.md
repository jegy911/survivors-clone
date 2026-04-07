# Ironfall

Godot 4 ile geliştirilen bir hayatta kalma / vampire survivors tarzı proje.

## Çalıştırma

1. [Godot 4.6](https://godotengine.org/) (veya `project.godot` içindeki `config/features` ile uyumlu sürüm) kurulu olsun.
2. Projeyi Godot’ta **Import / Open** ile aç.
3. **F5** (Play) veya Editor’dan ana sahneyi çalıştır.

## Dokümantasyon

İçerik veya mimari değişikliklerinde **`docs/GELISTIRICI_REHBERI.md`**, **`docs/YOL_HARITASI.md`** ve gerekiyorsa **`docs/TASARIM.md`** ile **erişilebilirlik matrisini** güncel tutmayı unutmayın (ayrıntı: `.cursor/rules/ironfall-docs.mdc`).

| Dosya | İçerik |
|--------|--------|
| [docs/GELISTIRICI_REHBERI.md](docs/GELISTIRICI_REHBERI.md) | Mimari, autoload’lar, yerelleştirme, checklist’ler |
| [docs/YOL_HARITASI.md](docs/YOL_HARITASI.md) | Plan, **tamamlanan sistemler özeti**, günlük |
| [docs/TASARIM.md](docs/TASARIM.md) | Görsel / ikon / UI / ses / yayın envanteri (✅/❌) |
| [docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md](docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md) | Erişilebilirlik + bağlılık (20+20), Var/Kısmi/Yok |

**Yerelleştirme:** `locales/tr.json`, `en.json`, `zh_CN.json` — `LocalizationManager` + `LANGUAGE_CATALOG`. Anahtar kontrolü: `python locales/check_locale_parity.py` (referans `en.json`). Yeni diller şimdilik plan aşamasında; tablo `GELISTIRICI_REHBERI.md` içinde.

## Lisans

*(İleride eklenecekse buraya yazın.)*
