# Ironfall — Geliştirici rehberi

Bu belge, projenin **nasıl işlediğini**, dosyaların **birbirine nasıl bağlandığını** ve **yeni içerik eklerken izlenmesi gereken yolları** özetler.  
*(İngilizce projelerde eşdeğeri genelde `ARCHITECTURE.md`, `DEVELOPER_GUIDE.md` veya `docs/CONTRIBUTING.md` olarak adlandırılır.)*

**Motor:** Godot 4.x  
**Son güncelleme:** Nisan 2026

---

## 1. Genel akış (oyun döngüsü)

1. **`project.godot`** → `run/main_scene` ile giriş sahnesi (genelde ana menü).
2. **Autoload’lar** (`project.godot` → `[autoload]`): `SaveManager`, `AudioManager`, `ObjectPool`, `EventBus`, `AchievementManager` — sahne yüklenmeden önce hazır olurlar.
3. Tipik oyuncu akışı: **Ana menü** → mod seçimi → **Karakter seçimi** → (co-op ise P2 karakter) → **Harita seçimi** → **`main/main.tscn`** (asıl oyun).
4. Oyunda oyuncu **`player/player.gd`** (karakter sahnesi üzerinden) ile yaratılır; `main/main.gd` spawn, dalga, ortam yöneticilerini kurar.

**Önemli:** Karakter, silah ve eşya kimlikleri çoğunlukla **string ID** (`"warrior"`, `"fan_blade"`, `"ember_heart"`) ile taşınır; tek bir merkezi `.tres` veritabanı yoktur — aynı ID birden fazla dosyada tutarlı olmalıdır.

---

## 2. Autoload’ların rolleri

| Autoload | Görev |
|----------|--------|
| **SaveManager** | Altın, seçili karakter/harita, meta upgrade’ler, ayarlar, kilit / satın alınmış karakter listeleri, istatistikler. |
| **AudioManager** | Ses çalma API’si. |
| **ObjectPool** | Sık oluşturulan nesneler (mermi, orb, damage number vb.) için havuz; `get_object(scene_path)` / `return_object`. |
| **EventBus** | Sinyal merkezi (hasar, ölüm, level up, altın vb.). |
| **AchievementManager** | Başarı kontrolleri. |

---

## 3. Karakter sistemi

### Veri
- **`core/character_data.gd`** — `CharacterData.CHARACTERS` dizisi: her eleman bir sözlük (`id`, `name`, `description`, `color`, `start_weapon`, `start_item`, bonuslar, `locked`, `secret`, `cost`, `unlock_hint`, `unlock_condition`, `origin_bonus`, `special`).

### Sahne
- **`characters/<id>/<id>.tscn`** — Çoğunlukla `CharacterBody2D` + `player/player.gd` scripti; görsel/animasyon karaktere özel.

### Spawn
- **`main/main.gd`** → `_get_character_scene(char_id)` içinde `match` ile `res://characters/...` yolu **mutlaka** eklenmeli.

### Oyun içi uygulama
- **`player/player.gd`** → `apply_character_bonuses()`: `SaveManager.selected_character` (veya P2) **indeks** ile `CHARACTERS` okunur; `start_weapon` / `start_item` için `add_weapon` / `add_item` çağrılır; `origin_bonus` ve `special` burada işlenir.

### Kayıt ve kilit
- **`core/save_manager.gd`**
  - `unlocked_characters`: Koşul sağlandı mı (ör. toplam kill)?
  - `purchased_characters`: Altınla satın alındı mı?
  - `check_and_unlock_characters()`: `unlock_condition` tiplerini `character_data` ile eşleştirir.
  - `purchase_character(char_id)`: Hem `unlocked` hem yeterli altın gerekir.

### UI
- **`ui/character_select.gd`** / **`ui/character_select_p2.gd`**: Kartlar `CHARACTERS` sırasına göre üretilir; `_get_weapon_name` / `_get_item_name` yeni ID’ler için güncellenmeli.

