# Ironfall — Geliştirici rehberi

Bu belge, projenin **nasıl işlediğini**, dosyaların **birbirine nasıl bağlandığını** ve **yeni içerik eklerken izlenmesi gereken yolları** özetler.  
*(İngilizce projelerde eşdeğeri genelde `ARCHITECTURE.md`, `DEVELOPER_GUIDE.md` veya `docs/CONTRIBUTING.md` olarak adlandırılır.)*

**Motor:** Godot 4.x  
**Son güncelleme:** 2026-04-09

### Dokümantasyonu ne zaman güncellemeliyiz?

Oyuna veya teknik yapıya dokunan her önemli değişiklikten sonra:

1. **`docs/GELISTIRICI_REHBERI.md`** — Yeni bir *tür* içerik eklediysen (ör. yeni orb, yeni pickup, yeni harita akışı) ilgili **checklist veya bölümü** ekle veya mevcut maddeleri güncelle. Sadece küçük denge değişikliği ise yalnızca etkilenen paragrafı düzeltmen yeterli olabilir.
2. **`docs/YOL_HARITASI.md`** — Planlanan bir iş bittiyse: öncelik tablosunda `[x]` yap veya maddeyi kaldır; **Yapılan iş günlüğü**ne tarih ile kısa satır ekle. İptal edilen işleri not düşerek çıkar.
3. **`docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`** — Erişilebilirlik veya bağlılık maddelerinden birinin **Var/Kısmi/Yok** durumu kodda değiştiyse ilgili tablo satırını güncelle.
4. **`docs/TASARIM.md`** — Envanterdeki bir madde teslim edildiyse veya yeni kalem eklendiyse ilgili satırları güncelle.
5. **`docs/KARAKTER_SINIFLARI_VE_TASARIM.md`** — Karakter **sınıfı**, co-op destek vizyonu veya sınıf–kahraman tablosu değiştiyse güncelle.
6. **`locales/*.json`** — Yeni metin veya anahtar: katalogdaki **tüm** dil dosyalarına aynı anahtarı ekleyin; `python locales/check_locale_parity.py` ile `en.json` referansına göre anahtar eşitliğini doğrulayın.
7. **`README.md`** — Kurulum / çalıştırma / repo yapısı değiştiyse ana sayfayı güncelle.
8. **`docs/lore.md`** — Evren, karakter ve düşman anlatısı netleştikçe veya yeni içerik lore ile bağlanacaksa ilgili bölümü güncelle.

*(IDE’de Cursor kullanıyorsan: `.cursor/rules` altındaki `ironfall-docs.mdc` kuralı bu disiplini hatırlatır.)*

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
| **SaveManager** | Altın, seçili karakter/harita, meta upgrade’ler, ayarlar (`locale` dahil), kilit / satın alınmış karakter listeleri, istatistikler; kodeks: **`codex_discovered`**, **`codex_weapons`**, **`codex_items`**, **`codex_maps`**. |
| **LocalizationManager** | `LANGUAGE_CATALOG` + `locales/<code>.json` → `TranslationServer`; fallback dili `project.godot` → `internationalization/locale/fallback` ve `_ready()` içinde `ProjectSettings.set_setting(..., "en")`; ilk kurulumda kayıt yoksa **OS dili** (katalogda varsa); `locale_changed` sinyali. |
| **AudioManager** | Ses çalma API’si. |
| **ObjectPool** | Sık oluşturulan nesneler (mermi, orb, damage number vb.) için havuz; `get_object(scene_path)` / `return_object` (serbest yuva yığını ile hızlı seçim). |
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
- **Yeni metin:** Tüm mevcut locale dosyalarına aynı anahtarı ekleyin; gerekirse `locales/gen_locales.py` ile `tr`/`en` üretimi (isteğe bağlı).

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
- **`core/character_data.gd`** — `CharacterData.CHARACTERS` dizisi: her eleman bir sözlük (`id`, `name`, `description`, `color`, `start_weapon`, `start_item`, bonuslar, `locked`, `secret`, `cost`, `unlock_hint`, `unlock_condition`, `origin_bonus`, `special`, `hero_class` — tasarım rolü: `tank` / `fighter` / `mage` / `controller` / `special`; seçim filtresi sırası: `HERO_CLASS_FILTER_IDS`). **`start_item` şu an tüm kahramanlarda boş** — başlangıçta yalnızca `start_weapon`; imza eşya koşu içinde toplanır (`description` / kodeks metinleri bilgi amaçlı “silah / eşya / evrim” satırlarını taşır). Karakter sahne yolu: `CharacterData.CHARACTER_SCENE_BY_ID` + `get_character_scene_path(char_id)` (`main/main.gd` oyuncu spawn).

