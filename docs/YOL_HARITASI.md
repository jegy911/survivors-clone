# Ironfall — Yol haritası ve yapılacaklar

Bu dosya **ürün / geliştirme planı**dır: öncelikler, tamamlananlar ve ileride eklenecek fikirler burada toplanır.  
*(İngilizce projelerde genelde `ROADMAP.md` adı kullanılır.)*

**Son güncelleme:** 2026-04-16 (level-up üç panel UI + `en` kabuk metinleri; kahraman `.tscn` disiplini; `en`-only locale dondurması)

---

## Proje incelemesi — öncelikli plan (audit)

Aşağıdaki sıra **öneridir**: P0 → hızlı kullanıcı kazanımı; P4 → uzun vadeli bakım. Ayrıntılı teknik borç tablosu yukarıda **«Teknik borç / refaktör ve optimizasyon»** ile çakışan maddeler orada tutulur; burada ürün + kod kokusu genişletilir.

### P0 — Gözle görülür tutarsızlıklar / hızlı düzeltme

| Konu | Not |
|------|-----|
| **Run içi sabit metin** | `main.gd`, `wave_manager.gd` vb. dalga / uyarı / yüzen metinlerde hâlâ Türkçe veya `tr()` dışı string; dil İngilizce olsa da karışık görünür. Matris: `ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md` § çoklu dil. |
| **Karakter seçimi kalan metin** | **Kilit ipucu** (`unlock_hint` `CharacterData`), P2 **«Seç» / «Hazır»**, bazı butonlar kod içi Türkçe — `locales` + anahtar. *(Kart isimleri: `codex.character.*.name` — tamam.)* |
| **Debug çıktıları** | `audio_manager.gd` `print` (SFX bus); `save_manager.gd` `print` — yayın öncesi `OS.is_debug_build()` veya log seviyesine alınmalı. |
| **Mağaza / placeholder** | `shop_menu` sekmeleri placeholder; oyuncu beklentisi yönetimi veya “yakında” metni. |

### P1 — Ürün açıkları (YOL’daki [ ] maddeleriyle örtüşür)

