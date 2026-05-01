# Sesler / Müzikler / Efektler

Oyun içindeki **tüm işitsel içerik** için yaşayan envanter: hangi olay hangi dosyayı çalıyor, hangi kod tetikliyor, neler eksik veya paylaşımlı. İleride burayı genişleterek “stüdyo seviyesi” bir ses haritası çıkaracağız.

**Teknik özet**

- Ana otorite: `core/audio_manager.gd` + sahne `core/audio_manager.tscn` (`AudioStreamPlayer` düğümleri, stream’ler `.tscn` üzerinde).
- Otobüsler: **SFX** (efektler), **Music** (müzik), ikisi de **Master** altında; hacim `SaveManager.settings` → `ui/settings.gd` içinde `AudioManager.apply_volume_settings()`.
- **İsteğe bağlı müzik dip’i:** `SaveManager.settings["combat_music_duck"]` (varsayılan **kapalı**). Açıkken her silah `attack()` sonrası `AudioManager.notify_combat_music_duck_beat()` müzik bus linear çarpanını kısa süre düşürür (`_combat_music_duck_linear` + `_refresh_music_bus_volume`); kapalıyken yalnızca `music_volume` uygulanır. Tetik: `weapons/weapon_base.gd` (`attack()` sonrası). Ayar: **Ayarlar → Ses** (`settings.gd`, etiket metni `LocalizationManager.tr_en_source("ui.settings.combat_music_duck")`).

**Kullanım:** Yeni ses ekleyince bu dosyada ilgili bölüme satır ekle; dosya taşınırsa yolu güncelle; ayrıştırılacak bir olay varsa “henüz yok” satırını doldur.

---

## Mevcut dosya envanteri (`assets/sounds/`)

| Dosya | Kullanım (kısa) | Tetik / kod |
|-------|-----------------|-------------|
| `music1.mp3` … `music6.mp3` | Koşu / menü müzik döngüsü | `AudioManager.MUSIC_PATHS`, `play_music`, `main/main.gd` (süreye göre `music2` vb.) |
| `ateş sesi.mp3` | Genel “ateş” SFX | `ShootPlayer` → `play_shoot()` |
| `hasar sesi.ogg` | Vuruş / isabet | `HitPlayer` → `play_hit()` |
| `ölümsesi.mp3` | Düşman ölümü | `DeathPlayer` → `play_death()` |
| `levelup.mp3` | Run içi seviye atlayınca + meta seviye | `LevelUpPlayer` → `play_levelup()`, `play_account_level_up()` |
| `oyuncu hasar.mp3` | Oyuncu hasar alınca | `PlayerHurtPlayer` → `play_player_hurt()` |
| `XP toplama.mp3` | XP orb toplama (pitch varyasyonlu) | `XPPlayer` → `play_xp()` |
| `boss spawn.mp3` | Boss ortaya çıkınca | `BossPlayer` → `play_boss()` |

---

## Menü sesleri

Ana menü / karakter seçimi / harita seçimi / ayarlar için **ayrı menü SFX dosyaları henüz yok**; arka planda çoğunlukla müzik çalar (`AudioManager.play_music(1)` vb.).

| Olay | Hedef dosya | Tetikleyici | Durum |
|------|-------------|-------------|-------|
| Menüde arka plan müziği | `music1.mp3` (ve sıradaki parçalar) | `ui/main_menu.gd`, `ui/intro_splash.gd` | Var |
| Menü buton tıklama | — | — | Henüz yok |
| Menü geçiş / panel açılışı | — | — | Henüz yok |

---

## Müzikler

| Parça | Dosya | Not |
|-------|-------|-----|
| Parça 1–6 | `assets/sounds/music1.mp3` … `music6.mp3` | `MUSIC_TRACK_COUNT`, ayarlardan sıradaki / duraklat |
| Boss’a özel ayrı müzik parçası | — | Şu an boss yalnızca `boss spawn.mp3` SFX; loop “boss müziği” yok |

---

## Silah efekt sesleri

Şu an **tek paylaşımlı ateş sesi**: `play_shoot()` → `ateş sesi.mp3`. Aşağıdakiler (ve benzeri `play_shoot` çağıranlar) aynı stream’i kullanıyor; ileride silah başına ayrıştırılabilir.

| Silah / bağlam | Kod | Not |
|----------------|-----|-----|
| Mermi | `weapons/weapon_bullet.gd` | `AudioManager.play_shoot()` |
| Hançer / peçe | `weapon_dagger.gd`, `weapon_veil_daggers.gd` | Aynı |
| Yelpaze parçası | `weapon_fan_blade.gd`, `weapon_ember_fan.gd` | Aynı |
| *(diğer silahlar)* | — | `play_shoot` yoksa bu tabloya ekle |

---

## Eşya efekt sesleri

Pasif eşyalar için **özel ses çağrısı yok** (`items/item_*.gd` içinde `AudioManager` kullanımı yok). İleride (ör. `ember_heart` nabız, `shield` blok sesi) buraya satır satır eklenecek.

| Eşya ID | Olay | Dosya | Tetikleyici | Durum |
|---------|------|-------|-------------|-------|
| *(örnek)* | — | — | — | Henüz yok |

---

## Karakter efekt sesleri

| Olay | Dosya | Tetikleyici |
|------|-------|-------------|
| Oyuncu hasar | `oyuncu hasar.mp3` | `player/player.gd` → `play_player_hurt()` |
| XP toplama | `XP toplama.mp3` | `play_xp()` (pitch streak ile) |
| Run içi level-up | `levelup.mp3` | `play_levelup()` |
| Meta / hesap level-up | `levelup.mp3` (aynı player) | `play_account_level_up()` |