### Sahne
- **`characters/<id>/<id>.tscn`** — Çoğunlukla `CharacterBody2D` + `player/player.gd`; her karakter kendi klasöründe tutulur.
- **Çok geniş sprite sheet:** Birçok GPU’da tek dokunun kenarı ~8192 px ile sınırlıdır. Daha geniş PNG kullanıyorsan ilgili `.png.import` içinde `process/size_limit=8192` (veya cihazına uygun üst sınır) kullan ve sahnedeki `AtlasTexture` `region` değerlerini aynı ölçek faktörüyle güncelle (projede savaşçı gövdeleri için örnek: `8192 / 16064`).

### Spawn
- **`main/main.gd`** → `_get_character_scene(char_id)` içinde `match` ile `res://characters/...` yolu **mutlaka** eklenmeli.

### Oyun içi uygulama
- **`player/player.gd`** → `apply_character_bonuses()`: `SaveManager.selected_character` (veya P2) **indeks** ile `CHARACTERS` okunur; `start_weapon` / `start_item` için `add_weapon` / `add_item` çağrılır; `origin_bonus` ve `special` burada işlenir. **Level-up:** `gain_xp` birden fazla seviye verirse her biri için `main.queue_upgrade(player)` kuyruğa girer (solo ve co-op aynı yol). `get_total_damage()` taban silah hasarına `bullet_damage` (karakter/meta/dalga düz bonusu) ekler.

### Kayıt ve kilit
- **`core/save_manager.gd`**
  - `unlocked_characters`: Koşul sağlandı mı (ör. toplam kill)?
  - `purchased_characters`: Altınla satın alındı mı?
  - **Yeni oyuncu varsayılanı:** Yalnızca `warrior` hem açık hem satın alınmış sayılır; `mage` / `vampire` `character_data` içindeki `unlock_condition` + `cost` ile açılır (mevcut kayıt dosyaları değişmez).
  - `check_and_unlock_characters()`: `unlock_condition` tiplerini `character_data` ile eşleştirir.
  - `purchase_character(char_id)`: Hem `unlocked` hem yeterli altın gerekir.

### UI
- **`ui/character_select.gd`** / **`ui/character_select_p2.gd`**: Kartlar `CHARACTERS` sırasına göre üretilir; sınıf filtresi (`hero_class`); P2’de P1’in karakteri filtre dışı kalsa da kartı görünür (alınamaz). `_get_weapon_name` / `_get_item_name` yeni ID’ler için güncellenmeli.

### Dikkat: indeks kaydı
- `selected_character` sayısal **indeks** olarak saklanır. `CHARACTERS` sırası değişirse eski kayıtlar yanlış karaktere işaret edebilir. Projede buna yönelik **`character_order_v2`** ile geçmiş sıra → ID → yeni indeks taşıması kullanılmıştır; benzer büyük sıra değişikliklerinde aynı mantık veya **ID tabanlı seçim** düşünülmeli.

---

## 4. Silah sistemi

### Taban
- **`weapons/weapon_base.gd`** — `WeaponBase`: cooldown, `attack()`, `upgrade()`, `category`, `tag`, `weapon_name`.

### Yeni silah scripti
- `weapons/weapon_<isim>.gd`, tercihen **`class_name Weapon...`** (Godot global sınıf).

### Oyuncuya bağlama
- **`core/player_loadout_registry.gd`** — `PlayerLoadoutRegistry.WEAPON_SCRIPT_BY_ID`: string ID → `preload` script; `create_weapon(id)`.
- **`player/player.gd`**
  - `add_weapon(type: String)` → `PlayerLoadoutRegistry.create_weapon(type)`.
  - `_on_upgrade_chosen` → yeni silah ID’si bu sözlükte ve `upgrade_ui` havuzunda olmalı.
  - `get_weapon_description(type)` → `codex.weapon.<id>.name/desc` + `ui.player.loadout.*` (yükseltme / yeni silah metni).

### Level-up havuzu
- **`ui/upgrade_ui.gd`**
  - `weapon_upgrades` dizisine string ID.
  - `get_upgrade_text()` içindeki silah `match` satırına aynı ID.

