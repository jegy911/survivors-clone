# Ironfall — Geliştirici rehberi

Bu belge, projenin **nasıl işlediğini**, dosyaların **birbirine nasıl bağlandığını** ve **yeni içerik eklerken izlenmesi gereken yolları** özetler.  
*(İngilizce projelerde eşdeğeri genelde `ARCHITECTURE.md`, `DEVELOPER_GUIDE.md` veya `docs/CONTRIBUTING.md` olarak adlandırılır.)*

**Motor:** Godot 4.x  
**Son güncelleme:** 2026-04-28 (`blood_pool` zemin üstü z-index; `weapon_citadel_flail` / `weapon_binding_circle` alan halkası; önceki: `ButtonCoverStyles` — §4)

**Hızlı giriş (yeni geliştirici / AI):** `docs/survivors_clone_context.md` — kısa autoload ve sahne akışı; bu dosya tam mimari rehberdir.

**Öncelikli plan (audit):** Ürün açıkları, bug / locale kalanları, refaktör ve optimizasyon maddelerinin sıralı özeti → **`docs/YOL_HARITASI.md`** başındaki **«Proje incelemesi — öncelikli plan (audit)»** (P0–P4).  
**Tek sayfa yapılacaklar:** [x] **`docs/YAPILACAKLAR_TOPLU.md`** — yalnızca açık işler listelenir; madde bitince oradan **silinir**, kaynak dokümanda **[x]** / güncelleme yapılır (iş akışı dosya başında).

### Dokümantasyonu ne zaman güncellemeliyiz?

Oyuna veya teknik yapıya dokunan her önemli değişiklikten sonra:

1. **`docs/GELISTIRICI_REHBERI.md`** — Yeni bir *tür* içerik eklediysen (ör. yeni orb, yeni pickup, yeni harita akışı) ilgili **checklist veya bölümü** ekle veya mevcut maddeleri güncelle. Sadece küçük denge değişikliği ise yalnızca etkilenen paragrafı düzeltmen yeterli olabilir.
2. **`docs/YOL_HARITASI.md`** — Planlanan bir iş bittiyse: öncelik tablosunda `[x]` yap veya maddeyi kaldır; **Yapılan iş günlüğü**ne tarih ile kısa satır ekle. İptal edilen işleri not düşerek çıkar.
3. **`docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`** — Erişilebilirlik veya bağlılık maddelerinden birinin **Var/Kısmi/Yok** durumu kodda değiştiyse ilgili tablo satırını güncelle.
4. **`docs/TASARIM.md`** — Envanterdeki bir madde teslim edildiyse veya yeni kalem eklendiyse ilgili satırları güncelle.
5. **`docs/KARAKTER_SINIFLARI_VE_TASARIM.md`** — Karakter **sınıfı**, co-op destek vizyonu veya sınıf–kahraman tablosu değiştiyse güncelle.
6. **`locales/en.json`** (+ gerekirse **`locales/codex_sources/codex_extensions_en.json`**) — Rutin geliştirmede yeni metin **yalnızca İngilizce** dosyalara eklenir (`tr` / `zh_CN` donduruldu — ayrıntı § «Yerelleştirme»). Tam dil turunda tüm `locales/*.json` + `check_locale_parity.py` disiplinine dönülür.
7. **`README.md`** — Kurulum / çalıştırma / repo yapısı değiştiyse ana sayfayı güncelle.
8. **`docs/lore.md`** — Evren, karakter ve düşman anlatısı netleştikçe veya yeni içerik lore ile bağlanacaksa ilgili bölümü güncelle.
9. **`docs/sesler-muzikler-efektler.md`** — Yeni ses dosyası, `AudioManager` / `audio_manager.tscn` stream’i, yeni `play_*` tetikleyicisi veya müzik parçası eklendiyse / kaldırıldıysa bu envanteri güncelle.

*(IDE’de Cursor kullanıyorsan: `.cursor/rules` altındaki `ironfall-docs.mdc` kuralı bu disiplini hatırlatır.)*

**Referans (VS / Brotato, proje başı arşiv):** `docs/vs wiki analizi/` — ayrıntılı wiki notları (dört dosya). Ürün damıtması **`docs/YOL_HARITASI.md`** «Referans — VS / Brotato wiki analizi» tablosunda; yapılacaklar **`docs/YAPILACAKLAR_TOPLU.md`** «`docs/vs wiki analizi/`» bölümünde; lore / görsel isimler **`docs/lore.md`**, **`docs/TASARIM.md`**.

---

## 1. Genel akış (oyun döngüsü)

1. **`project.godot`** → `run/main_scene` = `res://ui/intro_splash.tscn` (kara overlay ~5 sn; arka plan tint’siz; `AudioManager.play_music(1)`; `ui.intro_splash.press_to_start` 4–6. sn alttan kayma (konum: `intro_splash.gd` `PROMPT_*` sabitleri + `.tscn` yatay offset); tuş / tık / gamepad → `main_menu.tscn`).
2. **Autoload’lar** (`project.godot` → `[autoload]`): `SaveManager`, `InputRemap`, `LocalizationManager`, `AudioManager`, `ObjectPool`, `EnemyRegistry`, `EventBus`, `AchievementManager` — sahne yüklenmeden önce hazır olurlar (`SaveManager` ve `InputRemap`, `LocalizationManager`’dan önce yüklenir).
3. Tipik oyuncu akışı: **Açılış ekranı** → **Ana menü** → mod seçimi → **Karakter seçimi** → (co-op ise P2 karakter) → **Harita seçimi** → **`main/main.tscn`** (asıl oyun).
4. Oyunda oyuncu **`player/player.gd`** (karakter sahnesi üzerinden) ile yaratılır; `main/main.gd` spawn, dalga, ortam yöneticilerini kurar.

**Önemli:** Karakter, silah ve eşya kimlikleri çoğunlukla **string ID** (`"warrior"`, `"fan_blade"`, `"ember_heart"`) ile taşınır; tek bir merkezi `.tres` veritabanı yoktur — aynı ID birden fazla dosyada tutarlı olmalıdır.

---

## 2. Autoload’ların rolleri

| Autoload | Görev |
|----------|--------|
| **SaveManager** | Altın, seçili karakter/harita, meta upgrade’ler, ayarlar (`locale` dahil), kilit / satın alınmış karakter listeleri, istatistikler; **hesap seviyesi:** `account_level`, `account_xp` (mevcut seviye içi ilerleme), `account_xp_total` (koşulardan bankalanan toplam); `user://save.cfg` → **`[account]`** (`level`, `xp`, `xp_total`); koşu sonu `game_over` → run combat XP’nin %20’si (`grant_account_xp_from_run_raw`); seviye atlayınca **`level_up`** / **`account_level_up`** + Profil `ProgressBar` tween için **`account_profile_level_flash_pending`**; kodeks: **`codex_discovered`**, **`codex_weapons`**, **`codex_items`**, **`codex_maps`**. |
| **LocalizationManager** | `LANGUAGE_CATALOG` + `locales/<code>.json` → `TranslationServer`; fallback dili `project.godot` → `internationalization/locale/fallback` ve `_ready()` içinde `ProjectSettings.set_setting(..., "en")`; ilk kurulumda kayıt yoksa **OS dili** (katalogda varsa); `locale_changed` sinyali. |
| **AudioManager** | SFX + tek `MusicPlayer` ile arka plan: `music1`–`music6` sırayla döngü (`play_music(1..6)`, `music_prev` / `music_next`, `pause_music` / `resume_music`); koşu yarısında `main.gd` hâlâ erken `play_music(2)` çağırabilir. `SaveManager.level_up` → `play_account_level_up()` (`levelup.mp3`). **İsteğe bağlı müzik dip’i:** `SaveManager.settings["combat_music_duck"]` açıkken `weapon_base` her başarılı `attack()` sonrası `notify_combat_music_duck_beat()` → müzik bus hacmine kısa linear çarpan (`_refresh_music_bus_volume`); kapalıyken çarpan uygulanmaz. **Dosya / olay haritası:** `docs/sesler-muzikler-efektler.md`. |
| **ObjectPool** | Sık oluşturulan nesneler (mermi, orb, damage number vb.) için havuz; `get_object(scene_path)` / `return_object` (serbest yuva yığını ile hızlı seçim); ilk dolgu + dönüşte `reset()`. Havuzdaki `Area2D` çarpışma politikası → aşağı §4 **Projectile + ObjectPool**. |
| **EnemyRegistry** | Canlı düşman listesi; `EnemyBase` kayıt/çıkış (`tree_exiting`); silah ve efektler `EnemyRegistry.get_enemies()` ile okur (yoğun sürüde `get_nodes_in_group` yükünü azaltır). |
| **EventBus** | Sinyal merkezi (hasar, ölüm, level up, altın vb.). |
| **AchievementManager** | Başarı kontrolleri. |

