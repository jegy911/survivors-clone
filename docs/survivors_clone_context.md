# Ironfall — bağlam özeti (repo / AI / yeni geliştirici)

Bu dosya **kısa giriş** içindir: proje adı, çalışma kökü, Godot akışı ve autoload’lar. Ayrıntılı mimari, checklist’ler ve dosya yolları → **`docs/GELISTIRICI_REHBERI.md`**. Plan ve günlük → **`docs/YOL_HARITASI.md`**.

**Not:** Depo klasör adı tarihsel olarak `survivors-clone` olabilir; ürün ve `project.godot` uygulama adı **Ironfall**’dır.

---

## Teknik özet

| Öğe | Değer |
|-----|--------|
| Motor | Godot **4.6** (`project.godot` → `config/features`) |
| Ana giriş sahnesi | `res://ui/intro_splash.tscn` → ana menü → karakter / harita seçimi → `res://main/main.tscn` |
| Dil | GDScript; string **içerik kimlikleri** (`"warrior"`, `"fan_blade"`) birden fazla dosyada tutarlı tutulmalı |

---

## Autoload’lar (`project.godot` → `[autoload]`)

Yükleme sırası editörde tanımlıdır; `SaveManager` ve `InputRemap` / `LocalizationManager` erken gelir.

| Ad | Rol (tek cümle) |
|----|------------------|
| **SaveManager** | Kalıcı kayıt (`user://save.cfg`), altın, meta upgrade, ayarlar, kilitler, arena bayrakları, hesap seviyesi / XP. |
| **InputRemap** | Klavye yeniden atama; `user://save.cfg` içinde `input_keyboard_overrides`. |
| **LocalizationManager** | `LANGUAGE_CATALOG` + `locales/*.json`, `locale_changed`. |
| **AudioManager** | Müzik döngüsü + SFX; `docs/sesler-muzikler-efektler.md`. |
| **ObjectPool** | Mermi, orb, damage number vb. için havuz; havuzdaki `Area2D` için çarpışma sıfırlama + `init()` ile geri yükleme — ayrıntı `docs/GELISTIRICI_REHBERI.md` §4 «Projectile + ObjectPool». |
| **EnemyRegistry** | Canlı düşman listesi; `get_nodes_in_group("enemies")` yükünü azaltmak için. |
| **EventBus** | Oyun içi sinyal merkezi. |
| **AchievementManager** | Başarı takibi. |

---

## Önemli dizinler

| Yol | İçerik |
|-----|--------|
| `main/` | Oyun döngüsü, spawn, dalga, ortam. |
| `player/` | Oyuncu gövdesi, level-up, loadout mantığı (`player.gd` büyük; yardımcılar ayrı dosyalarda). Koşu HUD envanteri: `PlayerUiHelpers.rebuild_run_loadout_hud` → `CanvasLayer/CategoryPanel` (silah/eşya ikonları + `LVL`, `UpgradeIconCatalog`). |
| `weapons/`, `projectiles/` | Silah scriptleri / şablon sahneler; dünya vuruşu sahneleri. |
| `core/` | `SaveManager`, `CharacterData`, `GameplayConstants`, `PlayerLoadoutRegistry`, `EnemyRegistry`, … |
| `ui/` | Menüler, level-up, ayarlar, game over. |
| `locales/` | `en.json` (rutin yeni metin), `tr.json`, `zh_CN.json`; parity: `locales/check_locale_parity.py`. |

---

## Sonraki okuma sırası

1. `docs/GELISTIRICI_REHBERI.md` §1–2 — genel akış + autoload detayı.  
2. `README.md` — çalıştırma, `run_variant`, doküman tablosu.  
3. `docs/YOL_HARITASI.md` — audit (P0–P4) ve yapılacaklar.  
4. `.cursor/rules/ironfall-docs.mdc` — dokümantasyon güncelleme disiplini.