### Evrim
- **`weapons/weapon_evolution.gd`**
  - `EVOLUTIONS`: `requires_weapons`, `requires_items`, `name`, `description`; isteğe bağlı `weight` (level-up havuzunda ağırlık, varsayılan `10.0`).
  - `is_evolution_ready(player, evo_id)`: Tek doğrulama kaynağı (silah/eşya MAX, evrim henüz yok).
  - `get_available_evolutions(player)`: Hazır evrimleri döndürür; sıra **karıştırılır** (aynı ekranda birden fazla evrim adil görünsün).
  - `localized_name` / `localized_description`: `ui.evolution_defs.<id>.name|desc`; çeviri yoksa sözlükteki `name` / `description`.
- **`player/player.gd`** → `evolve_weapon`: Önce `is_evolution_ready`; sonra sadece **`requires_weapons`** silahlarını kaldırır; **eşyalar kalır**. Yüzen metin: `ui.upgrade_ui.evolution_floating`.
- **`ui/upgrade_ui.gd`**: Evrim kartı başlığı `ui.upgrade_ui.evolution_pick_title`; cog shard **4 seçenek** (`Option4`); reroll aynı `pick_count` ile çalışır.
- **Locale**: Yeni evrim → `locales/*.json` içinde `ui.evolution_defs.<evo_id>` (`name`, `desc`) + mümkünse `gen_locales.py` (tr/en).

### Özel davranışlar
- **Kaos** karakteri: `apply_character_bonuses` içinde `random_weapons` listesine yeni taban silah eklenmeli.
- **Projectile + ObjectPool**: Sahne yolu `ObjectPool.get_object(...)` ile alınır; `reset()` havuza dönüşte çağrılır (bkz. `projectiles/bullet.gd`, `fan_blade_shard.gd`).

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

### Level-up havuzu
- **`ui/upgrade_ui.gd`** — `item_upgrades` + `get_upgrade_text` item `match`.

### Dünya ödülleri
- Örn. **`effects/chest.gd`** içindeki rastgele item listeleri; boss / dalga ödülleri varsa aynı ID tutarlılığı.

---

## 5a. Koleksiyon (bestiary / kodeks)

- **`core/collection_data.gd`** — Sekmeler: `TAB_ENEMY`, `TAB_BOSS`, `TAB_WEAPON`, `TAB_ITEM`, `TAB_CHARACTER`, `TAB_MAP`. Tablo dizileri: `ENEMY_ENTRIES`, `BOSS_ENTRIES`, `WEAPON_ENTRIES`, `ITEM_ENTRIES`, `MAP_ENTRIES`; kahramanlar **`character_entries()`** ile `CharacterData.CHARACTERS` üzerinden üretilir (emoji + `accent` = karakter rengi). `all_entries()`, `entries_for_tab(tab)`, `total_entry_count()`, `has_bestiary_id()` (sadece ölüm kaydı).
- **`SaveManager`**: `codex_discovered` (düşman/boss), `codex_weapons`, `codex_items`, `codex_maps`; `is_codex_entry_unlocked(entry)` tek doğrulama; `register_codex_*` aileleri. **Tüm ilerlemeyi sıfırla** dört kodeks dizisini de temizler.
- **Keşif tetikleyicileri:** düşman ölümü `enemy_base` / `boss` / `giant`; silah ve eşya ilk alımda **`player/player.gd`** `add_weapon` / `add_item`; harita **`ui/map_select.gd`** oyun başlatırken `register_codex_map`; kahramanlar **`unlocked_characters`** (kilit açılmadan kart gizli).
- **Yeni düşman:** `.tscn` + `ENEMY_ENTRIES`/`BOSS_ENTRIES` + `codex.<id>.name/desc` (düşman/boss düz anahtar).
- **Yeni silah / eşya / harita:** `WEAPON_ENTRIES` / `ITEM_ENTRIES` / `MAP_ENTRIES` + üç dilde `codex.<weapon|item|map>.<id>.name/desc`. Toplu ek için **`locales/codex_sources/codex_extensions_{en,tr,zh_CN}.json`** düzenle → `python locales/merge_codex_extensions.py` (çıktı `locales/*.json` içindeki `codex` altına yazar; `check_locale_parity.py` yalnızca kök `*.json` dosyalarını karşılaştırır).
- **Yeni kahraman:** `CharacterData`’ya ekle; `codex.character.<id>` metinleri üç dilde.
- **UI:** `ui/collection_menu.gd` — üstte 6 sekme (`ui.collection_menu.tab_*`); ana menü **`ui/main_menu.gd`** → Kodeks.

