# Erişilebilirlik ve bağlılık — kod durumu matrisi

Bu belge, **20 + 20 maddenin** Ironfall kod tabanındaki **Var / Kısmi / Yok** durumunu ve kısa **repo notunu** içerir.  
Sanat ve yayın envanteri (✅/❌): **`docs/TASARIM.md`**.

**Son kod kontrolü:** 2026-04-07 (güncelleme: kodeks / koleksiyon menüsü)

---

## Tablo 1 — Erişilebilirlik (20 madde)

| # | Madde | Durum | Repo kontrolü |
|---|--------|-------|---------------|
| 1 | Oto-ateş | **Var** | `weapons/weapon_base.gd` — `_process` içinde timer → `attack()`. |
| 2 | Tek çubuk kontrol | **Kısmi** | Solo: `player.gd` WASD/ok. Local co-op: ikinci giriş haritası gerekir. |
| 3 | Anında restart | **Var** | `ui/game_over.gd` — tekrar oyna, havuz sıfırlama, `character_select`. |
| 4 | Görsel karmaşa (oyuncu efekt opaklığı) | **Var** | `SaveManager.settings["player_vfx_opacity"]` (0–1); `ui/settings.gd` + `pause_menu` kaydırıcı; `player.get_player_vfx_opacity()` — level-up halkası/flash, trail, co-op downed; silah VFX (`weapon_lightning`, `laser`, `death_laser`, `storm`, `toxic_chain`, `frost_nova`, `shadow_storm`, `shadow`); `projectiles/bullet`, `boomerang`, `ice_ball` (donma), `fan_blade_shard`; `item_blood_pool`, `item_steam_armor` buhar rengi. |
| 5 | Yüksek kontrast düşman (outline) | **Yok** | `enemy_base.gd` `_setup_visuals()` uygun; shader atanmadı. |
| 6 | Düşük donanım | **Kısmi** | `ObjectPool` vb.; tam performans raporu yok. |
| 7 | Manyetik toplama | **Var** | `xp_orb.gd`, `gold_orb.gd`, `player.get_magnet_bonus()`, item magnet. |
| 8 | Kısa oyun döngüsü | **Kısmi** | ~30 dk hayatta kalma / Reaper (`wave_manager` 1800s). Kısa run için ayrı mod gerekir. |
| 9 | Ekran sarsıntısı kapatma | **Var** | `settings["screen_shake"]`, `player.gd` / `EventBus`. |
| 10 | Hasar sayılarını gizleme | **Var** | `damage_numbers` enum; `settings.gd` + `enemy_base` / `player`. |
| 11 | Öğretici / güvenli ilk saniyeler | **Kısmi** | Ayrı tutorial sahnesi yok; dalga doğrudan başlıyor. |
| 12 | Otomatik duraklatma (odak kaybı) | **Yok** | `NOTIFICATION_APPLICATION_FOCUS_OUT` ile pause yok. |
| 13 | Renk körlüğü paleti | **Yok** | Tema/palet sistemi yok. |
| 14 | Büyük net ikonlar (level-up) | **Yok** | `upgrade_ui` ağırlıklı metin; ikon asset yok. |
| 15 | Görsel patlama ön uyarısı (exploder) | **Kısmi** | Anında patlama + parçacık; `flash()` boş — ön uyarı blink yok. |
| 16 | Metin boyutu (global ölçek) | **Yok** | Global font ölçeği yok. *(Çoklu arayüz dili: `LocalizationManager`, `locales` — `tr`/`en`/`zh_CN`; bu satır yalnızca font ölçeğini kapsar.)* |
| 17 | Pencere / tam ekran | **Kısmi** | `settings.gd` tam ekran + çözünürlük; isteğe bağlı global F11 `project.godot`’ta doğrulanmalı. |
| 18 | Fare veya klavye (hibrit hareket) | **Yok** | `player.gd` klavye/joypad; fare pozisyonuna göre hareket yok. |
| 19 | Lore’u zorlamama / ayrı sekme | **Kısmi** | Uzun lore ekranı yok; ayrı hikaye sekmesi yok. |
| 20 | Çevrimdışı çalışma | **Var** | `user://save.cfg`; liderlik tablosu yok. |

---

## Tablo 2 — Bağlılık / dopamin döngüsü (20 madde)

| # | Madde | Durum | Repo kontrolü |
|---|--------|-------|---------------|
| 1 | Kalıcı geliştirmeler | **Var** | `SaveManager.meta_upgrades`, `ui/meta_upgrade.gd`. |
| 2 | Power fantasy | **Var** | Silah level + evrim + meta. |
| 3 | Slot makinesi (level-up) | **Var** | `upgrade_ui.gd`, `weighted_pick`, level-up flash `player.gd`. |
| 4 | Silah evrimleri | **Var** | `weapon_evolution.gd`, `player.evolve_weapon()`. |
| 5 | Hızlı erken level | **Kısmi** | Tek XP eğrisi; ilk seviyeler özellikle hızlandırılmadı. |
| 6 | Kilidi açılır karakter | **Var** | `character_data.gd`, `save_manager`, sahneler. |
| 7 | Görsel juiciness | **Var** | `hit_stop`, damage numbers, orb drop, `show_vfx` dalları. |
| 8 | Tatmin edici ses (XP pitch) | **Kısmi** | `audio_manager.gd` `play_xp()` — pentatonik sıra var; streak bazlı sürekli yükselen pitch yok. |
| 9 | Sandık heyecanı | **Kısmi** | `effects/chest.gd` anında ödül; özel açılış animasyonu yok. |
| 10 | Beklenmedik boss | **Var** | `wave_manager.gd` `mini_boss_times`. |
| 11 | Koleksiyon / bestiary | **Var** | `core/collection_data.gd`, `SaveManager.codex_discovered`, ölümde `register_codex_discovered` (`enemy_base`, `boss`); `ui/collection_menu.tscn`; ana menü; `locales` `codex.*`. |
| 12 | Sayılar büyür (oyun sonu) | **Var** | `game_over.gd`. |
| 13 | Zorluk kademeleri (run başı) | **Kısmi** | `curse_level` meta; run başı 0–5 seçim ekranı yok. |
| 14 | Risk / ödül | **Var** | `shrine_of_risk.gd`, shrine XP çarpanı. |
| 15 | Çevre değişimi (zamanla renk/tempo) | **Yok** | Zamanla global renk/müzik tempo değişimi yok. |
| 16 | Gizli kilitler | **Var** | `AchievementManager`, Omega kodu `main_menu`, `character_data` unlock. |
| 17 | Kombo / katliam UI | **Var** | `player.gd` `recent_kill_times`, COMBO metni. |
| 18 | Farklı harita geometrileri | **Kısmi** | `map_select` çoğunlukla tek aktif harita; arena kilitli. |
| 19 | Kozmetik ödüller | **Yok** | Kozmetik unlock yok. |
| 20 | Net final / hedef süre | **Kısmi** | 30. dk Reaper (`1800` s); 20. dk tek fazlı final boss yok. |

---

## Özet sayım

| Kategori | Var | Kısmi | Yok |
|----------|-----|-------|-----|
| Erişilebilirlik (20) | 7 | 7 | 6 |
| Bağlılık (20) | 12 | 6 | 2 |

---

## Ne zaman güncelle?

Kod bir maddeyi karşıladığında veya kapsam değiştiğinde ilgili satırın **Durum** ve **Repo kontrolü** sütunlarını güncelle. Aynı madde **`docs/TASARIM.md`** içinde de listeleniyorsa oradaki işareti senkron tut.