### Dikkat: indeks kaydı
- `selected_character` sayısal **indeks** olarak saklanır. `CHARACTERS` sırası değişirse eski kayıtlar yanlış karaktere işaret edebilir. Projede buna yönelik **`character_order_v2`** ile geçmiş sıra → ID → yeni indeks taşıması kullanılmıştır; benzer büyük sıra değişikliklerinde aynı mantık veya **ID tabanlı seçim** düşünülmeli.

---

## 4. Silah sistemi

### Taban
- **`weapons/weapon_base.gd`** — `WeaponBase`: cooldown, `attack()`, `upgrade()`, `category`, `tag`, `weapon_name`.

### Yeni silah scripti
- `weapons/weapon_<isim>.gd`, tercihen **`class_name Weapon...`** (Godot global sınıf).

### Oyuncuya bağlama
- **`player/player.gd`**
  - `add_weapon(type: String)` → `match type:` ile `...new()`.
  - `_on_upgrade_chosen` → yeni silah ID’si aynı `match` listesinde olmalı.
  - `get_weapon_description(type)` → level-up kartı metinleri.

### Level-up havuzu
- **`ui/upgrade_ui.gd`**
  - `weapon_upgrades` dizisine string ID.
  - `get_upgrade_text()` içindeki silah `match` satırına aynı ID.

### Evrim
- **`weapons/weapon_evolution.gd`**
  - `EVOLUTIONS`: `requires_weapons`, `requires_items`, `name`, `description`.
  - `get_available_evolutions(player)`: Gerekli silah/eşya **MAX seviye** ve evrim silahı henüz yok.
- **`player/player.gd`** → `evolve_weapon`: Sadece **`requires_weapons`** listedeki silahları kaldırır; **eşyalar kalır**.

### Özel davranışlar
- **Kaos** karakteri: `apply_character_bonuses` içinde `random_weapons` listesine yeni taban silah eklenmeli.
- **Projectile + ObjectPool**: Sahne yolu `ObjectPool.get_object(...)` ile alınır; `reset()` havuza dönüşte çağrılır (bkz. `projectiles/bullet.gd`, `fan_blade_shard.gd`).

---

## 5. Pasif eşya (item) sistemi

### Taban
- **`items/passive_item.gd`** — `PassiveItem`: `category`, `apply()`, `upgrade()`, isteğe bağlı `on_damage_dealt` için `EventBus` bağlantısı.

### Oyuncuya bağlama
- **`player/player.gd`**
  - `add_item(type: String)` → `match`.
  - `_on_upgrade_chosen` → item listesi.
  - `get_item_description(type)`.
  - Oyun olayları: örn. `on_enemy_killed` içinde `active_items.has("...")` ile özel item metodu çağrısı.

### Level-up havuzu
- **`ui/upgrade_ui.gd`** — `item_upgrades` + `get_upgrade_text` item `match`.

### Dünya ödülleri
- Örn. **`effects/chest.gd`** içindeki rastgele item listeleri; boss / dalga ödülleri varsa aynı ID tutarlılığı.

---

## 6. Harita ve mod seçimi

- **`ui/map_select.gd`**: Mod (`vs` / `arena` planı) ve harita butonları; `SaveManager.selected_mode`, `SaveManager.selected_map` atanır; oyun **`res://main/main.tscn`** ile başlar.
- Yeni **hikaye haritası**: Burada yeni buton + `selected_map` string ID + `main` veya ortam tarafında bu ID’ye göre sahne/tileset/spawn mantığı (projede harita özel kod `main` ve ilgili manager’larda aranmalı).
- **Arena**: UI’da şu an kilitli placeholder; ileride mod + harita satırı + `main` içi dalga mantığı birlikte genişler.

---

## 7. UI ve metin (label)