---

## 6. Harita ve mod seçimi

- **`ui/map_select.gd`**: Run modu **`SaveManager.settings["run_variant"]`** (`story` / `fast`; `arena` şimdilik kilitli UI); harita listesi + önizleme; **`run_curse_tier`** (0–5) kaydı; **Başlat** → `SaveManager.selected_map` / mod alanları + `register_codex_map`. Süre ve boss ölçeği: `SaveManager.get_run_goal_sec()`, `get_mini_boss_times()`, `get_run_spawn_difficulty_mult()` (`spawn_manager`, `wave_manager`, `main`, `player`).
- Yeni **hikaye haritası**: Yeni buton + `selected_map` string ID + `main` veya ortam tarafında bu ID’ye göre sahne/tileset/spawn mantığı.
- **Arena**: `map_select` içinde kilitli; dalga mantığı `YOL_HARITASI.md` planı ile genişletilecek.

---

## 7. UI ve metin (label)

| Alan | Tipik dosya |
|------|-------------|
| Açılış ekranı | `ui/intro_splash.gd` / `.tscn` — `FullRect`; prompt `PROMPT_ANCHOR_*` / `PROMPT_OFF_*` (4–6. sn tween); `MainMenuBackground.load_texture()`; tint yok; siyah overlay ~5 sn; müzik track 1; `ui.intro_splash.press_to_start` |
| Ana menü | `ui/main_menu.gd` / `.tscn` — arka plan: `BackgroundBase` + isteğe bağlı `BackgroundPhoto` (`MainMenuBackground` / `assets/ui/main_menu_bg.png|.jpg|.webp`) + `BackgroundTint` + `StarsLayer`; `assets/ui/README_MAIN_MENU_BG.txt` |
| Mağaza (iskelet) | `ui/shop_menu.gd` / `.tscn` |
| Karakter seçimi | `ui/character_select.gd`, `character_select_p2.gd`, `character_select_helpers.gd`, `character_select_preview.gd` (sabit boy `TextureRect`: `idle_left` ilk kare önbelleği; kilit=siyah kutu, açık+satın alınmamış=silüet, satın alınmış=tam); `game_mode_select.gd` → `warmup_portraits_async`; ESC: P1→`game_mode_select`, P2→`character_select` |
| Harita | `ui/map_select.gd` |
| Level-up | `ui/upgrade_ui.gd` |
| HUD (kill, altın, çubuklar) | `player/player.gd` + `player` sahnesindeki `CanvasLayer` düğümleri |
| Oyun sonu / duraklat | `ui/game_over.gd`, `pause_menu.gd` |
| Meta upgrade | `ui/meta_upgrade.gd` |
| Koleksiyon (kodeks) | `ui/collection_menu.gd` / `.tscn` |
| Ayarlar | `ui/settings.gd` (+ sekme stilleri `ui/settings_ui_styles.gd`) |

**Yeni bir Label / buton:** İlgili `.tscn` düğümü + `.gd` içinde `onready` veya `%UniqueName` ile referans.

---

## 8. Orb ve toplanabilir nesneler (pickup)

Mevcut örnekler: **`effects/xp_orb.tscn`**, **`effects/gold_orb.tscn`**. İkisi de `Area2D` tabanlı; **ObjectPool** ile alınıp `return_object` ile havuza döner.

### Mevcut bağlantılar (referans)

- **Düşürme:** `enemies/enemy_base.gd` (ölümde altın / XP orb), `enemies/boss.gd`, `enemies/giant.gd` vb. — `ObjectPool.get_object("res://effects/....tscn")`.
- **Ortam:** `main/environment_manager.gd` — ağaçta kalan `xp_orbs` / `gold_orbs` grupları üzerinde işlem (ör. temizlik).
- **Havuz boyutu:** `core/ObjectPool.gd` — yol içinde `xp_orb` veya `gold_orb` geçen sahneler için havuz **40** öğe (diğerleri 20).

### Yeni bir orb (veya pickup) türü eklerken — checklist