### Yerelleştirme (UI metinleri)

- **Çeviriler:** `locales/<code>.json` (şu an `tr`, `en`, `zh_CN`) — iç içe sözlükler düz anahtara çevrilir (`ui.settings.title` gibi).
- **Kod:** `tr("anahtar")` veya `tr("anahtar") % değerler` (printf biçimli dizeler için).
- **Tek kaynak dil listesi:** `core/localization_manager.gd` içindeki `LANGUAGE_CATALOG` — her satır: `code`, `label_key` (Dil açılır listesinde `tr()` ile), isteğe bağlı `steam` (Steam `GetCurrentGameLanguage` kısa adı; yayın entegrasyonu için). Yeni dil: katalog satırı + `locales/<code>.json` + **bütün** mevcut dil dosyalarında `ui.settings.lang_<code>` (görünen dil adı).
- **Ayar:** `SaveManager.settings["locale"]` — geçerli `code`; `ui/settings.tscn` **Dil** sekmesi `LANGUAGE_CATALOG` ile doldurulur; `LocalizationManager.set_locale()`.
- **İlk oyun açılışı:** `user://save.cfg` yoksa dil, `OS.get_locale()` ile kataloga eşlenir; eşleşmezse `en`. Seçim kayda yazılır.
- **Eksik çeviri:** `internationalization/locale/fallback` (`en`); yeni dil dosyasında boş anahtar bırakılmamalı — `python locales/check_locale_parity.py` ile tüm `locales/*.json` dosyalarının `en.json` ile anahtar eşitliği kontrol edilir (çıkış kodu 1 = fark var).
- **Geliştirme dönemi — dil dondurması (2026):** Yeni metin ve anahtarlar **yalnızca** `locales/en.json` ve `locales/codex_sources/codex_extensions_en.json` içinde güncellenir. **`tr.json`**, **`zh_CN.json`**, **`codex_extensions_tr.json`**, **`codex_extensions_zh_CN.json`** şimdilik **raf** (ikinci emre / tam yerelleştirme turuna kadar rutin güncelleme yok; mevcut halleriyle kalır). Bu süreçte parity script bilinçli olarak `en` ile fark gösterebilir; dil turunda tekrar hizalanır.
- **EN-only UI metni (dondurma sırasında):** Arayüz dil `tr` / `zh_CN` olsa bile belirli blokların metnini **yalnızca İngilizce** göstermek için `LocalizationManager.tr_en_source("ui....")` kullanılır (`en.json` çeviri nesnesinden okur; yoksa `tr()`). Örnek: `ui/map_select` koşu laneti açıklaması + istatistik satırları; `ui.settings.combat_music_duck` etiketi.
- **Yeni metin (tam dil turu / eski disiplin):** Tüm mevcut locale dosyalarına aynı anahtarı ekleyin; gerekirse `locales/gen_locales.py` ile `tr`/`en` üretimi (isteğe bağlı).

#### Mevcut diller (repo)

| Dil | `code` | Dosya |
|-----|--------|--------|
| Türkçe | `tr` | `locales/tr.json` |
| İngilizce | `en` | `locales/en.json` |
| Basitleştirilmiş Çince | `zh_CN` | `locales/zh_CN.json` |

*(2026-04 itibarıyla yeni dil ekleme çalışması **geçici olarak durduruldu**; sıradaki diller aşağıdaki plan tablosundan ilerlenecek.)*

#### Planlanan diller (dosya henüz yok)

`code` sütunu `locales/<code>.json` ve `LANGUAGE_CATALOG` ile uyumlu olmalıdır. Steam sütunu `ISteamApps::GetCurrentGameLanguage()` kısa adlarına karşılık gelir.

| Dil | Önerilen `code` | Steam dili |
|-----|-----------------|------------|
| Rusça | `ru` | `russian` |
| İspanyolca | `es` | `spanish` |
| Brezilya Portekizcesi | `pt_BR` | `brazilian` |
| Japonca | `ja` | `japanese` |
| Almanca | `de` | `german` |
| Fransızca | `fr` | `french` |
| Korece | `ko` | `korean` |
| Lehçe (Polish) | `pl` | `polish` |
| Ukraynaca | `uk` | `ukrainian` |

*(Türkçe, İngilizce ve `zh_CN` yukarıda “Mevcut diller” tablosunda; `en` Steam’de `english`.)*

---

## 3. Karakter sistemi

### Rol ve sınıf (tasarım)

- **Sınıf çerçevesi** (Controller, Fighter, Mage, Tank), co-op destek vizyonu ve mevcut kahramanların **taslak** sınıf eşlemesi: **`docs/KARAKTER_SINIFLARI_VE_TASARIM.md`**. Kodda rol etiketi: `CharacterData.CHARACTERS[].hero_class`; tasarım tablosu ile senkron tutulmalıdır.

### Veri
- **Yeni kahraman talebi (silah + eşya + evrim paketi):** Tek PR’da tamamlanması gereken kapsam ve kontrol listesi → **`docs/KARAKTER_YENI_KARAKTER_PAKETI.md`** (sınıf adıyla kısa istek bile bu paketi içerir).
- **`core/character_data.gd`** — `CharacterData.CHARACTERS` dizisi: her eleman bir sözlük (`id`, `name`, `description`, `color`, `start_weapon`, `start_item`, bonuslar, `locked`, `secret`, `cost`, `unlock_condition`, `origin_bonus`, `special`, `hero_class` — tasarım rolü: `tank` / `fighter` / `mage` / `controller` / `special`; seçim filtresi sırası: `HERO_CLASS_FILTER_IDS`). Kilit **ipucu metni** artık `locales/en.json` → `ui.character_select.unlock.<id>` (`CharacterSelectHelpers.localized_unlock_hint`). **Tüm kahramanlarda `start_item` boş** — başlangıçta yalnızca `start_weapon`; imza pasifler (ör. `night_vial`, `ember_heart`) koşuda toplanır. `description` / kodeks metinleri silah + koşu içi eşya yolu + evrim satırlarını taşır. Karakter sahne yolu: `CharacterData.CHARACTER_SCENE_BY_ID` + `get_character_scene_path(char_id)` (`main/main.gd` oyuncu spawn).