| Alan | Tipik dosya |
|------|-------------|
| Ana menü | `ui/main_menu.gd` / `.tscn` |
| Karakter seçimi | `ui/character_select.gd`, `character_select_p2.gd` |
| Harita | `ui/map_select.gd` |
| Level-up | `ui/upgrade_ui.gd` |
| HUD (kill, altın, çubuklar) | `player/player.gd` + `player` sahnesindeki `CanvasLayer` düğümleri |
| Oyun sonu / duraklat | `ui/game_over.gd`, `pause_menu.gd` |
| Meta upgrade | `ui/meta_upgrade.gd` |
| Ayarlar | `ui/settings.gd` |

**Yeni bir Label / buton:** İlgili `.tscn` düğümü + `.gd` içinde `onready` veya `%UniqueName` ile referans; metinleri ileride `localization` için anahtarlara taşımak mantıklı (bkz. yol haritası).

---

## 8. Checklist: yeni karakter

1. `core/character_data.gd` — yeni sözlük (ID benzersiz).
2. `characters/<id>/<id>.tscn` — sahne (script `player.gd` uyumu).
3. `main/main.gd` — `_get_character_scene` eşlemesi.
4. Gerekirse `save_manager.gd` — varsayılan kilit/purchase (çoğu karakter sadece veri + koşul ile gelir).
5. `ui/character_select.gd` ve `character_select_p2.gd` — `_get_weapon_name` / `_get_item_name` / özel `special` satırları.
6. `CHARACTERS` sırası değişecekse: kayıtlı indeks migrasyonu veya ID tabanlı seçim.

---

## 9. Checklist: yeni taban silah

1. `weapons/weapon_*.gd` + `class_name`.
2. `player/player.gd` — `add_weapon`, `_on_upgrade_chosen`, `get_weapon_description`.
3. `ui/upgrade_ui.gd` — `weapon_upgrades`, `get_upgrade_text`.
4. Varsa projectile: `projectiles/*.tscn` + script, `ObjectPool` uyumu.
5. Kaos: `random_weapons` listesi.
6. Karakter seçimi isimleri: `character_select*.gd`.

---

## 10. Checklist: yeni pasif eşya

1. `items/item_*.gd` + `class_name`.
2. `player/player.gd` — `add_item`, `_on_upgrade_chosen`, `get_item_description`, gerekli oyun döngüsü kancaları (`on_enemy_killed`, `take_damage`, `_process` vb.).
3. `ui/upgrade_ui.gd` — `item_upgrades`, `get_upgrade_text`.
4. Sandık/boss/dalga ödül listeleri (kullanılacaksa).
5. Evrim gereksinimi olacaksa `weapon_evolution.gd` — `requires_items`.

---

## 11. Checklist: yeni evrim silahı

1. `weapons/weapon_*.gd` (evrim sonucu silah).
2. `weapon_evolution.gd` — `EVOLUTIONS` girişi.
3. `player/player.gd` — `add_weapon` içinde evrim ID’si (örn. `ember_fan`).
4. `get_weapon_description` / karakter seçimi isimleri (gerekirse).

---

## 12. İlgili klasörler (kısa)

- `main/` — Oyun sahnesi, spawn, dalga, kamera, co-op HUD tetikleri.
- `enemies/` — Düşman davranışı, ölüm, orb düşürme.
- `effects/` — Sandık, parçacık benzeri efektler.
- `projectiles/` — Oyuncu / düşman mermileri.
- `core/` — Kayıt, karakter verisi, kategori bonusları, havuz.
- `weapons/`, `items/` — Oyun içi ekipman mantığı.

---

## 13. Son not

Bu rehber, kod tabanındaki gerçek yapıya göre yazılmıştır; yeni sistem eklendikçe **ilgili bölüm güncellenmelidir**. Özellikle string ID eşlemeleri (`match` blokları) unutulursa içerik oyunda görünür ama seçilemez veya çalışmaz.
