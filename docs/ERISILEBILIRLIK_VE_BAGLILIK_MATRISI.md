# Erişilebilirlik ve bağlılık — kod durumu matrisi

Bu belge, **20 + 20 maddenin** Ironfall kod tabanındaki **Var / Kısmi / Yok** durumunu ve kısa **repo notunu** içerir.  
Sanat ve yayın envanteri (✅/❌): **`docs/TASARIM.md`**.

**Son kod kontrolü:** 2026-04-28 (matris #4 — `weapon_binding_circle` glyph halkası `get_player_vfx_opacity`; önceki: `item_speed_charm`, vb.)

---

## Tablo 1 — Erişilebilirlik (20 madde)

| # | Madde | Durum | Repo kontrolü |
|---|--------|-------|---------------|
| 1 | Oto-ateş | **Var** | `weapons/weapon_base.gd` — `_process` içinde timer → `attack()`. |
| 2 | Tek çubuk kontrol | **Kısmi** | Solo: `player.gd` WASD/ok. Local co-op: ikinci giriş haritası gerekir. |
| 3 | Anında restart | **Var** | `ui/game_over.gd` — tekrar oyna, havuz sıfırlama, `character_select`. |
| 4 | Görsel karmaşa (oyuncu efekt opaklığı) | **Var** | `SaveManager.settings["player_vfx_opacity"]` (0–1); `ui/settings.gd` + `pause_menu` kaydırıcı; `player.get_player_vfx_opacity()` — level-up halkası/flash, trail, co-op downed; silah VFX (`weapon_lightning`, `laser`, `death_laser`, `storm`, `toxic_chain`, `frost_nova`, `shadow_storm`, `shadow`, `weapon_aura` halka, `weapon_binding_circle` `glyph.png`, `weapon_citadel_flail` `head.png` alan halkası); `effects/combat_projectile_fx.gd` (yıldırım sprite + zincir çizgisi); `projectiles/bullet`, `hunter_axe` (Sprite2D), `lightning_bolt`, `ice_ball` (donma), `fan_blade_shard`; `item_blood_pool`, `item_speed_charm` ayak-altı (`speed_charm_effect.png`), `item_steam_armor` buhar rengi. |
| 5 | Yüksek kontrast düşman (outline) | **Var** | `SaveManager.settings["enemy_high_contrast_outline"]` (isteğe bağlı; **Ayarlar → Görüntü**); `enemy_base.gd` `_setup_visuals()` → `AnimatedSprite2D` sarı siluet + görünür `ColorRect` düşmanlarda offset; yalnız yeni spawn. |
| 6 | Düşük donanım | **Kısmi** | `SaveManager.settings["performance_quality"]` **Düşük / Orta / Yüksek** (`get_max_enemies_cap`, olay spawn çarpanı, `is_heavy_vfx_enabled` / partikül); **Ayarlar → Görüntü**. Ayrı `ObjectPool`. Resmî benchmark raporu yok. |
| 7 | Manyetik toplama | **Var** | `xp_orb.gd`, `gold_orb.gd`, `player.get_magnet_bonus()`, item magnet. |
| 8 | Kısa oyun döngüsü | **Var** | `SaveManager.settings["run_variant"]` story / fast / **arena** (`is_fast_run()`, `is_arena_run()`, `get_run_goal_sec()` ~1800s / ~840s / **~600s arena**); `map_select` + dalga/boss ölçeklemesi `wave_manager` / `spawn_manager`. |
| 9 | Ekran sarsıntısı kapatma | **Var** | `settings["screen_shake"]`, `player.gd` / `EventBus`. |
| 10 | Hasar sayılarını gizleme | **Var** | `damage_numbers` enum; `settings.gd` + `enemy_base` / `player`. |
| 11 | Öğretici / güvenli ilk saniyeler | **Kısmi** | Ayrı tutorial sahnesi yok; dalga doğrudan başlıyor. |
| 12 | Otomatik duraklatma (odak kaybı) | **Var** | `main/main.gd` `get_window().focus_exited` → `pause_menu` + `get_tree().paused`; `SaveManager.settings["pause_on_focus_loss"]` (isteğe bağlı, varsayılan açık; **Ayarlar → Oynanış**); `pause_menu_overlay`; yalnız koşu sahnesi. |
| 13 | Renk körlüğü paleti | **Kısmi** | `SaveManager.settings["colorblind_palette"]` (`none` / `friendly`); **Ayarlar → Görüntü**; XP orb rengi `filter_accessibility_orb_color()` (`enemy_base` drop). Tam UI tema paleti yok. |
| 14 | Büyük net ikonlar (level-up) | **Kısmi** | `upgrade_ui.gd`: üç sütunlu panel, dikey kartlarda Unicode/emoji ikonlar + envanter `tooltip_text`; ayrı büyük sprite ikon asset’i yok. |
| 15 | Görsel patlama ön uyarısı (exploder) | **Var** | Yakınlık ~95 px içindeyken `AnimatedSprite2D.modulate` nabız; patlamada sıfırlanır; `flash()` taban sınıf (vuruş geri bildirimi). |
| 16 | Metin boyutu (global ölçek) | **Kısmi** | `SaveManager.settings["ui_scale"]` (kayıt + **Ayarlar → Görüntü** kaydırıcı); `map_select`, `shop_menu`, `upgrade_ui` (dış `MarginContainer` kenar boşlukları) ve benzeri ekranlarda `get_ui_scale()`. Tüm menü/HUD’da zorunlu uygulama yok. |
| 17 | Pencere / tam ekran | **Var** | `settings.gd` + `SaveManager.apply_window_mode_from_settings()`; `project.godot` `toggle_fullscreen` (F11); `load_game` sonunda pencere modu uygulanır. |
| 18 | Fare veya klavye (hibrit hareket) | **Kısmi** | Fare ile hareket yok; **Ayarlar → Kontroller** ile P1/P2 yön, duraklat, tam ekran için klavye yeniden eşleme (`InputRemap`, `input_keyboard_overrides`); oyun kolu eksen/tuşları projede kaldı. |
| 19 | Lore’u zorlamama / ayrı sekme | **Kısmi** | Uzun lore ekranı yok; ayrı hikaye sekmesi yok. |
| 20 | Çevrimdışı çalışma | **Var** | `user://save.cfg`; liderlik tablosu yok. |

### Çoklu dil (çapraz — erişilebilirlik)

Arayüz dili **`LocalizationManager`** + `locales/tr.json`, `en.json`, `zh_CN.json` (`LANGUAGE_CATALOG`, Ayarlar → Dil). **Run içi (`tr()`):** `main/main.gd` HUD **dalga sayacı** (`ui.hud.wave_counter`), immunity / co-op satırları (`ui.alerts.immunity_rotation`, `ui.game.level_format` / `kill_format`); `main/wave_manager.gd` **dalga ödülü** (`ui.wave_reward.*`) + yüzen uyarılar (`ui.alerts.*`); `main/spawn_manager.gd` olay uyarıları (`ui.alerts.*`); `ui/upgrade_ui.gd` **kabuk** (`ui.upgrade_ui.*`). Menü, ayarlar, duraklatma, kodeks, karakter seçimi (ipucu + butonlar `ui.character_select.*`), oyun sonu, meta upgrade vb. anahtarlanmıştır. **Not (2026-04-16):** Yukarıdaki run içi yüzen metinler ui.alerts.* ile anahtarlandı; yeni metinler rutinde en.json only.

---

## Tablo 2 — Bağlılık / dopamin döngüsü (20 madde)

| # | Madde | Durum | Repo kontrolü |
|---|--------|-------|---------------|
| 1 | Kalıcı geliştirmeler | **Var** | `SaveManager.meta_upgrades`, `ui/meta_upgrade.gd`. |
| 2 | Power fantasy | **Var** | Silah level + evrim + meta. |
| 3 | Slot makinesi (level-up) | **Var** | `upgrade_ui.gd`, `weighted_pick`, level-up flash `player.gd`. |
| 4 | Silah evrimleri | **Var** | `weapon_evolution.gd`, `player.evolve_weapon()`. |
| 5 | Hızlı erken level | **Var** | `player.gd` `_calc_xp_for_level` + `LEVEL_XP_REQUIREMENT_MULT`, `RUN_XP_GAIN_MULT`, dalga XP ödülü (`wave_manager`); taban `EnemyBase.XP_DROP_CHANCE`. *(Denge: seviye hızı yavaşlatılabilir — sabitler `player.gd` / `enemy_base.gd`.)* |
| 6 | Kilidi açılır karakter | **Var** | `character_data.gd`, `save_manager`, sahneler. |
| 7 | Görsel juiciness | **Var** | `hit_stop`, damage numbers, orb drop, `show_vfx` dalları. |
| 8 | Tatmin edici ses (XP pitch) | **Var** | `audio_manager.gd` `play_xp()` — ardışık toplamada `xp_streak` ile pitch artışı + daha uzun sıfırlama. |
| 9 | Sandık heyecanı | **Var** | `effects/chest.gd` — kısa tween açılış animasyonu, ardından ödül. |
| 10 | Beklenmedik boss | **Var** | `wave_manager.gd` `mini_boss_times`. |
| 11 | Koleksiyon / bestiary | **Var** | `core/collection_data.gd`, `SaveManager.codex_discovered`, ölümde `register_codex_discovered` (`enemy_base`, `boss`); `ui/collection_menu.tscn`; ana menü; `locales` `codex.*`. |
| 12 | Sayılar büyür (oyun sonu) | **Var** | `game_over.gd`. |
| 13 | Zorluk kademeleri (run başı) | **Var** | `run_curse_tier` 0–`RUN_CURSE_TIER_MAX`, varsayılan **1**; referans `RUN_CURSE_REFERENCE_TIER` (**1**), `run_curse_tier_delta()` = tier − ref; `map_select` + `run_curse_stat_bar`; spawn **÷(1+RUN_CURSE_SPAWN_PER_TIER×delta)**; düşman HP/hız **×(1+RUN_CURSE_ENEMY_*×delta)** (`get_run_curse_enemy_*_mult`); XP dilimi **RUN_CURSE_XP_GAIN_PER_TIER×delta**; ilk **60 s** dalga düşmanı **1 HP**; dakika 1+ ek **MOB_GLOBAL_*** (`get_global_mob_*_mult`); sürüde `swarm_speed_override` lanet + global hız; mini boss / Reaper koşu laneti katmanı (**2026-04-23**). |
| 14 | Risk / ödül | **Var** | `shrine_of_risk.gd`, shrine XP çarpanı. |
| 15 | Çevre değişimi (zamanla renk/tempo) | **Yok** | Zamanla global renk/müzik tempo değişimi yok. |
| 16 | Gizli kilitler | **Var** | `AchievementManager`, Omega kodu `main_menu`, `character_data` unlock. |
| 17 | Kombo / katliam UI | **Var** | `player.gd` `recent_kill_times`, COMBO metni. |
| 18 | Farklı harita geometrileri | **Kısmi** | `map_select` çoğunlukla tek aktif harita (`vs_map`); **arena** modu aynı haritada kısa süre hedefiyle oynanır, ayrı arena geometrisi yok. |
| 19 | Kozmetik ödüller | **Kısmi** | Ana menü → **`ui/shop_menu`** iskelet (kozmetik / pet / fragman sekmeleri, placeholder); satın alma / unlock yok. |
| 20 | Net final / hedef süre | **Kısmi** | Hedef süre `get_run_goal_sec()` (story ~1800s, fast ~840s) + HUD; 20. dk tek fazlı ayrı final boss yok. |

---

## Özet sayım

| Kategori | Var | Kısmi | Yok |
|----------|-----|-------|-----|
| Erişilebilirlik (20) | 12 | 8 | 0 |
| Bağlılık (20) | 16 | 3 | 1 |

---

## Ne zaman güncelle?

Kod bir maddeyi karşıladığında veya kapsam değiştiğinde ilgili satırın **Durum** ve **Repo kontrolü** sütunlarını güncelle. Aynı madde **`docs/TASARIM.md`** içinde de listeleniyorsa oradaki işareti senkron tut.