### Sahne
- **`characters/<id>/<id>.tscn`** — Çoğunlukla `CharacterBody2D` + `player/player.gd`; her karakter kendi klasöründe tutulur.
- **Çok geniş sprite sheet:** Birçok GPU’da tek dokunun kenarı ~8192 px ile sınırlıdır. Daha geniş PNG kullanıyorsan ilgili `.png.import` içinde `process/size_limit=8192` (veya cihazına uygun üst sınır) kullan ve sahnedeki `AtlasTexture` `region` değerlerini aynı ölçek faktörüyle güncelle (projede savaşçı gövdeleri için örnek: `8192 / 16064`).

### Spawn
- **`main/main.gd`** → `_get_character_scene(char_id)` içinde `match` ile `res://characters/...` yolu **mutlaka** eklenmeli.

### Oyun içi uygulama
- **`player/player.gd`** → `apply_character_bonuses()`: `SaveManager.get_character_index_for_player(player_id)` ile `CHARACTERS` okunur (kahraman **`selected_character_id`** / **`selected_character_p2_id`** üzerinden tutarlıdır); `start_weapon` / `start_item` için `add_weapon` / `add_item` çağrılır; `origin_bonus` ve `special` burada işlenir. **Level-up:** `gain_xp` birden fazla seviye verirse her biri için `main.queue_upgrade(player)` kuyruğa girer (solo ve co-op aynı yol). **Koşu XP / seviye hızı:** `RUN_XP_GAIN_MULT` (girdi çarpanı), `_calc_xp_for_level` + `LEVEL_XP_REQUIREMENT_MULT` (seviye eşiği), Lv1 için `apply_meta_bonuses` sonrası `_calc_xp_for_level(1)`; dalga ödülü XP → `wave_manager.gd` (`xp_to_next_level` kesri). `get_total_damage()` taban silah hasarına `bullet_damage` (karakter/meta/dalga düz bonusu) ekler. **Koşu HUD envanteri:** `recalculate_category_bonus()` sonunda `update_category_ui()` → `PlayerUiHelpers.rebuild_run_loadout_hud(self)` — `CanvasLayer/CategoryPanel` içinde iki satır (silahlar / eşyalar), slot başına `UpgradeIconCatalog` ikon + `ui.player.loadout_slot_lvl` (`tr_en_source`, yalnız `en.json`); ikon yoksa `upgrade_ui` ile aynı emoji yedeği (`player_ui_helpers.gd`).

### Kayıt ve kilit
- **`core/save_manager.gd`**
  - `unlocked_characters`: Koşul sağlandı mı (ör. toplam kill)?
  - `arena_cleared_as_shadow_walker`: Arena koşusunu kazanırken kadroda `shadow_walker` var mıydı? (`dusk_striker` `unlock_condition`: `arena_win_shadow_walker`)
  - `purchased_characters`: Altınla satın alındı mı?
  - **Yeni oyuncu varsayılanı:** Yalnızca `warrior` hem açık hem satın alınmış sayılır; `mage` / `vampire` `character_data` içindeki `unlock_condition` + `cost` ile açılır (mevcut kayıt dosyaları değişmez).
  - `check_and_unlock_characters()`: `unlock_condition` tiplerini `character_data` ile eşleştirir (ör. `arena_win_shadow_walker` → `arena_cleared_as_shadow_walker` bayrağı; `update_stats_after_game` içinde Arena + kazanma + kadroda `shadow_walker` iken set edilir).
  - `purchase_character(char_id)`: Hem `unlocked` hem yeterli altın gerekir.

### UI
- **`locales/*.json`**: `ui` altında **aynı anahtar iki kez** (ör. iki `"player"`) kullanma — JSON son değeri kabul eder; önceki blok (ör. `loadout`, istat metinleri) sessizce kaybolur ve `tr()` anahtarı döner → level-up’ta `%` format hatası / boş açıklama.
- **`ui/character_select.gd`** / **`ui/character_select_p2.gd`**: Kartlar `CHARACTERS` sırasına göre üretilir; sınıf filtresi (`hero_class`); P2’de P1’in karakteri filtre dışı kalsa da kartı görünür (alınamaz). **Görünen kahraman adı** `CharacterSelectHelpers.character_display_name(id)` → `codex.character.<id>.name`; **başlangıç silahı / eşya satırı** `CharacterSelectHelpers.weapon_display_name` / `item_display_name` → `codex.weapon.<id>.name` / `codex.item.<id>.name` (dil dosyası). `CharacterData.CHARACTERS[].name` yalnızca veri / Türkçe taslak. **Layout (2026-04-16):** `character_select*.tscn` — tam ekran arka plan `ColorRect`, `OuterMargin`, sol sütunda ortalanmış ızgara (`GridCenterRow` + spacer), sağda istatistik özeti `CharacterSelectStatsPanel.rebuild()` (`ui/character_select_stats_panel.gd`; meta + kahraman düz/yüzde bonusları yeşil satırlar). Alt aksiyon satırı `ActionMargin` ile köşeden içeride.

### Dikkat: indeks + kimlik kaydı
- `selected_character` / `selected_character_p2` hâlâ **indeks** olarak kaydedilir (UI uyumu); ayrıca `selected_character_id` / `selected_character_p2_id` (**kahraman `id` string**) saklanır. Oyun ve spawn `SaveManager.get_character_index_for_player()` ile önce ID’den indeks çözer; seçim ekranı `set_selected_character_p1_index` / `p2` ile ikisini birlikte günceller. Eski kayıtlarda yalnızca indeks varsa `load_game` sonunda `_reconcile_selected_characters_from_storage()` ID’yi indeksten doldurur.

---

## 4. Silah sistemi

### Oturumlar arası devam noktası

Kısa el sıkışma (bugün ne teslim edildi, sırada ne var): **`docs/YOL_HARITASI.md`** içindeki **«Son oturum — el sıkışma (2026-04-14)»** ve **«Teknik borç / refaktör ve optimizasyon»** bölümleri — bir sonraki çalışmada oradan devam etmek yeterli.

### Taban
- **`docs/SILAHLAR_ESYALAR_EVO.md`** — Taban silahlar, evrim silahları ve pasif eşyaların hasar / alan / miktar / cooldown özet tabloları (denge değişince güncelle).
- **`weapons/weapon_base.gd`** — `WeaponBase`: cooldown, `attack()`, `upgrade()`, `category`, `tag`, `weapon_name`; kök düğüm **`Area2D`** (çarpışma katmanı/maske 0, `monitoring` kapalı — yalnızca editör yerleşimi / isteğe bağlı çarpışma için). **`has_targets_for_attack()`** düşman yokken tam cooldown tüketmeden `NO_TARGET_RECHECK_SEC` ile yeniden dener; alan silahlarında `hit_cooldowns` boşalana kadar `true` kalabilir. **`GLOBAL_COOLDOWN_SCALE`** (`weapon_base.gd` sabiti; tüm silahların `get_effective_cooldown` çıktısı) taban bekleme sürelerini çarpar; alt sınıflar menzil kapısını kendi geometrilerine göre uygular. Başarılı `attack()` sonrası **`AudioManager.notify_combat_music_duck_beat()`** (yalnız `combat_music_duck` açıksa müzik dip’i).

### Yeni silah scripti
- `weapons/weapon_<isim>.gd`, tercihen **`class_name Weapon...`** (Godot global sınıf).