| Konu | Not |
|------|-----|
| **Öğretici** | İlk saniye güveni (matris #11 **Kısmi**); ayrı tutorial sahnesi yok. |
| **Co-op giriş** | İkinci oyuncu giriş haritası **Kısmi** (matris #2). |
| **Evrim + kodeks** | Evrim derinleştirme tablosu `[ ]`; kodekste ayrı **Evrim** sekmesi yok. |
| **Sınıf → oyun** | Kahraman `hero_class` metin olarak var; **oyun dengesine bağlama** `[ ]`. |
| **Bağlam belgesi** | `survivors_clone_context.md` (veya eşdeğeri) yok — yeni geliştirici / AI için özet. |
| **Arena / lore / rehber** | Arena: `map_select` + `run_variant` **arena** ile kısa hedef süre (10 dk) oynanabilir; ayrı harita / dalga savunma paketi hâlâ plan. Lore/rehber uzun vadeli. |

### P2 — Refaktör / tekrarlayan kod / isim borcu

| Konu | Not |
|------|-----|
| **`get_nodes_in_group("player")`** | `main`, `spawn_manager`, `wave_manager`, `environment_manager`, orb’lar, düşmanlar… çok çağrı; co-op ve AI için **tek kaynak** (ör. `main` oyuncu dizisi veya hafif `PlayerRegistry`) düşünülebilir. |
| **`get_nodes_in_group("player_bullets")`** | Birkaç efekt; havuz / layer ile hizalama. |
| **Silah / level-up listeleri** | `upgrade_ui.gd` `WEAPON_UPGRADE_IDS`, `player.gd` `_LEVELUP_WEAPON_IDS`, `collection_data` / kodeks — **yeni silah** eklerken çok dosya; tek veri kaynağı veya doğrulama script’i (teknik borç tablosu). |
| **`boomerang` vs `hunter_axe`** | ID `boomerang`, sahne `hunter_axe.tscn` — isimlendirme borcu; dokümantasyon + olası gelecekte rename. |
| **Sabit 600 px** | `weapon_lightning` + `main` co-op mesafesi — ortak sabit. |
| **`player.gd` boyutu** | 900+ satır; zaten `player_ui_helpers` vb. — mantık bloklarına bölme devam edebilir. |
| **`upgrade_ui.get_upgrade_text`** | Uzun `match`; yeni silah/eşya eklerken unutulma riski — tablo sürücülü veya `codex` fallback. |

### P3 — Optimizasyon (ölçüm sonrası)

| Konu | Not |
|------|-----|
| **Düşman sürüsü** | `EnemyRegistry` tüm liste taraması; yıldırım / zincir menzilinde O(n) her vuruş; sürü 600+ iken profil → **mesafe ızgarası** veya seyrek güncelleme. |
| **ObjectPool** | Havuz boyutları varsayılan; yoğun bolt / mermi için ayar + belge. |
| **Partikül / VFX** | `performance_quality` düşükte kısmen kapatılıyor; ağır sahnelerde sayım tavanı gözden geçirilebilir. |

### P4 — Bakım, kalite, süreç

| Konu | Not |
|------|-----|
| **Commit / asset** | `git status`: takip edilmeyen `assets/projectiles/`, `weapons/scenes/` vb. tek commit’te toplanmalı. |
| **CI** | İsteğe bağlı: Godot `--headless` export veya `check_locale_parity.py` + sahne varlığı script’i. |
| **TODO yok** | Kodda `TODO/FIXME` etiketi yok; yine de yukarıdaki maddeler yol haritası görevi görür. |

---

## 2026-04-14 — Günün değişiklikleri (debug / geri sarma notu)

Bugün toplu dokunuşlar yapıldı; olası regresyonlarda buradan iz sür:

- **Silah sahneleri:** `weapons/scenes/weapon_<id>.tscn` (çoğu silah); `PlayerLoadoutRegistry.create_weapon` sahne önceliği.
- **Balta:** `projectiles/boomerang.gd|.tscn` silindi → `hunter_axe.tscn` / `hunter_axe.gd`; silah ID `boomerang` korundu.
- **Yeni dosyalar:** `effects/combat_projectile_fx.gd`, `lightning_hit_fx.*`, `lightning_bolt.*`, `ObjectPool` ile bolt; `tools/` (ör. `gen_weapon_scenes.py`).
- **Asset:** `assets/projectiles/` (aura, axe, chain, lightning) — commit öncesi `git status` ile `??` kontrol.
- **Aura:** `weapon_aura.gd` ölçek / `super._process`, `aura_outer_*` sabitleri.
- **Zincir:** `weapon_chain` sıralı vuruş + gecikme; VFX önce Line2D TILE, sonra **Sprite2D** segment + `chain.png` (yön + uzunluk); renk / solma / `CHAIN_*` sabitleri `combat_projectile_fx.gd`.
- **Yıldırım:** `weapon_lightning` + `lightning_bolt` (gökten iniş, dikey sprite), `STRIKE_MAX_DIST_FROM_PLAYER` 600, `weapon_lightning.tscn` üst sprite kaldırıldı/gizlendi.
- **Locale / UI:** `ui.player` çift anahtar birleştirme; level-up metinleri; **karakter kartı isimleri** artık `codex.character.<id>.name` (`CharacterSelectHelpers.character_display_name`).
- **Meta / kayıt:** `start_level_bonus` clamp, `SaveManager` normalizasyon; kahraman ID kaydı (`selected_character_id` vb.).
- **Kalan Türkçe sabitler (bilinçli):** `CharacterData` içi `name` / `unlock_hint` (Türkçe veri); seçim ekranında isim düzeltildi, kilit ipucu ve bazı butonlar (`Seç`, `Satın Al`…) hâlâ kod/locale karışık olabilir — ayrı tur.

---

## Son oturum — el sıkışma (2026-04-14)

Bir sonraki oturumda **“kaldığımız yerden devam”** için özet:

| Konu | Durum |
|------|--------|
| **Silah sahneleri** | `PlayerLoadoutRegistry.create_weapon`: önce `weapons/scenes/weapon_<id>.tscn` (25 sahne), yoksa `weapon_*.gd` script düğümü. Mantık `weapons/`, dünya vuruşu `projectiles/` + ObjectPool. |
| **Balta** | `projectiles/boomerang.*` kaldırıldı → **`projectiles/hunter_axe.tscn`** / `hunter_axe.gd`. Kayıtlı silah kimliği hâlâ `boomerang` / `blood_boomerang` (metinler “Balta”). |
| **Asset’ler** | `assets/projectiles/` (aura, axe, chain, lightning). Çalışma ağacında bazıları **henüz commit’lenmemiş** olabilir (`git status` → `??`) — bir commit’te toplanmalı. |
| **Yıldırım** | `lightning_bolt` (ObjectPool): kamera üstünden iniş, sprite **dikey** (`Sprite2D.rotation = 0`), `weapon_lightning.tscn` üzerinde yıldırım ikonu yok; hedef **`STRIKE_MAX_DIST_FROM_PLAYER` = 600 px** (görünür alan hissi; `main.gd` co-op `MAX_PLAYER_DISTANCE` ile aynı tavan fikri). |
| **Zincir** | `CombatProjectileFx.spawn_chain_segment`: `chain.png` ile **Sprite2D** segment (konum ortada, `rotation` segment yönü, `scale.x` = mesafe). |

**Sonraki adım (insan):** Tüm değişiklikleri gözden geçirip `??` dosyaları dâhil **tek veya birkaç anlamlı commit**; aşağıdaki teknik borçlar zorunlu değil.

---

## Teknik borç / refaktör ve optimizasyon

*(Öncelik serbest; bir sonraki seanslarda seç–al.)*

| Alan | Öneri |
|------|--------|
| **600 px tek kaynak** | `weapon_lightning.gd` `STRIKE_MAX_DIST_FROM_PLAYER` ile `main.gd` `MAX_PLAYER_DISTANCE` ortak sabitte (`core/` autoload veya küçük `balance_constants.gd`) birleştirilebilir. |
| **Silah sahnesi sprite politikası** | `weapon_chain.tscn` üstü sprite gizli (zincir VFX segmentte); diğer silahlarda şablon tutarlılığı + `tools/gen_weapon_scenes.py` notu. |
| **Yıldırım bolt hareketi** | Şu an `move_toward(hedef)` ile hafif çapraz iz mümkün; tam dik iniş için hedef X sabitlenip yalnızca Y indirilebilir. |
| **ObjectPool** | `lightning_bolt` havuz boyutu / eşzamanlı vuruş sayısı oynanışa göre ayar; kısa not `GELISTIRICI_REHBERI` veya kod yorumu. |
| **`EnemyRegistry` + menzil** | Tüm liste üzerinden mesafe; sürü çok büyürse profil → ızgara / seyrek güncelleme değerlendirilir. |
| **Doğrulama aracı** | `WEAPON_SCRIPT_BY_ID` anahtarları için eşleşen `weapons/scenes/weapon_<id>.tscn` varlığını kontrol eden küçük script (CI opsiyonel). |
| **Bağlam belgesi** | Aşağıdaki plan tablosunda `[ ]` kalan **`survivors_clone_context.md`** (autoload / akış özeti). |

---

## Bu dosyayı ve geliştirici rehberini nasıl güncellemeliyiz?

| Ne zaman? | Ne yap? |
|-------------|---------|
| Bir plan maddesini **bitirdiğinde** | Aşağıdaki **Yapılan iş günlüğü**ne tarih + kısa açıklama ekle; ilgili tabloda `[x]` yap veya maddeyi sil / “İptal” notu düş. |
| Oyuna **yeni tür içerik** eklediğinde (orb, silah, karakter, vb.) | `docs/GELISTIRICI_REHBERI.md` içinde ilgili checklist veya yeni bölümü güncelle (ör. orb için bölüm 8). |
| `docs/TASARIM.md` kapsamındaki bir madde kod + asset olarak **bittiğinde** | O dosyadaki ilgili satırları güncelle. |
| Bir şeyi **koddan kaldırdığında** | Rehberdeki checklist’lerden ve bu dosyadaki maddelerden kaldır veya “kaldırıldı” diye günlüğe yaz. |
| Repo / çalıştırma **değiştiyse** | `README.md` güncelle. |
| **Erişilebilirlik / bağlılık** satırı kodda değişti | `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md` ilgili satırı güncelle. |

> Cursor kullanıyorsan: `.cursor/rules/ironfall-docs.mdc` bu kuralları otomatik hatırlatır.

---

## Tamamlanan sistemler (özet, 2026-04)

Aşağıdakiler kod + dokümantasyon ile **teslim edilmiş** kabul edilir; ayrıntı günlük satırlarında.

| Alan | Ne var? |
|------|---------|
| **Yerelleştirme** | `LocalizationManager` autoload; `LANGUAGE_CATALOG` + `locales/tr.json`, `en.json`, `zh_CN.json`; Ayarlar → Dil; ilk kurulumda kayıt yoksa OS dili; `internationalization/locale/fallback` `en`; `check_locale_parity.py` (`en.json` referansı). |
| **Kayıt / ayarlar** | `SaveManager.settings` (ses, görüntü, oynanış, `input_keyboard_overrides`, …); `InputRemap` ile kalıcı klavye eşlemesi; geçersiz dil kodu düzeltmesi. |
| **İçerik (örnekler)** | Göçebe (nomad): Yelpaze Bıçak başlangıç; Kor Kalbi koşuda, Kor Yelpazesi evrimi; karakter sırası / `character_order_v2` migrasyonu. |
| **Dokümantasyon disiplini** | `GELISTIRICI_REHBERI`, `YOL_HARITASI`, `TASARIM`, erişilebilirlik matrisi, kök `README`, `.cursor/rules/ironfall-docs.mdc`. |

**Not (dil):** Yeni locale dosyası ekleme işi **şimdilik durduruldu**; sıradaki diller `GELISTIRICI_REHBERI.md` içindeki plan tablosunda listelenir.

---

## Yapılan iş günlüğü (tarihli)

| Tarih | Özet |
|--------|------|
| 2026-04-16 | **Level-up UI sahne ağacı + meta kart + slot metni** — `upgrade_ui.tscn`: `EditorRoot` ile Godot 2D’de düzenlenebilir layout; `upgrade_ui.gd`: `_bind_editor_root` / istat panelinde bu koşu kalan reroll-skip + max slot satırları; `meta_upgrade.tscn` + `meta_upgrade.gd`: ortalı sütun, kartta yalnız `damage_bonus` tam açıklama (diğerleri tooltip), `weapon_slot_bonus` / `item_slot_bonus` meta satırları; `locales/en.json` (yeni anahtarlar; `tr`/`zh_CN` dil turu dışı). |
| 2026-04-17 | **`dusk` başlangıç yükü düzeltmesi** — `CharacterData`: `start_item` boş (yalnız `dagger`); `night_vial` koşuda; `locales/en.json` + `codex_extensions_en` dusk metni; `lore.md` / `KARAKTER_SINIFLARI` / `GELISTIRICI` senkron. |
| 2026-04-14 | **`dusk_striker` kahramanı** — Fighter, başlangıç `dagger` (ikiz hançer, mermiden düşük taban toplam hasar, ~1,28 s CD) + `night_vial` (Gece Şişesi; hafif XP/altın çekim yarıçapı); evrim `veil_daggers` (`dagger` MAX + `night_vial` MAX). Açılış: Arena’da kazanarak ve kadroda `shadow_walker`; **380** altın; oyuncu sahnesi `characters/dusk/dusk.tscn`. **Arena v0:** `ARENA_RUN_GOAL_SEC` 600, `map_select` oynanabilir. |
| 2026-04-16 | **Kahraman sahne disiplini + dil dondurması** — Yeni kahraman: kendi `.tscn`; kopya sahnede `AnimatedSprite2D` animasyon adları kalır, frame’ler boşaltılır (`dusk` uygulandı). Rutin locale: yalnız `en` + `codex_extensions_en`; `tr` / `zh_CN` raf — `GELISTIRICI` + `ironfall-docs.mdc`. |
| 2026-04-16 | **Level-up: aura çöküşü + önizleme + ikon klasörü** — `weapon_aura`: halka `player` yerine silah altında; `upgrade_ui`: yeni silah/eşya önizlemesi kodeks-only (geçici `PassiveItem`/`visible` hatası yok), serseri `AuraWeaponRing` temizliği; `UpgradeIconCatalog` + `assets/ui/upgrade_icons/` README. |
| 2026-04-16 | **Level-up UI (Megabonk tarzı)** — `upgrade_ui.gd` / `upgrade_ui.tscn`: tam ekran üç sütun (`HBoxContainer`), sol envanter ızgarası + `tooltip_text`, orta dikey seçim kartları (silah/eşya/evrim önizlemesi), sağ canlı istatistik + `SaveManager.meta_upgrades` özeti; kabuk metinleri `locales/en.json` `ui.upgrade_ui.*`; `TASARIM` / erişilebilirlik matrisi / `YAPILACAKLAR_TOPLU` senkron. |
| 2026-04-15 | **`YAPILACAKLAR_TOPLU` iş akışı** — Liste = yalnız açık iş; bitince satır sil, kaynakta tik; `[ ]` kaldırıldı; `GELISTIRICI` / `README` / P0 karakter satırı güncellendi. |
| 2026-04-15 | **YAPILACAKLAR_TOPLU.md** — Yedi ana dokümandaki yapılacaklar tek `.md` checklist; `README.md` tablo linki. |
| 2026-04-15 | **Proje incelemesi (audit)** — `YOL_HARITASI.md`: P0–P4 öncelikli plan (locale kalanları, `get_nodes_in_group`, liste tekrarı, perf, bakım). |
| 2026-04-14 | **Karakter seçim isimleri + zincir opaklık** — Kartlarda `CharacterSelectHelpers.character_display_name` → `codex.character.*.name` (dil ayarına uyum); zincir segmenti daha opak (renk, RGB boost, daha uzun solma). |
| 2026-04-14 | **Zincir VFX Sprite2D** — `spawn_chain_segment`: Line2D yerine dönen `chain.png` segmenti (oyuncu→düşman→sıçrama); `weapon_chain.tscn` üstü sprite gizli (yalnız uçuş segmenti). |
| 2026-04-14 | **Dokümantasyon — oturum kapanışı** — `YOL_HARITASI`: «Son oturum — el sıkışma» + «Teknik borç / refaktör» tabloları; `Acil` bölümüne commit/`??` hatırlatması; `GELISTIRICI_REHBERI` §4 oturumlar arası devam bağlantısı. |
| 2026-04-14 | **Yıldırım menzil tavanı** — `weapon_lightning`: yalnızca oyuncudan ≤600 px içindeki düşmanlar hedef (ilk vuruş + zincir sıçraması); ekran dışı görünmez vuruş yok. |
| 2026-04-14 | **Zincir doku + yıldırım görselliği** — `spawn_chain_segment`: Line2D `texture_repeat` ile `chain.png` TILE görünür; `lightning_bolt` spawn kamera üstü + hedefe düşüş (oyuncu→düşman süzülme yok); `weapon_lightning.tscn` yıldırım sprite kaldırıldı. |
| 2026-04-14 | **Başlangıç level + yıldırım bolt + balta sahnesi + zincir** — `start_level_bonus` en fazla +1 net level (Lv2); `lightning_bolt.tscn` / ObjectPool; `boomerang` projeksiyonu `hunter_axe.tscn`; zincir Line2D beyaz × renk + TILE; level-up silah/eşya üst önek kaldırıldı; aura `aura_outer_texel_auto_factor`. |
| 2026-04-14 | **Locale `ui.player` birleştirme + meta clamp** — `en`/`tr`/`zh_CN`: çift `"player"` anahtarı yüzünden `loadout.*` çevirileri eziliyordu (level-up `%` hatası + boş açıklama); `SaveManager._normalize_meta_upgrades` + oyunda `start_level_bonus` üst sınırı 3 (dev max 10 → ilk level-up L12 bug’ı). |
| 2026-04-14 | **Silah sahne şablonu + aura/zincir/yıldırım** — `WeaponBase` → `Area2D`; `weapons/scenes/weapon_*.tscn` (CollisionShape2D + ColorRect + Sprite2D), `create_weapon` sahne önceliği; aura `aura_outer_radius_texels` ile hasar yarıçapına göre ölçek; zincir `chain_step_delay_sec` + Line2D görünürlük; `lightning_hit_fx` editör `texture`/`scale` korunur; `tools/gen_weapon_scenes.py`. |
| 2026-04-14 | **Aura düzeltmesi + projeksiyon + kahraman ID + yıldırım tscn** — Aura `super._process` (tekrar hasar), halka daha parlak; `assets/projectiles/`; `SaveManager.selected_character_id` / `get_character_index_for_player`; `effects/lightning_hit_fx.tscn`; balta isimlendirmesi / `TASARIM` / matris / `SILAHLAR_ESYALAR_EVO` (önceki tur). |
| 2026-04-14 | **Level-up metni + silah sahne ayrımı** — `player.gd` loadout metninde `%` / yüzde çakışması (prefix birleştirme); geçici `weapons/scenes` sarmalayıcıları kaldırılmıştı; silah mantığı `weapon_*.gd`, dünya mermisi `projectiles/*.tscn`. |
| 2026-04-09 | **Silah / eşya denge geçişi** — PDF “Oyun Dengesi İçin Silah Verileri” ile tüm taban + evrim silahları + pasif eşya formülleri; lazer menzil 300→500 zirve, Death Laser 400→600; kritik eşya 1.5× + `player.get_total_damage`; `SILAHLAR_ESYALAR_EVO.md` güncellendi. |
| 2026-04-09 | **Cog / level-up / veri doc** — Dişli 5’te sınır + sarı etiket, doluyken düşmez; boş progression level-up’ta +20 can / +25 altın (UI yok); max hızda hız kartı yok; `has_progression_upgrades` + `apply_empty_level_reward`; `docs/SILAHLAR_ESYALAR_EVO.md` tabloları. |
| 2026-04-09 | **Kill HUD + hız tavanı** — `enemy_base`/`giant`/`boss`: öldürme `die()` anında `on_enemy_killed` (tween + hit-stop beklenmez); `main._process` co-op HUD her kare; `player.MAX_MOVE_SPEED` 300 + `get_effective_move_speed()`. |
| 2026-04-09 | **Menülerde ESC / geri** — `core/menu_input.gd` (`MenuInput.is_menu_back_pressed`): `ui_cancel`, ESC, gamepad B; `game_mode_select`, `map_select`, `shop`, `meta_upgrade`, `collection` (önce seçim temizle), `settings` (rebind varken önce iptal), `pause` (önce iç ayar paneli), `game_over`→ana menü, `intro` (prompt sonrası); karakter seçim P1/P2 güncellendi. |
| 2026-04-09 | **Açılış ekranı (intro)** — `intro_splash`: `FullRect` layout; tint yok (foto tam parlaklık); ~5 sn siyah fade; 4–6. sn prompt alttan (ayar: `intro_splash.gd` `PROMPT_*`); `AudioManager.play_music(1)`; `press_to_start` → `main_menu.tscn`; `MainMenuBackground.gd`. |
| 2026-04-09 | **Ana menü arka plan zemini** — `main_menu.tscn`: foto katmanı + tint + yıldızlar; `assets/ui/main_menu_bg` (png/jpg/webp) + `README_MAIN_MENU_BG.txt`. |
| 2026-04-09 | **Karakter seçim UX + hız** — Portre: `idle_left` ilk kare + doku önbelleği (SubViewport kaldırıldı); kilit=siyah, unlock+satın değil=silüet, satın=tam; sabit 136² çerçeve; `game_mode_select` arka plan `warmup_portraits_async`; ESC ile P1→oyun modu, P2→P1 seçim. |
| 2026-04-09 | **Run modu + mağaza + erişilebilirlik** — `map_select`: story/fast, `run_curse_tier` 0–5, harita önizleme; `SaveManager` run süreleri / spawn çarpanı; ana menü **Mağaza** → `ui/shop_menu` (placeholder sekmeler); Ayarlar → Görüntü: `ui_scale`, `colorblind_palette`; `upgrade_ui` emoji satır önekleri; `locales` + matris güncellemesi. |
| 2026-04-09 | **Performans ön ayarı (erişilebilirlik #6)** — `performance_quality` high/medium/low: `get_max_enemies_cap` (1200/650/320), sürü ve kuşatma olay sayısı çarpanı, `is_heavy_vfx_enabled` (düşükte kapalı) + partikül `get_particle_burst_count`; `spawn_manager.get_max_enemies()`, `main.gd` spawn döngüsü; Ayarlar → Görüntü açılır liste; locale. |
| 2026-04-09 | **Ayarlar — Kontroller + sekme düzeni** — `InputRemap` autoload; `input_keyboard_overrides` kaydı; Ayarlar → **Kontroller**: P1/P2 yön, duraklat, tam ekran için klavye yeniden atama (oyun kolu olayları korunur); **Görüntü**: `enemy_high_contrast_outline`; **Oynanış**: `pause_on_focus_loss` vb.; tam ilerleme sıfırlamada tuşlar varsayılana; `locales` + matris Tablo 1 satır 18 **Kısmi** notu. |
| 2026-04-09 | **Erişilebilirlik (matris Tablo 1)** — Pencere odak kaybında otomatik duraklatma (`main.gd` + `pause_on_focus_loss`); F11 tam ekran (`toggle_fullscreen`, `SaveManager.apply_window_mode_from_settings`); isteğe bağlı düşman yüksek kontrast çerçevesi (`enemy_high_contrast_outline` + `enemy_base`); exploder yakınlık nabız uyarısı; `pause_menu_overlay` grubu ile ESC/odak senkronu; locale `tr`/`en`/`zh_CN`. |
| 2026-04-07 | **Erişilebilirlik matrisi — çoklu dil** — `ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`: Tablo 1 altında **Çoklu dil (çapraz)** bölümü; run HUD / dalga ödülü / level-up önekleri kapsamı + kalan sabit metin notu; üst bilgi “son kod kontrolü” güncellendi. |
| 2026-04-07 | **Run UI / denge** — HUD dalga metni + dalga ödülü paneli `tr` / `en` / `zh_CN`; ödül altın (12+4×dalga), iyileşme %15, hasar +5; çoklu seviye XP → sıralı level-up kuyruğu (`main.queue_upgrade` solo+coop); `get_total_damage` artık `bullet_damage` ekler; level-up silah/eşya ID eşlemesi genişletildi. `TASARIM.md` karakter görselleri ✅. |
| 2026-04-07 | **Kahraman `start_item` kaldırıldı** — Tüm `CharacterData.CHARACTERS` için `start_item` boş; yalnız başlangıç silahı. Vampir / Göçebe / dört yeni rol açıklamaları Hat Kıran tarzı bilgi kartı (silah, eşya, evrim, açılış, origin); kodeks `codex_extensions_*` + merge; `lore.md` başlangıç yükü ilkesi. |
| 2026-04-07 | **4 kahraman + 8 silah + 4 eşya + 4 evrim** — Kontrolör: `sigil_warden` (hex_sigil + glyph_charm → binding_circle), `grav_binder` (gravity_anchor + resonance_stone → void_lens). Tank: `ironclad` (bastion_flail + rampart_plate → citadel_flail), `linebreaker` (shield_ram + iron_bulwark → fortress_ram). `CharacterData` sonda (indeks uyumu); `player.gd` glyph/rampart/iron bulwark zırh + rezonans çekim; sahneler frost/paladin kopyası; `locales` + `CollectionData` + `upgrade_ui` havuzları. |
| 2026-04-07 | **Kilit ipucu / açıklama** — Büyücü/Vampir `unlock_hint`, Göçebe `description` ve kodeks `nomad` açıklamaları (tr/en/zh_CN + `codex_extensions_*`) satın alma/altın cümlesinden arındırıldı; ücret yalnızca koşul sonrası satın alma butonunda. |
| 2026-04-07 | **Karakter ilerlemesi** — Başlangıçta yalnızca Savaşçı ücretsiz; Büyücü (50 toplam kill → 💰150) ve Vampir (Savaşçı ile 120 sn hayatta kalma → 💰175) kilit + satın alma; `SaveManager` / tam sıfırlama / devtool “lock_chars” varsayılanı `["warrior"]`; `selected_character_p2` varsayılan `0`. |
| 2026-04-07 | **Karakter seçimi — sınıf filtresi** — `hero_class` + `HERO_CLASS_FILTER_IDS`; P1/P2 `character_select*.gd` dört rol filtresi (tekrar basınca tüm liste); `special` kahramanlar yalnızca filtresiz görünür; `ui.character_select.filter_*` locale. |
| 2026-04-07 | **Lore belgesi** — `docs/lore.md`: çöküş sonrası dünya (kalıntı teknoloji + rün), Şeytani Kral endgame çerçevesi, Warrior/Mage tasvirleri ve tasarım ilkeleri; `GELISTIRICI_REHBERI.md` dokümantasyon listesine `lore.md` maddesi eklendi. |
| 2026-04-07 | **Performans / refaktör** — `EnemyRegistry` autoload (düşman listesi, `EnemyBase` kayıt); silah/efektlerde `get_nodes_in_group("enemies")` kaldırıldı; `ObjectPool` serbest yuva yığını; `PlayerLoadoutRegistry` (silah/eşya fabrikası); `CharacterData.CHARACTER_SCENE_BY_ID`; `player_ui_helpers`, `character_select_helpers`, `settings_ui_styles`; `MAX_ENEMIES` 1200; `ui.player` / `ui.character_select` locale anahtarları. |
| 2026-04-07 | **Ürün vizyonu** — Co-op destek kahramanları, dört karakter sınıfı, profil/meta, idle-benzeri görevler, rehber/kodeks/sözlük maddeleri `YOL_HARITASI.md` içinde işaretlendi; ayrıntılı sınıf ve kahraman taslağı: `docs/KARAKTER_SINIFLARI_VE_TASARIM.md`. |
| 2026-04-07 | **TASARIM.md — düşman görsel envanteri** — Tüm düşman türleri için `AnimatedSprite2D` + asset yolları doğrulandı; eski “yalnız ColorRect” satırları kaldırıldı; outline / exploder ön uyarısı ayrı hedef olarak not edildi. |
| 2026-04-07 | **Kodeks genişletme** — Sekmeler: düşman, boss, silah, eşya, kahraman, harita; `codex_weapons` / `codex_items` / `codex_maps`; `CollectionData` + `locales/codex_sources` + `merge_codex_extensions.py`. |
| 2026-04-07 | **Bağlılık matrisi Tablo 2 #11 (koleksiyon / bestiary)** — Ana menüden kodeks; grid + filtre + detay; ilk öldürmede `codex_discovered` kaydı; `tr` / `en` / `zh_CN` `codex.*` metinleri. |
| 2026-04-07 | **Erişilebilirlik matrisi #4** — `player_vfx_opacity`: kayıt, Ayarlar + duraklatma kaydırıcısı, oyuncu/silah/projeksiyon/item görsel opaklık çarpanı (`player.get_player_vfx_opacity()`). |
| 2026-04-07 | **Evrim sistemi (ilk derinleştirme)** — `WeaponEvolution.is_evolution_ready`, `evolve_weapon` güvenli çıkış; `get_available_evolutions` karıştırma; isteğe bağlı `weight`; `ui.evolution_defs` + level-up / yüzen metin yerelleştirmesi; `upgrade_ui` 4. seçenek (cog shard) ve reroll’da `pick_count` düzeltmesi. |
| 2026-04-07 | **Godot çıktı / derleme** — `LocalizationManager`: geçersiz `TranslationServer.set_fallback_locale` kaldırıldı; `ProjectSettings` + `project.godot` `internationalization/locale/fallback`; `nomad.tscn` tekil sahne UID; `enemy1.png` ile uyumlu `ext_resource` UID; UI/damage_number sahnelerinde hatalı script UID’leri kaldırıldı; 16k+ px geniş texture’lar `process/size_limit=8192` + ilgili `AtlasTexture` bölgeleri ölçeklendi (`warrior` / `nomad` / `player` / `omega`). |
| 2026-04-07 | **Yerelleştirme paketi (tamam)** — `LANGUAGE_CATALOG`, OS ile ilk kurulum dili, `internationalization/locale/fallback`, geçersiz `locale` düzeltmesi, `check_locale_parity.py` (tüm `locales/*.json` ↔ `en.json`); **简体中文** `zh_CN.json` + `lang_*` anahtarları + OS `zh` eşlemesi (繁体 bölgeler şimdilik `en`). |
| 2026-04-06 | **Yerelleştirme (ilk sürüm)** — `LocalizationManager` autoload, `locales/tr.json` + `en.json`, `SaveManager.settings.locale`, Ayarlar → Dil; ana UI metinleri `tr()` ile anahtarlandı. |
| 2026-04-04 | **Dokümantasyon** — `docs/TASARIM.md` eklendi; sanat/yayın envanteri oraya taşındı; erişilebilirlik matrisi yalnızca kod durumuna indirgendi. |
| 2026-04 | **Göçebe (nomad)** — Karakter, sahne, spawn, kilit (175 toplam kill → 350 altın), seçim ekranı sırası, indeks migrasyonu (`character_order_v2`). |
| 2026-04 | **Yelpaze Bıçak + shard** — `fan_blade`, `fan_blade_shard` (Polygon2D, ObjectPool), yakın menzil. |
| 2026-04 | **Kor Kalbi + Kor Yelpazesi** — `ember_heart`, evrim `ember_fan` (MAX fan_blade + MAX ember_heart). |
| 2026-04 | **Dokümantasyon** — `docs/GELISTIRICI_REHBERI.md`, `docs/YOL_HARITASI.md`, kök `README.md`, Cursor kuralı `ironfall-docs.mdc`. |
| 2026-04-05 | **Erişilebilirlik + devamlılık checklist** — Özet bölüm eklendi; kodla doğrulandı. |
| 2026-04-06 | **20+20 tam matris** — `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md` (CSV taslak sütunları + Var/Kısmi/Yok + repo notu). |
| (not) | Türbin, Buharlı Zırh, Enerji Hücresi testi; Cog Shard HUD — plan kaynağında tamam notu. |

*Yeni satır en üste veya en alta eklenebilir; takım tercihine göre “en yeni üstte” tutulması okumayı kolaylaştırır.*

---

## Erişilebilirlik ve devamlılık

**Kod durumu matrisi:** [ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md](ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md)  
**`TASARIM.md`:** [TASARIM.md](TASARIM.md)

Teknik ayar anahtarları: `GELISTIRICI_REHBERI.md` §15.

---

## Öncelik tabloları (plan)

### Acil — Yarım kalan veya kısa vadede bitirilecek işler

*(2026-04-14: açık **acil kod işi** yok.)* **Repo:** `git status` ile `??` kalan `assets/projectiles/`, `weapons/scenes/`, `tools/`, yeni `effects/` / `projectiles/` dosyalarını ve silinen `boomerang` yollarını içeren diff’i commit’lemek sıradaki pratik adım.

---

### Önemli — Sistem temelleri

| Durum | İş |
|--------|-----|
| [x] | **Dil sistemi (localization)** — `LocalizationManager`, `LANGUAGE_CATALOG`, `tr` / `en` / `zh_CN`, Ayarlar → Dil, OS ilk kurulum, parity script; *yeni diller sonraya bırakıldı.* |
| [ ] | **Evrim sistemi derinleştirme** — Kombinasyonlar, denge, UI, kenar durumlar. *(2026-04: doğrulama, locale, cog 4. slot, reroll/pick_count, havuz sırası; yeni evrim/denge için devam.)* |
| [x] | **README.md** — GitHub için özet, Godot ile çalıştırma, `docs/` linkleri. |
| [ ] | **Bağlam belgesi** — `survivors_clone_context.md` (veya eşdeğeri): Ironfall, yeni sistemler, autoload özeti. |

---

### Orta vadeli — İçerik genişletme

| Alan | Hedef / not |
|------|----------------|
| **Yerelleştirme (yeni diller)** | `ru`, `es`, `pt_BR`, `ja`, `de`, `fr`, `ko`, `pl`, `uk` — tablo ve `code`/`steam` eşlemesi: `GELISTIRICI_REHBERI.md` § yerelleştirme. |
| **Karakterler** | Örn. 20 satın alınabilir + 3 gizli = 23 toplam (hedef rakam tartışılabilir). |
| **Silahlar** | Örn. ~20 silah; karakter–silah teması. |
| **Pasif eşyalar** | Çeşitlendirme; havuz büyütme hedefleri. |
| **Düşmanlar** | Harita başına 6–8 çeşit gibi hedef. |
| **Haritalar** | Örn. 5 hikaye + 5 arena (arena modu ile birlikte). |

Paralel envanter: `docs/TASARIM.md`.

---

### Uzun vadeli — Oyun derinliği

- [ ] **Lore** — Hikaye, boss, harita metinleri (metin/envanter: `docs/TASARIM.md`).
- [ ] **Arena modu (tam)** — Ayrı arena haritası, dalga savunma ritmi, ödül ekonomisi; `map_select` ile genişletme. *(v0: `run_variant` **arena**, `SaveManager.ARENA_RUN_GOAL_SEC` ≈ 10 dk, `vs_map`; `dusk` açılış bayrağı — günlük 2026-04-14.)*

---

## Ürün vizyonu — güven, statü, verimlilik, rehber

Aşağıdaki maddeler **ürün / tasarım** kaynağıdır; kod durumu satır içi notlarla işaretlenir. Karakter sınıfları ve kahraman taslak tablosu: [KARAKTER_SINIFLARI_VE_TASARIM.md](KARAKTER_SINIFLARI_VE_TASARIM.md).

### A. Oyuncunun kendine güveni

| Durum | Madde |
|--------|--------|
| [ ] | **P2P / co-op destek kahramanları** — Takım arkadaşına kısa süreli hasar buff’ı, iyileşme oranı, cooldown / area büyütme vb.; çeşitli support kimlikleri. *(Co-op’ta P2 seçimi var; takım buff mekaniği yok.)* |
| [x] | **Dört sınıf tanımı (metin)** — Controller, Fighter, Mage, Tank açıklamaları `KARAKTER_SINIFLARI_VE_TASARIM.md` içinde. |
| [ ] | **Sınıfın oyuna bağlanması** — `CharacterData` veya eşdeğerinde `class` alanı, UI’da gösterim, denge. |
| [ ] | **Mevcut kahramanların sınıfa göre stat hizalaması** — Taslak atama belgede; sayısal denge beklemede. |
| [x] | **Yeni kahramanlar için sınıf çerçevesi** — Tasarım kuralı olarak belgelendi (`2.1`). |

### B. Oyuncunun “statüsü” hissi

| Durum | Madde |
|--------|--------|
| [x] | **Profil sekmesi (temel)** — Ayarlar → Profil: kalıcı istatistikler + başarı listesi (`ui/settings.gd` `_build_profil_tab`). |
| [ ] | **Profil genişlemesi** — Takma adlar, ikonlar, açılabilir profil arka planı ve çerçeveler. |
| [ ] | **Hesap / seviye sistemi** — Level atladıkça ödüller (yukarıdaki kozmetiklerle bağlantılı olabilir). |
| [ ] | **İleride rank sistemi** — Rekabetçi veya görünür derecelendirme (tasarım açık). |

### C. Verimlilik (idle-benzeri, ana oyunu gölgelemeden)

| Durum | Madde |
|--------|--------|
| [ ] | **Görev / idle-benzeri gönderim** — Oyun tam idle olmayacak; açılmış kahramanlardan bir veya birkaçını gerçek zamanlı süreli görevlere gönderme (ör. 30 dk → 24 saat arası birkaç süre seçeneği). |
| [ ] | **Ödüller** — Dönüşte altın ve/veya XP; hesap seviyesi veya modlara göre kullanılabilir para ayrımı (tasarım kararı). |
| [ ] | **Ölçekleme** — Rank / seviyeye göre görev açılımı; eşzamanlı görev sayısı; gönderilebilen kahraman sayısı; idle menü içi shop / güçlendirme. |
| [ ] | **Hedef** — Az vakitli oyuncular için alternatif kasma yolu; **asıl run deneyiminin önüne geçmeyecek** şekilde sınırlar. |

### D. Direction — rehber ve kodeks

| Durum | Madde |
|--------|--------|
| [ ] | **Her deneyim seviyesine onboarding** — İlk kez açan, türe yabancı veya deneyimli oyuncu için yönlendirme akışı. |
| [ ] | **Sağlam rehber kaynağı** — Tek yerden erişilen, güncellenebilir rehber (UI + metin). |
| [x] | **Koleksiyon / kodeks zemini** — Ana menüden kodeks; düşman, boss, silah, eşya, kahraman, harita sekmeleri (`CollectionData.TAB_ORDER`). |
| [ ] | **Koleksiyonda evrim bölümü** — Evrim silahları run içinde var; kodekste ayrı **Evrim** sekmesi veya alt bölüm yok. |
| [ ] | **İleride idle / görev sistemi** — Rehber veya kodeksten bağlantı (D + C entegrasyonu). |
| [ ] | **Oyun içi sözlük** — Cooldown, area ve benzeri terimlerin açıklaması; koleksiyon içi bölüm veya ayrı sözlük sekmesi. |
| [ ] | **Genel rehberlik önceliği** — Oyuncunun ne topladığını, neyin ne işe yaradığını anlaması (UX + metin). |

---

### Yayın (dış platformlar)

Checklist: `docs/TASARIM.md`.

---

## Fikir havuzu (henüz önceliklendirilmemiş)

- Üst bölüm **Ürün vizyonu — güven, statü, verimlilik, rehber** geniş planı toplar; buraya daha ince fikirler eklenebilir.
- …

---

## Eski “tamamlananlar listesi” (özet)

Ayrıntılı kayıt için yukarıdaki **Tamamlanan sistemler (özet)** ve **Yapılan iş günlüğü** tablolarını kullanın. Burası yalnızca hızlı hatırlatma:

- Göçebe, Yelpaze Bıçak başlangıç; Kor Kalbi koşuda, Kor Yelpazesi evrimi; karakter sırası / kayıt migrasyonu, dokümantasyon ve README tamamlandı (2026-04).
- Üç dilli arayüz (`tr` / `en` / `zh_CN`) ve yerelleştirme altyapısı tamamlandı (2026-04-07); ek diller planlı.