1. **`effects/<isim>_orb.tscn` + `.gd`** — `Area2D`; çarpışma / toplama mesafesi; oyuncuya yaklaşma mantığı (mıknatıs: `player.get_magnet_bonus()` veya sabit yarıçap).
2. **`init` / `reset`** — Pool ile uyum: `reset()` içinde hız, pozisyon, görünürlük, grup üyeliği sıfırlanmalı; `ObjectPool.return_object(self)` toplandığında veya ömür bittiğinde çağrılmalı.
3. **`add_to_group` / `remove_from_group`** — Örn. `"xp_orbs"`, `"gold_orbs"` gibi; **pausa, temizlik veya istatistik** için grupları kullanan kod varsa (`environment_manager` vb.) yeni grup adını oraya da ekle.
4. **Düşürme noktaları** — Hangi düşman / sandık / olay bu orb’u üretecekse orada `get_object` ile sahne yolu; gerekirse değer parametresi (`xp_value`, `value` gibi) `init` ile verilir.
5. **Oyuncu tarafı** — Toplanınca `player.gain_xp`, `collect_gold`, `heal`, yeni bir metot veya `EventBus` emit; co-op’ta P1/P2 paylaşımı **mevcut orb’lardaki gibi** düşünülmeli.
6. **`ObjectPool.gd`** — Çok yoğun sahne ise yeni sahne yolu için havuz boyutu kuralı gerekebilir (şu an sadece xp/gold için özel sayı var).
7. **`docs/TASARIM.md`** — Yeni pickup/orb için görsel envanter satırı; tamamlanınca işaretle.
8. **`docs/YOL_HARITASI.md`** — Özellik teslim edildiyse **Yapılan iş günlüğü**ne kısa satır.

Yeni orb kodu için başlangıç: `xp_orb.gd` / `gold_orb.gd` ve `.tscn` şablonu.

---

## 9. Checklist: yeni karakter

1. `core/character_data.gd` — yeni sözlük (ID benzersiz, `hero_class` zorunlu: `tank` / `fighter` / `mage` / `controller` / `special`).
2. `characters/<id>/<id>.tscn` — sahne (script `player.gd` uyumu).
3. `core/character_data.gd` — `CHARACTER_SCENE_BY_ID` + `get_character_scene_path` (yeni `id` → `.tscn` yolu).
4. Gerekirse `save_manager.gd` — varsayılan kilit/purchase (çoğu karakter sadece veri + koşul ile gelir).
5. `locales/*.json` — `ui.character_select.special.*` (kartlarda `special` alanı için) ve kodeks kahraman metinleri.
6. `CHARACTERS` sırası değişecekse: kayıtlı indeks migrasyonu veya ID tabanlı seçim.

---

## 10. Checklist: yeni taban silah

1. `weapons/weapon_*.gd` + `class_name`.
2. `core/player_loadout_registry.gd` — `WEAPON_SCRIPT_BY_ID` içine aynı string ID.
3. `player/player.gd` — `_on_upgrade_chosen` `match` listesi (veya havuz); açıklama `codex` + `ui.player.loadout` ile gelir.
4. `ui/upgrade_ui.gd` — `weapon_upgrades`, `get_upgrade_text`.
5. Varsa projectile: `projectiles/*.tscn` + script, `ObjectPool` uyumu; hedef seçiminde tercihen `EnemyRegistry.get_enemies()`.
6. Kaos: `apply_character_bonuses` içindeki `random_weapons` listesi.
7. `locales/*.json` — `codex.weapon.<id>.name/desc` (üç dil).

---

## 11. Checklist: yeni pasif eşya

1. `items/item_*.gd` + `class_name`.
2. `core/player_loadout_registry.gd` — `ITEM_SCRIPT_BY_ID` satırı.
3. `player/player.gd` — `_on_upgrade_chosen` ve oyun döngüsü kancaları (`on_enemy_killed`, `take_damage`, `_process` vb.); açıklama `codex` + `ui.player.loadout`.
4. `ui/upgrade_ui.gd` — `item_upgrades`, `get_upgrade_text`.
5. Sandık/boss/dalga ödül listeleri (kullanılacaksa).
6. Evrim gereksinimi olacaksa `weapon_evolution.gd` — `requires_items`.

---

## 12. Checklist: yeni evrim silahı