### Oyuncuya bağlama
- **`core/player_loadout_registry.gd`** — `PlayerLoadoutRegistry.WEAPON_SCRIPT_BY_ID`: string ID → `preload` script; `create_weapon(id)` önce **`weapons/scenes/weapon_<id>.tscn`** varsa `instantiate()`, yoksa `script.new()` (mantık düğümü). Şablon sahneler: kök `Area2D` + `CollisionShape2D` + (isteğe bağlı) `ColorRect` + `Sprite2D` — görseli Godot’da düzenlemek için. **Dünyadaki mermi / balta / buz topu** ayrı: `projectiles/*.tscn` (çoğu `Area2D` + çarpışma + sprite); ObjectPool ile spawn — `bullet.tscn` ile `weapon_bullet.gd` aynı şey değildir.
- **`player/player.gd`**
  - `add_weapon(type: String)` → `PlayerLoadoutRegistry.create_weapon(type)`.
  - `_on_upgrade_chosen` → yeni silah ID’si bu sözlükte ve `upgrade_ui` havuzunda olmalı.
  - `get_weapon_description(type)` → `codex.weapon.<id>.name/desc` + `ui.player.loadout.*` (yükseltme / yeni silah metni).

### Level-up havuzu
- **`ui/upgrade_ui.gd`**
  - `WEAPON_UPGRADE_IDS` / `ITEM_UPGRADE_IDS` dizileri `player.gd` içindeki `_LEVELUP_*` listeleriyle uyumlu olmalı.
  - Arayüz: üç sütun (envanter ızgarası + dikey kartlar + istatistik / meta özeti); veri `Player` ve `SaveManager` üzerinden; envanter slotlarında `tooltip_text`.
  - **`ui/upgrade_ui.tscn`**: Kök altında **`EditorRoot`** varsa düzen (`MarginContainer` / kartlar / butonlar) editörden taşınır; betik `_bind_editor_root` ile bağlanır; yoksa kod `_build_ui_shell()` ile oluşturur. Reroll/skip: `player.run_levelup_rerolls_left` / `run_levelup_skips_left` **koşu boyunca** azalan havuz (meta `reroll_bonus` / `skip_bonus` yalnızca koşu başı toplamına eklenir). Temel slot 6+6; meta `weapon_slot_bonus` / `item_slot_bonus` en fazla 2’şer rank (+1 slot/rank).
  - Yeni yüzey metinleri (dil dondurması sırasında): `locales/en.json` → `ui.upgrade_ui.*`.
  - İkon PNG’leri: `assets/ui/upgrade_icons/` (alt klasörler + `README.txt`); yükleme `UpgradeIconCatalog` (`core/upgrade_icon_catalog.gd`). Toplu ham PNG düşümü için geçici klasör: **`assets/inbox/`** (`README.txt`) — buradan hedef alt klasörlere taşınıp sahne/kod bağlanır.
  - **Denge / ölçek taslağı:** `docs/OLCEKLEME_ONERI.md` — alan/süre/magnet için `%` vs düz (+N) çerçevesi ve örnek tablo (ürün kararına göre kodla birleştirilir).
  - **Aura görsel halkası** (`weapon_aura.gd`): `AuraWeaponRing` artık **silah düğümünün** çocuğu (`add_child` silahta); level-up önizlemesi yeni silah için oyuncuya geçici child eklemez (kodeks metni).
  - **Bağlayıcı Halka alan göstergesi** (`weapon_binding_circle.gd`): `BindingCircleRing` → `assets/projectiles/binding_circle/glyph.png`; ölçek `radius × get_area_multiplier()` (Aura’daki otomatik dış yarıçap yaklaşımı); `get_player_vfx_opacity()`.
  - **Hisar Zinciri alan göstergesi** (`weapon_citadel_flail.gd`): `CitadelFlailRangeRing` → `assets/projectiles/citadel_flail/head.png`; aynı ölçek / opaklık politikası (`binding_circle` ile paralel).

### Evrim
- **`weapons/weapon_evolution.gd`**
  - `EVOLUTIONS`: `requires_weapons`, `requires_items`, `name`, `description`; isteğe bağlı `weight` (level-up havuzunda ağırlık, varsayılan `10.0`).
  - `is_evolution_ready(player, evo_id)`: Tek doğrulama kaynağı (silah/eşya MAX, evrim henüz yok).
  - `get_available_evolutions(player)`: Hazır evrimleri döndürür; sıra **karıştırılır** (aynı ekranda birden fazla evrim adil görünsün).
  - `localized_name` / `localized_description`: `ui.evolution_defs.<id>.name|desc`; çeviri yoksa sözlükteki `name` / `description`.
- **`player/player.gd`** → `evolve_weapon`: Önce `is_evolution_ready`; sonra sadece **`requires_weapons`** silahlarını kaldırır; **eşyalar kalır**. Yüzen metin: `ui.upgrade_ui.evolution_floating`.
- **`ui/upgrade_ui.gd`**: Evrim kartı başlığı `ui.upgrade_ui.evolution_pick_title`; cog shard **4 seçenek** (kart havuzu `pick_count`); reroll aynı `pick_count` ile çalışır.
- **Locale**: Yeni evrim → `locales/*.json` içinde `ui.evolution_defs.<evo_id>` (`name`, `desc`) + mümkünse `gen_locales.py` (tr/en).

### Özel davranışlar
- **Kaos** karakteri: `apply_character_bonuses` içinde `random_weapons` listesine yeni taban silah eklenmeli.
- **Projectile + ObjectPool**
  - Sahne yolu `ObjectPool.get_object(...)` ile alınır; `ObjectPool.return_object` önce `hide()` sonra `reset()` çağırır (`core/ObjectPool.gd`). Havuz **ilk doldurulurken** de `hide()` + `reset()` (aynı dosya) — gizli nesnede sahne dosyasından gelen çarpışma kalmasın.
  - **Havuzda `Area2D` çarpışması:** Yalnız `visible = false` yetmez; özellikle `area_entered` kullanan mermiler (`bullet.gd`, `dagger.tscn`) gizliyken de tetiklenebilirdi. Kural: **`reset()` sonunda `collision_layer` / `collision_mask` = 0** (ve gerekirse `lightning_bolt` gibi aynı politika); **`init()`** (veya eşdeğeri) sahneye uygun katman/maskeyi yeniden yazar. Uygulanan örnekler: `bullet.gd`, `lightning_bolt.gd`, `fan_blade_shard.gd`, `hunter_axe.gd`, `ice_ball.gd`, `enemy_bullet.gd`, `effects/gold_orb.gd`, `effects/xp_orb.gd`.
  - **`fan_blade_shard`:** `set_deferred("monitoring", false)` kaldırıldı — kuyruk, sonraki `init()` ile yarışıp shard’ı yanlışlıkla susturabiliyordu; havuzda `collision_layer = 0` yeterli.
  - **Yelpaze shard oynanışı:** menzil = `fire_range × get_area_multiplier`; ömür = menzil ÷ `shard_speed`; `_physics_process` adımı `_max_travel` ile sınırlı; spawn `player.get_directional_attack_spawn` (sprite silüeti).
- **Taban projeksiyon / silah VFX dokuları** (`assets/projectiles/`): Aura halkası `weapon_aura.gd` (oyuncuya `AuraWeaponRing`); hasar yarıçapı ile dış hizası için silah kökünde **`aura_outer_radius_texels`** / **`aura_outer_texel_auto_factor`** (0 pikselde otomatik dış yarıçap ≈ doku × 0,5 × faktör; meta alan `get_area_multiplier()` ile hem hasar hem halka). Zincir segmenti `CombatProjectileFx.spawn_chain_segment` (`effects/combat_projectile_fx.gd`, `weapon_chain.gd`; sıçrama arası **`chain_step_delay_sec`**; segment başına **Sprite2D** + `chain.png`, mesafe boyunca `scale.x`, yön `rotation`; dikey doku için `CHAIN_TEX_LINKS_ALONG_WIDTH := false`); yıldırım sahnesi **`effects/lightning_hit_fx.tscn`** (+ `lightning_hit_fx.gd`): editördeki `texture` / `scale` korunur, `run()` yalnızca renk / süre uygular; `CombatProjectileFx.spawn_lightning_style_flash` (`weapon_storm.gd`, `weapon_toxic_chain.gd`); yıldırım **silah vuruşu** `projectiles/lightning_bolt.tscn` (ObjectPool; görsel: kamera üst çizgisinde hedef X’inde spawn, düşüş; isabet `lightning_hit_fx`; `weapons/scenes/weapon_lightning.tscn` oyuncu üstü sprite yok; hedef havuzu `GameplayConstants.MAX_COMBAT_RADIUS_PX` — `core/gameplay_constants.gd`, co-op centroid tavanı ile aynı); savrulan balta `projectiles/hunter_axe.tscn` + `assets/projectiles/axe/boomerang.png`. **Not:** Kayıtlı silah kimliği hâlâ `boomerang`; oyuncuya dönük metinlerde “Balta” / “Axe” (`locales`, kodeks). Yeniden üretilebilir silah sahneleri: `python tools/gen_weapon_scenes.py`.