| Olay | Dosya | Tetikleyici | Durum |
|------|-------|-------------|-------|
| Adım / zıplama / dash sesi | — | — | Henüz yok |
| Karaktere özel ulti / yetenek | — | — | Henüz yok |

---

## Buton / UI sesleri

| Olay | Dosya | Tetikleyici | Durum |
|------|-------|-------------|-------|
| Level-up kart seçimi | — | `ui/upgrade_ui.gd` | Henüz yok |
| Sandık / ödül | — | — | Henüz yok |
| Genel UI tıklama | — | — | Henüz yok |

---

## Oyuncu ölümü / run bitişi

| Olay | Dosya | Tetikleyici | Durum |
|------|-------|-------------|-------|
| Oyuncu öldü / game over | — | `ui/game_over.tscn` akışı | Özel ölüm SFX yok |
| Zafer / mağlubiyet jingle | — | — | Henüz yok |

*(Düşman ölümü sesi `ölümsesi.mp3` yalnızca düşman tarafında kullanılıyor; oyuncu ile karıştırma.)*

---

## Düşman ölümü

| Olay | Dosya | Tetikleyici |
|------|-------|-------------|
| Normal düşman ölümü | `ölümsesi.mp3` | `enemies/enemy_base.gd` → `play_death()` |
| Dev (giant) ölümü | Aynı | `enemies/giant.gd` → `play_death()` |

| Olay | Dosya | Durum |
|------|-------|-------|
| Patlayan düşman / özel ölüm varyantı | — | Şu an `play_hit` / genel ölüm ile sınırlı; ayrıştırılabilir |

---

## Boss müzikleri ve boss sesleri

| Olay | Dosya | Tetikleyici | Not |
|------|-------|-------------|-----|
| Boss spawn anı | `boss spawn.mp3` | `enemies/boss.gd` → `play_boss()` | SFX |
| Boss’a özel arka plan müziği | — | — | Yok; genel `music1–6` döngüsü devam eder |
| Boss ölümü / faz geçişi | — | — | İleride |

---

## İsabet / patlama / diğer ortak SFX

| Olay | Dosya | Tetikleyici |
|------|-------|-------------|
| İsabet (düşman vurulunca) | `hasar sesi.ogg` | `enemy_base`, `shield_enemy`, `exploder` vb. → `play_hit()` |

| Olay | Dosya | Durum |
|------|-------|-------|
| Patlama (`item_explosion` vb.) | — | Ayrı patlama sesi yok |
| Sandık açılışı | — | Henüz yok |

---

## SFX durum matrisi (✅/❌)

Bu tablo, özellikle run içinde görülen sistemlerde ses olup olmadığını hızlıca takip etmek içindir.

| Sistem / olay | SFX var mı? | Dosya / çağrı | Not |
|---------------|-------------|----------------|-----|
| XP orb toplama | ✅ | `XP toplama.mp3` / `AudioManager.play_xp()` | Pitch varyasyonlu |
| Gold orb toplama | ❌ | — | Ayrı altın toplama sesi yok |
| Chest düşmesi (enemy drop) | ❌ | — | `enemy_base` yalnız spawn eder |
| Chest `OPEN` öncesi idle sallanma | ❌ | — | Görsel tween var, ses yok |
| Chest opening animasyonu | ❌ | — | Açılış için özel SFX yok |
| Chest roulette | ❌ | — | Tick/roll sesi yok |
| Chest reward `TAKE` / `DISCARD` | ❌ | — | UI/confirm sesi yok |
| Blood Oath pickup | ❌ | — | Özel pickup SFX yok |
| Vacuum collector pickup | ❌ | — | Yalnız floating text var |
| Freeze barrel patlaması | ❌ | — | Alan etkisi var, ses yok |
| Poison trap patlaması | ❌ | — | Alan etkisi var, ses yok |
| Shrine (risk/devil) tetiklenmesi | ❌ | — | Özel shrine SFX yok |
| Destructible crate kırılması | ❌ | — | Kırılma sesi yok |
| Ruin cache açılması | ❌ | — | Açılma/kırılma sesi yok |
| Düşman hasar alması | ✅ | `hasar sesi.ogg` / `AudioManager.play_hit()` | Ortak hit sesi |
| Düşman ölümü | ✅ | `ölümsesi.mp3` / `AudioManager.play_death()` | Ortak death sesi |
| Oyuncu hasar alması | ✅ | `oyuncu hasar.mp3` / `AudioManager.play_player_hurt()` | Var |
| Boss spawn | ✅ | `boss spawn.mp3` / `AudioManager.play_boss()` | Spawn stinger |
| Silah ateşi (desteklenenler) | ✅ | `ateş sesi.mp3` / `AudioManager.play_shoot()` | Şu an paylaşımlı tek ateş sesi |

---

## İleride eklenecek bölümler (taslak başlıklar)

Aşağıdakiler şimdilik boş başlık; ses işi büyüdükçe alt tablolar açılabilir.

- **Ortam (ambient)** — harita / gece-gündüz
- **UI hover / odak** — gamepad / klavye odak sesleri
- **Ko-op** — P2’ye özel cue’lar
- **Kodeks / koleksiyon** — sayfa çevirme, kilit açılma
- **Erişilebilirlik** — görsel alternatifle eşlenen işitsel ipuçları

---

*Son kod taraması: `AudioManager`, `audio_manager.tscn`, `assets/sounds/` ve `AudioManager.` çağrıları (`*.gd`).*
