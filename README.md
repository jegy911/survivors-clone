# Ironfall

Godot 4 ile geliştirilen bir hayatta kalma / vampire survivors tarzı proje.

## Çalıştırma

1. [Godot 4.6](https://godotengine.org/) (veya `project.godot` içindeki `config/features` ile uyumlu sürüm) kurulu olsun.
2. Projeyi Godot’ta **Import / Open** ile aç.
3. **F5** (Play) veya Editor’dan ana sahneyi çalıştır — önce kısa **açılış ekranı** (arka plan ~5 sn içinde aydınlanır; 4–6. sn arası “devam…” metni alttan kayar (konum `ui/intro_splash.gd` içindeki `PROMPT_*` sabitleri); ardından tuş/tık), sonra ana menü.

## Koşu modları (`SaveManager.settings["run_variant"]`)

Harita seçiminde (`ui/map_select.tscn` → `map_select.gd`) üç mod vardır; süre hedefi `SaveManager.get_run_goal_sec()` ile gelir:

| Mod | Süre hedefi (yaklaşık) | Not |
|-----|-------------------------|-----|
| **story** | ~30 dk | Klasik koşu; Reaper öncesi hedef süre. |
| **fast** | ~14 dk | Sıkıştırılmış dalga/boss ölçeği. |
| **arena** | ~10 dk (`ARENA_RUN_GOAL_SEC` = 600) | Aynı **vs_map** üzerinde kısa maç; hedef süreye ulaşıp koşuyu **kazanmış** saymak için oyun sonu istatistiğinde `won` kullanılır. **Alacakaranlık Hançeri** (`dusk_striker`) açılışı: bu modda en az bir kez kazanırken kadroda **Gölge Yürüyücü** (`shadow_walker`) olmalı; kayıt bayrağı `arena_cleared_as_shadow_walker` (`save_manager.gd`). |

Yeni taban silah **ikiz hançer** (`dagger`): `weapons/weapon_dagger.gd`, `weapons/scenes/weapon_dagger.tscn`, `projectiles/dagger.tscn`; level-up havuzları `player.gd` / `upgrade_ui.gd` ile senkron.

## Dokümantasyon

İçerik veya mimari değişikliklerinde **`docs/GELISTIRICI_REHBERI.md`**, **`docs/YOL_HARITASI.md`**, gerekiyorsa **`docs/TASARIM.md`** ve karakter rolü / sınıfı değiştiyse **`docs/KARAKTER_SINIFLARI_VE_TASARIM.md`** ile **erişilebilirlik matrisini** güncel tutmayı unutmayın (ayrıntı: `.cursor/rules/ironfall-docs.mdc`).

| Dosya | İçerik |
|--------|--------|
| [docs/GELISTIRICI_REHBERI.md](docs/GELISTIRICI_REHBERI.md) | Mimari, autoload’lar, yerelleştirme, checklist’ler |
| [docs/YOL_HARITASI.md](docs/YOL_HARITASI.md) | Plan, **tamamlanan sistemler özeti**, günlük |
| [docs/TASARIM.md](docs/TASARIM.md) | Görsel / ikon / UI / ses / yayın envanteri (✅/❌) |
| [docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md](docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md) | Erişilebilirlik + bağlılık (20+20), Var/Kısmi/Yok |
| [docs/KARAKTER_SINIFLARI_VE_TASARIM.md](docs/KARAKTER_SINIFLARI_VE_TASARIM.md) | Karakter sınıfları (Controller / Fighter / Mage / Tank), co-op destek vizyonu, kahraman taslak tablosu |
| [docs/YAPILACAKLAR_TOPLU.md](docs/YAPILACAKLAR_TOPLU.md) | Açık işlerin düz listesi; biten satır silinir, kaynak `.md` içinde tiklenir |

**Yerelleştirme:** `locales/tr.json`, `en.json`, `zh_CN.json` — `LocalizationManager` + `LANGUAGE_CATALOG`. Anahtar kontrolü: `python locales/check_locale_parity.py` (referans `en.json`). Yeni diller şimdilik plan aşamasında; tablo `GELISTIRICI_REHBERI.md` içinde.

**Tuşlar:** Ana menü / duraklatmadan **Ayarlar → Kontroller** ile P1 ve P2 hareketi, duraklat ve tam ekran için klavye yeniden atama (`InputRemap`, `user://save.cfg` içinde `input_keyboard_overrides`). Oyun kolu eksen ve tuşları projedeki `InputMap` tanımıyla kalır.

**Performans:** **Ayarlar → Görüntü** içinde **Performans ön ayarı** (Yüksek / Orta / Düşük) — düşman üst sınırı, sürü/kuşatma yoğunluğu ve ağır VFX/partikül davranışını değiştirir (`SaveManager.performance_quality`).

**Ana menü arka planı:** İsteğe bağlı tam ekran görsel — `assets/ui/main_menu_bg.png` (veya `.jpg` / `.webp`). Ayrıntı: `assets/ui/README_MAIN_MENU_BG.txt`.

## Lisans

*(İleride eklenecekse buraya yazın.)*