---

## 5. Pasif eşya (item) sistemi

### Taban
- **`items/passive_item.gd`** — `PassiveItem`: `category`, `apply()`, `upgrade()`, isteğe bağlı `on_damage_dealt` için `EventBus` bağlantısı.

### Oyuncuya bağlama
- **`core/player_loadout_registry.gd`** — `ITEM_SCRIPT_BY_ID` + `create_item(id)`.
- **`player/player.gd`**
  - `add_item(type: String)` → `PlayerLoadoutRegistry.create_item(type)`.
  - `_on_upgrade_chosen` → item ID listesi ile uyumlu olmalı.
  - `get_item_description(type)` → `codex.item.<id>.name/desc` + `ui.player.loadout.*`.
  - Oyun olayları: örn. `on_enemy_killed` içinde `active_items.has("...")` ile özel item metodu çağrısı.
  - **Kan havuzu dünya görseli** (`items/item_blood_pool.gd`): `blood_pool_ripple.png` sahneye `player.get_parent()` altına eklenir — **`main/main.tscn` zemini `Sprite2D` `z_index=-1`** olduğundan havuz **`z_index=-2`** gibi değerler zeminin *altında* kalır / görünmez; dünya leke efektleri **`z_index` 0 veya üzeri** kullan (`item_explosion` varsayılan 0 ile çalışır).

### Dünya ödülleri
- Örn. **`effects/chest.gd`** içindeki rastgele item listeleri; boss / dalga ödülleri varsa aynı ID tutarlılığı.

---

## 5a. Koleksiyon (bestiary / kodeks)

- **`core/collection_data.gd`** — Sekmeler: `TAB_ENEMY`, `TAB_BOSS`, `TAB_WEAPON`, `TAB_ITEM`, `TAB_CHARACTER`, `TAB_MAP`, `TAB_WORLD_ITEM`, `TAB_GLOSSARY`. Tablo dizileri: `ENEMY_ENTRIES`, `BOSS_ENTRIES`, `WEAPON_ENTRIES`, `ITEM_ENTRIES`, `MAP_ENTRIES`, `WORLD_ITEM_ENTRIES`; kahramanlar **`character_entries()`** ile `CharacterData.CHARACTERS` üzerinden üretilir (emoji + `accent` = karakter rengi). `all_entries()`, `entries_for_tab(tab)`, `total_entry_count()`, `has_bestiary_id()` (sadece ölüm kaydı). `WORLD_ITEM_ENTRIES` kaynağı: `docs/colorrect.md` Dünya/spawn cisimleri.
- **Kodeks kart / detay görseli:** `core/codex_icon_catalog.gd` — sırayla `codex_icons`, `codex_art`, sekmeye özel yollar (kahraman `codex.png`, harita önizlemesi, düşman/boss sprite eşlemesi, `glossary_icons`), ardından **silah/eşya** için `assets/ui/upgrade_icons/` (`core/upgrade_icon_catalog.gd`; evrim sonucu silahlar için `evolutions/<id>.png` ve `shadow_storm` → `storm_shadow.png` takması). PNG yoksa emoji. Ayrıntı: `assets/ui/codex_icons/README.txt`, `assets/ui/codex_art/README.txt`. Harita önizleme yolu: `CodexIconCatalog.MAP_PREVIEW_TEXTURES` / `map_preview_path` (harita seçimi ile aynı).
- **`SaveManager`**: `codex_discovered` (düşman/boss), `codex_weapons`, `codex_items`, `codex_maps`; `is_codex_entry_unlocked(entry)` tek doğrulama; `register_codex_*` aileleri. **Tüm ilerlemeyi sıfırla** dört kodeks dizisini de temizler.
- **Keşif tetikleyicileri:** düşman ölümü `enemy_base` / `boss` / `giant`; silah ve eşya ilk alımda **`player/player.gd`** `add_weapon` / `add_item`; harita **`ui/map_select.gd`** oyun başlatırken `register_codex_map`; kahramanlar **`unlocked_characters`** (kilit açılmadan kart gizli).
- **Yeni düşman:** `.tscn` + `ENEMY_ENTRIES`/`BOSS_ENTRIES` + `codex.<id>.name/desc` (düşman/boss düz anahtar).
- **Yeni silah / eşya / harita:** `WEAPON_ENTRIES` / `ITEM_ENTRIES` / `MAP_ENTRIES` + `codex.<weapon|item|map>.<id>.name/desc` — **dil dondurması sırasında** yalnızca `codex_extensions_en.json` → `merge_codex_extensions.py` ile `en.json`’a birleştir; `tr` / `zh_CN` şimdilik elleme. (Tam dil turunda yine `{en,tr,zh_CN}` akışı.)
- **Yeni kahraman:** `CharacterData`’ya ekle; `codex.character.<id>` — dondurma sırasında **`codex_extensions_en.json`** (ve `en.json` birleşimi); diğer diller raf.
- **UI:** `ui/collection_menu.gd` — üstte sekmeler (`ui.collection_menu.tab_*`); ana menü **`ui/main_menu.gd`** → Kodeks; grid + detayda `CodexIconCatalog.try_for_entry`.

---

## 6. Harita ve mod seçimi

- **`ui/map_select.gd`**: Run modu **`SaveManager.settings["run_variant"]`** (`story` / `fast` / **`arena`** — kısa hedef süre `SaveManager.ARENA_RUN_GOAL_SEC`); harita listesi + önizleme; **`run_curse_tier`** (0–`SaveManager.RUN_CURSE_TIER_MAX`, varsayılan **1**) kaydı; **Başlat** → `SaveManager.selected_map` / mod alanları + `register_codex_map`. **Referans kademe:** `SaveManager.RUN_CURSE_REFERENCE_TIER` (**1**) — denge bu kademe etrafında; `run_curse_tier_delta()` = `tier − REF`. Spawn: `get_run_spawn_difficulty_mult()` = `1 + RUN_CURSE_SPAWN_PER_TIER × delta`. Düşman: `get_run_curse_enemy_hp_mult()` / `get_run_curse_enemy_speed_mult()`; XP dilimi: `player.gain_xp` içinde `RUN_CURSE_XP_GAIN_PER_TIER × delta`. **Dalga düşmanı (normal / sürü / çember):** `main/spawn_manager.gd` — zaman scaling’inden sonra `FIRST_MINUTE_ONE_SHOT_SEC` (**60**) içinde **1 HP** (tek vuruş); sonrasında zaman scaling’ine ek **`MOB_GLOBAL_*`** can / hasar / hız çarpanları (`get_global_mob_*_mult()`). Mini boss / Reaper: yalnızca koşu laneti katmanı (`_apply_run_curse_tier`), global mob buff yok. **Koşu laneti UI:** `tr_en_source` + `ui/run_curse_stat_bar.gd`; `run_curse_*_percent_for_tier()` önizleme (**2026-04-23**).
- Yeni **hikaye haritası**: Yeni buton + `selected_map` string ID + `main` veya ortam tarafında bu ID’ye göre sahne/tileset/spawn mantığı.
- **Arena**: `map_select` içinde kilitli; dalga mantığı `YOL_HARITASI.md` planı ile genişletilecek.