1. `weapons/weapon_*.gd` (evrim sonucu silah).
2. `weapon_evolution.gd` — `EVOLUTIONS` girişi.
3. `core/player_loadout_registry.gd` — `WEAPON_SCRIPT_BY_ID` içine evrim silahı ID’si (örn. `ember_fan`).
4. `player/player.gd` — `_on_upgrade_chosen` `match` listesinde evrim ID’si (gerekirse).
5. `codex` + `ui.evolution_defs` / `get_weapon_description` (gerekirse).
6. `locales/tr.json`, `en.json`, `zh_CN.json` — `ui.evolution_defs.<evo_id>` (`name`, `desc`); mümkünse `gen_locales.py` (tr/en).

---

## 13. İlgili klasörler (kısa)

- `main/` — Oyun sahnesi, spawn, dalga, kamera, co-op HUD tetikleri.
- `enemies/` — Düşman davranışı, ölüm, orb düşürme.
- `effects/` — Sandık, parçacık benzeri efektler.
- `projectiles/` — Oyuncu / düşman mermileri.
- `core/` — Kayıt, karakter verisi, kategori bonusları, havuz, `EnemyRegistry`, `PlayerLoadoutRegistry`.
- `player/` — `player.gd` + `player_ui_helpers.gd` (level-up VFX, istatistik paneli).
- `weapons/`, `items/` — Oyun içi ekipman mantığı.

---

## 14. Son not

Bu rehber, kod tabanındaki gerçek yapıya göre yazılmıştır; yeni sistem eklendikçe **ilgili bölüm güncellenmelidir**. Özellikle string ID eşlemeleri (`match` blokları) unutulursa içerik oyunda görünür ama seçilemez veya çalışmaz. **`docs/YOL_HARITASI.md`**, **`docs/TASARIM.md`** ve erişilebilirlik matrisi ile birlikte yaşayan belgeler olarak tutulmalıdır.

---

## 15. Erişilebilirlik ve devamlılık referansları

**20+20 madde — kod durumu (Var/Kısmi/Yok + repo notu):**  
`docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`

`docs/TASARIM.md` — ses ve UI ile ilgili ürün hedefleri (§15 dışı).

### `SaveManager.settings` anahtarları (`core/save_manager.gd`)

| Anahtar | Tip | Açıklama |
|---------|-----|----------|
| `master_volume` | float | Ana ses (0–1) |
| `sfx_volume` | float | Efekt bus |
| `music_volume` | float | Müzik bus |
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

**UI:** `ui/settings.gd` — Sekmeler: Ses, **Dil** (`locale`), **Görüntü** (`fullscreen`, çözünürlük, VFX, `performance_quality`, `enemy_high_contrast_outline`), **Oynanış** (`damage_numbers`, `hp_bars`, `screen_shake`, `pause_on_focus_loss`, `player_vfx_opacity`), **Kontroller** (tuş yeniden atama, `InputRemap`), Profil, Dev. **Tam ekran kısayolu:** `toggle_fullscreen` (F11) → `SaveManager._unhandled_input`.

### `InputRemap` (`core/input_remap.gd`)

Oyun başında projedeki `InputMap` anlık görüntüsünü alır; `SaveManager.settings["input_keyboard_overrides"]` ile klavye `InputEventKey` olaylarını listedeki eylemler için uygular (`REMAPPABLE_ACTIONS`). Oyun kolu `InputEventJoypad*` olayları silinmez. Sıfırlama: Ayarlar → Kontroller → “varsayılana dön” veya tam ilerleme sıfırlama (`ui/settings.gd`).

### Yeni ayar / kontrol eklerken

1. `core/save_manager.gd` → `settings` sözlüğüne **varsayılan** değer.
2. `ui/settings.gd` → doğru sekmeye `_add_toggle` / `_add_slider` / `_add_dropdown` (`_build_*_tab`).
3. Oyun mantığında `SaveManager.settings.get("anahtar", varsayılan)`; callback’lerde `SaveManager.save_game()`.
4. Tuş eşlemesi ekleniyorsa: `InputRemap.REMAPPABLE_ACTIONS`, `ui.settings.bind_*` ve `tab_controls` (tüm `LANGUAGE_CATALOG` dilleri); `python locales/check_locale_parity.py`.

### XP sesi (`pitch_scale`)

`core/audio_manager.gd` → `play_xp()`: Her toplamada `xp_player.pitch_scale` pentatonik dizi (`xp_notes`) ile ayarlanır; kısa süre sonra `xp_note_index` sıfırlanır (`_process`). XP sesi ile ilgili ürün maddeleri: `docs/TASARIM.md`.

Ayar anahtarları veya matris satırı değişince **`docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`** ile senkron tut.