---

## 7. UI ve metin (label)

| Alan | Tipik dosya |
|------|-------------|
| Açılış ekranı | `ui/intro_splash.gd` / `.tscn` — `FullRect`; prompt `PROMPT_ANCHOR_*` / `PROMPT_OFF_*` (4–6. sn tween); `MainMenuBackground.load_texture()`; tint yok; siyah overlay ~5 sn; müzik track 1; `ui.intro_splash.press_to_start` |
| Ana menü | `ui/main_menu.gd` / `.tscn` — arka plan: `BackgroundBase` + isteğe bağlı `BackgroundPhoto` (`MainMenuBackground` / `assets/ui/main_menu_bg.png|.jpg|.webp`) + `BackgroundTint` + `StarsLayer`; `assets/ui/README_MAIN_MENU_BG.txt` — **metal buton kapakları:** §7.1 |
| Mağaza (iskelet) | `ui/shop_menu.gd` / `.tscn` |
| Karakter seçimi | `ui/character_select*.tscn` + `character_select.gd` / `character_select_p2.gd`, `character_select_helpers.gd`, `character_select_preview.gd`, `character_select_stats_panel.gd` — portre/cache aynı; sağ sütunda seçime göre istatistik özeti; `game_mode_select.gd` → `warmup_portraits_async`; ESC: P1→`game_mode_select`, P2→`character_select` |
| Harita | `ui/map_select.gd` |
| Level-up | `ui/upgrade_ui.gd` — kart ikonları `UpgradeIconCatalog` (`assets/ui/upgrade_icons/README.txt`); silah envanter slotu evrim PNG yedeği: `try_weapon_with_evolution_fallback` |
| HUD (kill, altın, XP, silah/eşya ızgarası) | `player/player.gd` + `player` sahnesindeki `CanvasLayer` (`StatsRow`, `XPBar`, **`CategoryPanel`** → `PlayerUiHelpers.rebuild_run_loadout_hud`) |
| Oyun sonu / duraklat | `ui/game_over.gd`, `pause_menu.gd` — duraklatmadan **Ayarlar** → tam `settings.tscn` (`meta from_game`), geri `restore_after_settings()` |
| Meta upgrade | `ui/meta_upgrade.gd` + `meta_upgrade.tscn` — `OuterMargin` + üst `VBox`, kart alanı `ScrollContainer` ile kaydırılabilir |
| Koleksiyon (kodeks) | `ui/collection_menu.gd` / `.tscn` |
| Ayarlar | `ui/settings.tscn` + `settings.gd` (+ `settings_ui_styles.gd`); ana menü ve koşu içi duraklat aynı sahne — koşu: `set_meta("from_game", true)` (`pause_menu`), geri `ui.pause.back`; **Ses:** müzik parça satırı + `music_volume`; ESC: `MenuInput` |

**Yeni bir Label / buton:** İlgili `.tscn` düğümü + `.gd` içinde `onready` veya `%UniqueName` ile referans.

### 7.1 Buton kapakları (`StyleBoxTexture`, `button1`–`3`)

**Ortak sınıf:** `ui/button_cover_styles.gd` (`class_name ButtonCoverStyles`) — `button1.png` / `button2.png` / `button3.png` preload; `apply(...)`, atlas `Rect2(2, 188, 507, 134)`, yatay `texture_margin_left/right` = **104**, dikey margin **0**. Menülerde çeşitlilik için kapak indeksi **0 / 1 / 2** dönülür.

**Ana menü:** `ui/main_menu.gd` — `_build_ui` + `_apply_texts`; buton başına kapak `_main_menu_cover_variant(btn)` ile atanır; punto / `content_margin` hâlâ `_main_menu_button_font_size` ve `_main_menu_button_text_inset`.

| Ne | Nerede |
|----|--------|
| **PNG’ler** | `assets/button covers/README.txt` |
| **Yeni PNG / atlas** | `ButtonCoverStyles.atlas_region_for(tex)` — üç dosya aynı 512² düzeni varsayar; farklı kırpma gerekiyorsa bu fonksiyonda `tex` yoluna göre dal ekle. |

**Başka bir `buttonX.png` denemek — kısa checklist**

1. PNG’yi `assets/button covers/` altına koy; `ButtonCoverStyles` içindeki `_covers` / preload listesine ekle.
2. Opak bbox’ı `atlas_region_for` ile hizala (gerekirse Pillow `getbbox()`).
3. Sivri uç genişliğine göre `stylebox_from_cover` içindeki `texture_margin_left` / `right` ayarla; dikey dikiş istemiyorsan üst/alt **0** kalsın.
4. İlgili menüde `apply(..., text_inset, font_size)` ile metni çerçeveye oturt.

Tasarım envanteri satırı: `docs/TASARIM.md` → **UI, HUD ve menüler** → Ana menü.

---

## 8. Orb ve toplanabilir nesneler (pickup)

Mevcut örnekler: **`effects/xp_orb.tscn`**, **`effects/gold_orb.tscn`**. İkisi de `Area2D` tabanlı; **ObjectPool** ile alınıp `return_object` ile havuza döner.

### Mevcut bağlantılar (referans)

- **Düşürme:** `enemies/enemy_base.gd` — ölüm sonunda **`resolve_death_loot()`**: XP / altın / sandık / nadir pickup için **tek ağırlıklı seçim** (aynı ölümde çoğul bağımsız düşürme yok); **~%1** ile en fazla **iki** ayrı tür. Sandık ağırlığı normal akışta `normal=0.01`, `elite=0.20` tutulur (geçici test boost’ları iş bitince geri alınır). `boss` / `giant` / `exploder` özel sonlar `resolve_death_loot` veya `super._on_death_complete` ile hizalı. `ObjectPool.get_object("res://effects/....tscn")`.
- **Ortam:** `main/environment_manager.gd` — ağaçta kalan `xp_orbs` / `gold_orbs` grupları üzerinde işlem (ör. temizlik). Dünya spawn görselleri `assets/effects/*` ile asset-backed: `vacuum_collector`, `poison_trap`, `shrine_risk/devil`, `destructible_crate_low/high`, `ruin_cache_low/mid/high`, `blood_oath`. `crate` low/high dönüşümlü spawn edilir; `ruin_cache` low/mid/high tier ile spawn edilir ve `high` tier ek upgrade/altın verir. Okunabilirlik pass’inde bu dünya/spawn pickup görselleri (XP/Gold hariç) sahada `4x` ölçekle gösterilir.
- **Sandık etkileşimi:** `effects/chest.tscn` + `effects/chest.gd` — yerde `chest.png`, yakında `E` veya `ui_accept` ile açılış overlay’i; tek merkez panel akışı: `chest_opening_animation.png` ilk kare (kapalı sandık) + `OPEN` (beklemede hafif sallanma) -> aynı sprite üstünden 40 FPS açılış animasyonu -> son kare sabitken `5.0s` item/weapon roulette (ilk 3s hızlı, son 2s kademeli yavaş) -> ödül kartı (`TAKE`/`DISCARD`). Ödül `item/weapon/gold/heal` olarak seçilir ve yalnız `TAKE` ile uygulanır.
- **Havuz boyutu:** `core/ObjectPool.gd` — yol içinde `xp_orb` veya `gold_orb` geçen sahneler için havuz **40** öğe (diğerleri 20).

### Yeni bir orb (veya pickup) türü eklerken — checklist

1. **`effects/<isim>_orb.tscn` + `.gd`** — `Area2D`; çarpışma / toplama mesafesi; oyuncuya yaklaşma mantığı (mıknatıs: `player.get_magnet_bonus()` veya sabit yarıçap).
2. **`init` / `reset`** — Pool ile uyum: `reset()` içinde hız, pozisyon, görünürlük, grup üyeliği sıfırlanmalı; **`Area2D` ise havuzda `collision_layer` / `collision_mask` = 0**, tekrar kullanımda `init()` ile `.tscn` ile aynı değerlere dön (`gold_orb` / `xp_orb` dahil). `ObjectPool.return_object(self)` toplandığında veya ömür bittiğinde çağrılmalı.
3. **`add_to_group` / `remove_from_group`** — Örn. `"xp_orbs"`, `"gold_orbs"` gibi; **pausa, temizlik veya istatistik** için grupları kullanan kod varsa (`environment_manager` vb.) yeni grup adını oraya da ekle.
4. **Düşürme noktaları** — Hangi düşman / sandık / olay bu orb’u üretecekse orada `get_object` ile sahne yolu; gerekirse değer parametresi (`xp_value`, `value` gibi) `init` ile verilir.
5. **Oyuncu tarafı** — Toplanınca `player.gain_xp`, `collect_gold`, `heal`, yeni bir metot veya `EventBus` emit; co-op’ta P1/P2 paylaşımı **mevcut orb’lardaki gibi** düşünülmeli.
6. **`ObjectPool.gd`** — Çok yoğun sahne ise yeni sahne yolu için havuz boyutu kuralı gerekebilir (şu an sadece xp/gold için özel sayı var).
7. **`docs/TASARIM.md`** — Yeni pickup/orb için görsel envanter satırı; tamamlanınca işaretle.
8. **`docs/YOL_HARITASI.md`** — Özellik teslim edildiyse **Yapılan iş günlüğü**ne kısa satır.

Yeni orb kodu için başlangıç: `xp_orb.gd` / `gold_orb.gd` ve `.tscn` şablonu.

---

## 9. Checklist: yeni karakter

**Tam kahraman paketi (önerilen):** İmza kahraman isteniyorsa tek seferde **taban silah + (isteğe bağlı) başlangıç pasifi + silah evrimi** tasarlanmalı; pasif **evrim için gerekli** olsa da tek başına **faydalı ama abartısız** kalmalı (§11 + `weapon_evolution.gd`). Gerekli dosyalar: silah için §10, eşya için §11, evrim için §12 (veya mevcut evrime bağlama).

**Kapanış çıktısı (zorunlu alışkanlık):** Kahraman ekleme veya loadout metni güncellemesi bittiğinde, sohbetin **sonunda** kullanıcıya tek blok halinde **bilgi kartı** ver — sıra sabit:

1. **karakter adı:** `id` — görünen ad (örn. `ironclad` — Tam Zırhlı)  
2. **karakter classı:** `hero_class` (örn. `fighter`)  
3. **silah:** `start_weapon` (kısa ad — bir satırlık özet; örn. `bastion_flail` (Kale Gürzü — alan + itme))  
4. **eşya:** `start_item` veya yoksa `—` (örn. `rampart_plate` (Rampa Plakası — zırh))  
5. **evrim silahı:** evrim sonucu ID veya `—` (örn. `citadel_flail` (Hisar Zinciri))

Oyun içi uzun `description` / `codex.character.<id>` metni (Açılış, origin vb.) veride ayrıca kalabilir; sohbet özeti bu beş satırlık şablondur. Yerelleştirme güncellemesi yalnızca `en` + `codex_extensions_en` (bkz. § «Yerelleştirme» — dil dondurması).

1. `core/character_data.gd` — yeni sözlük (ID benzersiz, `hero_class` zorunlu: `tank` / `fighter` / `mage` / `controller` / `special`).
2. `characters/<id>/<id>.tscn` — sahne (script `player.gd` uyumu). **Her kahramanın kendi `.tscn` dosyası zorunlu**; başka kahramanın dosya yolunu `CHARACTER_SCENE_BY_ID` ile paylaşma. Başlangıç için başka sahneden kopya alındıysa: `AnimatedSprite2D` → **SpriteFrames** içinde **animasyon adları** (`idle_left`, `idle_right`, `walk_left`, `walk_right` vb.) kalsın, her animasyondaki **frame** girişlerini sil (boş `frames` listesi); böylece yinelenen atlas / yüzlerce `SubResource` taşınmaz — görseli sonra `dusk` örneği gibi bu sahneye eklersin.
3. `core/character_data.gd` — `CHARACTER_SCENE_BY_ID` + `get_character_scene_path` (yeni `id` → `.tscn` yolu).
4. Gerekirse `save_manager.gd` — varsayılan kilit/purchase (çoğu karakter sadece veri + koşul ile gelir); **yeni `unlock_condition["type"]`** ise `check_and_unlock_characters` `match` kolu + gerekirse kalıcı alan (`save_game` / `load_game`).
5. `locales/en.json` + `locales/codex_sources/codex_extensions_en.json` — `codex.character.<id>`; `ui.character_select.special.*` yalnızca `special` doluysa. (`tr` / `zh_CN` / diğer `codex_extensions_*` rutin güncellenmez — dil dondurması.)
6. `core/collection_data.gd` — `_char_emoji` (kodeks grid).
7. `CHARACTERS` sırası değişecekse: `SaveManager.OLD_CHARACTER_ORDER` sonuna `id` ekle; kayıtlı indeks migrasyonu veya ID tabanlı seçim.

---

## 10. Checklist: yeni taban silah

1. `weapons/weapon_*.gd` + `class_name`.
2. **Tekillik çifti (`gravity_anchor` / `void_lens`):** `weapons/center_cataclysm_helper.gd` — ekran ortası büyüme tween’i + yarıçap içi instakill; süre/menzil sabitleri ilgili `weapon_*.gd` içinde. Dokular `assets/projectiles/gravity_anchor/`, `void_lens/`. Evrim ikonu `void_lens` → `assets/ui/upgrade_icons/evolutions/void_lens.png`.
3. **Kale gürzü (`bastion_flail`):** `weapons/scenes/weapon_bastion_flail.tscn` — `OrbitPivot`, `Sprite2D`, `FlailHitbox`; mantık `weapon_bastion_flail.gd`.
4. `core/player_loadout_registry.gd` — `WEAPON_SCRIPT_BY_ID` içine aynı string ID.
5. `player/player.gd` — `_LEVELUP_WEAPON_IDS` (ve Kaos için `random_weapons` listesi); açıklama `get_weapon_description` → `codex`.
6. `ui/upgrade_ui.gd` — `WEAPON_UPGRADE_IDS`, `ITEM_UPGRADE_IDS`, `get_upgrade_text` (yardımcı / hata ayıklama).
7. Varsa projectile: `projectiles/*.tscn` + script, `ObjectPool` uyumu; hedef seçiminde tercihen `EnemyRegistry.get_enemies()`.
8. Kaos: `apply_character_bonuses` içindeki `random_weapons` listesi.
9. `core/collection_data.gd` — `WEAPON_ENTRIES` (kodeks sekmesi).
10. `locales/en.json` + `locales/codex_sources/codex_extensions_en.json` — `codex.weapon.<id>.name/desc` (dil dondurması: yalnız İngilizce dosyalar).

---

## 11. Checklist: yeni pasif eşya

1. `items/item_*.gd` + `class_name`.
2. `core/player_loadout_registry.gd` — `ITEM_SCRIPT_BY_ID` satırı.
3. `player/player.gd` — `_on_upgrade_chosen` ve oyun döngüsü kancaları (`on_enemy_killed`, `take_damage`, `_process` vb.); açıklama `codex` + `ui.player.loadout`.
4. `ui/upgrade_ui.gd` — `ITEM_UPGRADE_IDS`, `get_upgrade_text`.
5. Sandık/boss/dalga ödül listeleri (kullanılacaksa).
6. Evrim gereksinimi olacaksa `weapon_evolution.gd` — `requires_items`.

---

## 12. Checklist: yeni evrim silahı

1. `weapons/weapon_*.gd` (evrim sonucu silah).
2. `weapon_evolution.gd` — `EVOLUTIONS` girişi.
3. `core/player_loadout_registry.gd` — `WEAPON_SCRIPT_BY_ID` içine evrim silahı ID’si (örn. `ember_fan`).
4. `player/player.gd` — `_on_upgrade_chosen` `match` listesinde evrim ID’si (gerekirse).
5. `codex` + `ui.evolution_defs` / `get_weapon_description` (gerekirse).
6. `locales/en.json` — `ui.evolution_defs.<evo_id>` (`name`, `desc`); `codex_extensions_en.json` gerekirse. (`tr` / `zh_CN` donduruldu.)

---

## 13. İlgili klasörler (kısa)

- `main/` — Oyun sahnesi, spawn, dalga, kamera, co-op HUD tetikleri.
- `enemies/` — Düşman davranışı, ölüm, orb düşürme.
- `effects/` — Sandık, parçacık benzeri efektler.
- `projectiles/` — Oyuncu / düşman mermileri.
- `core/` — Kayıt, karakter verisi, kategori bonusları, havuz, `EnemyRegistry`, `PlayerLoadoutRegistry`.
- `player/` — `player.gd` + `player_ui_helpers.gd` (level-up VFX, hız sinerjisi izi; koşu içi ayrı HUD istatistik paneli yok — level-up / upgrade ekranında özet).
- `weapons/`, `items/` — Oyun içi ekipman mantığı.

---

## 14. Son not

Bu rehber, kod tabanındaki gerçek yapıya göre yazılmıştır; yeni sistem eklendikçe **ilgili bölüm güncellenmelidir**. Özellikle string ID eşlemeleri (`match` blokları) unutulursa içerik oyunda görünür ama seçilemez veya çalışmaz. **`docs/YOL_HARITASI.md`**, **`docs/TASARIM.md`** ve erişilebilirlik matrisi ile birlikte yaşayan belgeler olarak tutulmalıdır.

---

## 15. Erişilebilirlik ve devamlılık referansları

**20+20 madde — kod durumu (Var/Kısmi/Yok + repo notu):**  
`docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`

`docs/TASARIM.md` — ses ve UI ile ilgili ürün hedefleri (§15 dışı). Dosya/tetik envanteri: `docs/sesler-muzikler-efektler.md`.

### `SaveManager.settings` anahtarları (`core/save_manager.gd`)

| Anahtar | Tip | Açıklama |
|---------|-----|----------|
| `master_volume` | float | Ana ses (0–1) |
| `sfx_volume` | float | Efekt bus |
| `music_volume` | float | Müzik bus |
| `combat_music_duck` | bool | Varsayılan **kapalı**; açıkken silah saldırısı başına kısa müzik hattı kısılması (`AudioManager.notify_combat_music_duck_beat`); **Ayarlar → Ses** |
| `fullscreen` | bool | Tam ekran |
| `resolution_x` | int | Pencere genişliği (pencereli mod) |
| `resolution_y` | int | Pencere yüksekliği |
| `show_vfx` | bool | Birçok düşman/efektte VFX aç/kapa |
| `performance_quality` | String | `"high"` / `"medium"` / `"low"` — düşman üst sınırı, sürü/kuşatma yoğunluğu, ağır VFX/partikül (`SaveManager.get_max_enemies_cap()`, `is_heavy_vfx_enabled()`, …) |
| `screen_shake` | bool | Ekran sarsıntısı |
| `player_vfx_opacity` | float | Oyuncu tarafı görsel efekt opaklığı çarpanı (0–1); `player.get_player_vfx_opacity()` |
| `damage_numbers` | String | `"both_on"`, `"player_only"`, `"enemy_only"`, `"both_off"` |
| `hp_bars` | String | Aynı seçenek kümesi |
| `locale` | String | Arayüz dili: `LANGUAGE_CATALOG` içindeki `code` (örn. `tr`, `en`, `zh_CN`); `LocalizationManager` yazar/okur. |
| `pause_on_focus_loss` | bool | Koşu sırasında pencere odağını kaybedince otomatik duraklat (varsayılan açık); **Ayarlar → Oynanış**; `main/main.gd`. |
| `enemy_high_contrast_outline` | bool | Düşmanlarda sarı siluet/çerçeve (yalnız yeni spawn); **Ayarlar → Görüntü**; `enemy_base.gd` `_setup_visuals()`. |
| `input_keyboard_overrides` | Dictionary | İsteğe bağlı klavye eşlemesi: eylem adı (`ui_up`, …) → fiziksel tuş kodu (`int`); `core/input_remap.gd`. |

**UI:** `ui/settings.gd` — Sekmeler: Ses (**`combat_music_duck`** anahtarının etiketi `LocalizationManager.tr_en_source` ile yalnız EN metin dosyasından), **Dil** (`locale`), **Görüntü** (`fullscreen`, çözünürlük, VFX, `performance_quality`, `enemy_high_contrast_outline`), **Oynanış** (`damage_numbers`, `hp_bars`, `screen_shake`, `pause_on_focus_loss`, `player_vfx_opacity`), **Kontroller** (tuş yeniden atama, `InputRemap`), Profil, Dev. **Tam ekran kısayolu:** `toggle_fullscreen` (F11) → `SaveManager._unhandled_input`.

### `InputRemap` (`core/input_remap.gd`)

Oyun başında projedeki `InputMap` anlık görüntüsünü alır; `SaveManager.settings["input_keyboard_overrides"]` ile klavye `InputEventKey` olaylarını listedeki eylemler için uygular (`REMAPPABLE_ACTIONS`). Oyun kolu `InputEventJoypad*` olayları silinmez. Sıfırlama: Ayarlar → Kontroller → “varsayılana dön” veya tam ilerleme sıfırlama (`ui/settings.gd`).

### Yeni ayar / kontrol eklerken

1. `core/save_manager.gd` → `settings` sözlüğüne **varsayılan** değer.
2. `ui/settings.gd` → doğru sekmeye `_add_toggle` / `_add_slider` / `_add_dropdown` (`_build_*_tab`).
3. Oyun mantığında `SaveManager.settings.get("anahtar", varsayılan)`; callback’lerde `SaveManager.save_game()`.
4. Tuş eşlemesi ekleniyorsa: `InputRemap.REMAPPABLE_ACTIONS`, `ui.settings.bind_*` ve `tab_controls` (tüm `LANGUAGE_CATALOG` dilleri); `python locales/check_locale_parity.py`.

### XP sesi (`pitch_scale`)

`core/audio_manager.gd` → `play_xp()`: Her toplamada `xp_player.pitch_scale` pentatonik dizi (`xp_notes`) ile ayarlanır; kısa süre sonra `xp_note_index` sıfırlanır (`_process`). Ürün maddeleri: `docs/TASARIM.md` § Ses tasarımı; teknik envanter: `docs/sesler-muzikler-efektler.md`.

Ayar anahtarları veya matris satırı değişince **`docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`** ile senkron tut.
