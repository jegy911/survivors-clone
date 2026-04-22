# Vampire Survivors Wiki Analizi — Aşama 1
## Oyunumuza İlham Kaynağı: VS × Brotato × Megabonk

> Bu belge survivors-clone projesinin referans kaynağıdır.  
> Vampire Survivors wiki'sinden sistematik olarak çıkarılan bilgiler + oyunumuza uyarlanmış notlar.  
> **3 aşamada tamamlanacak. Bu: Aşama 1.**

---

## İÇİNDEKİLER

1. [Stage (Harita) Mekaniği](#1-stage-harita-mekaniği)
2. [Karakter Sistemi](#2-karakter-sistemi)
3. [Silah Sistemi](#3-silah-sistemi)
4. [Evrim Sistemi](#4-evrim-sistemi)
5. [Passive Item Sistemi](#5-passive-item-sistemi)
6. [Pickup Sistemi](#6-pickup-sistemi)
7. [Düşman Sistemi ve Wave Events](#7-düşman-sistemi-ve-wave-events)
8. [Oyunumuza Alacaklarımız — Öncelik Listesi](#8-oyunumuza-alacaklarımız--öncelik-listesi)

---

## 1. Stage (Harita) Mekaniği

### VS'de Nasıl Çalışır?

**Temel döngü:**
- Oyuncu haritada spawn olur, düşmanlar dışarıdan gelir
- Her dakika yeni bir wave başlar; her wave kendi düşman tipi, minimum düşman sayısı ve spawn interval'ına sahiptir
- 30 dakika hayatta kalınırsa "kazanılmış" sayılır; ardından Reaper gelmeye başlar

**Stage Modifiers (Her harita kendi stat bonus/cezasını taşır):**
- Player move speed, projectile speed, gold multiplier, luck
- Enemy move speed, HP, quantity
- Tüm modifier'lar birbiriyle toplanır, sonra passive item ve powerup bonuslarına çarpan olarak uygulanır

---

### VS Mod Sistemi (4 adet)

| Mod | Ne Yapar | Nasıl Açılır |
|-----|---------|--------------|
| **Hyper Mode** | Karakter ve düşman hızı +%65-75, projectile hızı +%15-25, gold x1.5 | Stage boss'unu öldür |
| **Hurry Mode** | Oyun saati 2x hızlı ilerler, XP +%25 | Sorceress' Tears relicini topla |
| **Inverse Mode** | Harita 180° döner, gold +%200, luck +%20; düşmanlar +%200 HP ile başlar, dakikada +%5 HP ve +0.5 hız kazanır | Gracia's Mirror relicini topla |
| **Endless Mode** | 30. dakikada Reaper gelmez; waves başa döner (cycle), her cycle'da düşman HP +%100, spawn sıklığı +%50, hasar +%25 | Seventh Trumpet relicini topla |

---

### VS Gameplay Modifiers

- **Arcana:** Run başında 1 arcana verilir, özel boss'lardan 2 daha alınır. Her biri benzersiz oyun değiştirici efekt taşır.
- **Limit Break:** Tüm silah ve passive'ler MAX seviyeye gelince normal seçenekler yerine "Limit Break" upgrade'leri çıkar. Silah daha da güçlenir ama evrim sonrası sıfırlanır.
- **Random Events:** Her dakikanın 30. saniyesinde bir sonraki olay belirlenir (yararlı/zararlı/nötr).
- **Random LevelUp:** Level atlayınca oyuncu seçim yapamaz; oyun otomatik item/silah seçer.

---

### 🎯 Oyunumuza Uyarlama Notları — Stage Sistemi

**Şu an sahip olduklarımız:**
- Tek harita, 30 dakika, Reaper modu ✅
- Siege sistemi (15-30dk) ✅
- Bağışıklık rotasyonu (15dk sonrası) ✅

**Eklenebilecekler (öncelik sırasıyla):**
1. **Her harita kendi modifier'ını taşısın** → `map_data.gd` dictionary'si (move_speed_bonus, gold_bonus, enemy_hp_bonus vb.)
2. **Hyper Mode** → Harita seçim ekranında toggle; boss öldürünce açılır
3. **Endless Mode** → Cycle sistemi; 30dk sonrası wave'ler başa döner
4. **Random Events** → Her dakika rastgele küçük event (VS'deki gibi roulette değil, daha sade)

---

## 2. Karakter Sistemi

### VS'de Nasıl Çalışır?

Her karakterin:
- **Temel stat farkları** var (Health, Armor, Might, MoveSpeed, Speed, Cooldown, Luck, Curse, Growth, Greed, Recovery, Amount, Revival, Reroll, Skip, Banish, Charm, Magnet, vb.)
- **Başlangıç silahı** var (karaktere özel)
- **Pasif yeteneği** var (her X level'da bonus, özel mechanic vb.)
- **Unlock koşulu** var (genellikle başka bir şeyi tamamlamak)

### VS Karakter Örnekleri ve Mekanikleri

| Karakter | Özel Mekanik | Başlangıç Silahı |
|---------|-------------|-----------------|
| Antonio | Her 10 level'da +%10 hasar (max +%50) | Whip |
| Arca | Her 10 level'da cooldown -%5 (max -%15) | Fire Wand |
| Lama | Her 10 level'da +%5 Might, MoveSpeed, Curse | Axe |
| Krochi | 1 Revival ile başlar, level 33'te +1 daha | Cross |
| Pugnala | İki silahla başlar (Phiera + Eight) | Çift silah |
| Alucard | Soul Steal, Dark Inferno, overheal'de efektler, sağlık drain'e bağışık | Alucart Sworb |
| Ariana | Hareket hızı zırha dönüşür, özel pickup bulabilir | — |
| Keitha | Her level +%1 Luck; level 30'da Academy Badge alır | Flash Arrow |
| Keremet | Overheal'de özel yetenek tetiklenir; zırh +20 ama hareket edemez | Keremet Morbus |

### VS Karakter Stat Sistemi (Tam Liste)

VS'de bir karakterin modifiye edebildiği stat'lar:

```
Health        — Max can
Armor         — Gelen hasarı azaltır
Might         — Hasar çarpanı
MoveSpeed     — Hareket hızı
Speed         — Mermi hızı
Cooldown      — Silah ateş hızı
Luck          — Nadir item çıkma şansı, pickup drop rate
Curse         — Spawn interval, düşman HP ve hız artar
Growth        — XP kazanım bonusu
Greed         — Gold kazanım bonusu
Recovery      — Saniye başına HP yenileme
Amount        — Mermi sayısı
Revival       — Canlanma hakkı
Reroll        — Level up'ta yeniden çekme
Skip          — Level up'ta seçim atlama
Banish        — Level up'tan item kaldırma
Charm         — (Özel) Düşmanları geçici olarak müttefik yapar
Magnet        — XP ve pickup çekim menzili
```

---

### 🎯 Oyunumuza Uyarlama Notları — Karakter Sistemi

**Şu an sahip olduklarımız:**
- 13 karakter, her biri `apply_character_bonuses()` ile kendi bonus'unu uygular ✅
- Temel stat'lar: HP, armor, speed, bullet_damage, cooldown, luck ✅

**Eksikler ve öneriler:**
1. **Growth stat (XP çarpanı)** → `player.gd`'de `gain_xp()`'da zaten `xp_bonus` var ama karakter bazlı Growth yok
2. **Greed stat (Gold çarpanı)** → Hiç yok, eklenebilir
3. **Revival sistemi** → Co-op'ta `downed/revive` var ama solo'da yok; karakter bazlı Revival stat'ı tanımlayabiliriz
4. **Reroll / Skip / Banish** → `upgrade_ui.gd`'de reroll/skip var mı? Kontrol edilmeli
5. **Karakter özel mechanic derinliği** → VS'de karakterlerin çok daha derin pasif yetenekleri var (her X level'da şunu yap, overheal'de şunu yap, vb.) → bizim karakterlerin de daha derin olması gerekiyor
6. **Charm mekanik** → İlginç; steampunk temamıza uygun: düşmanları geçici "robotlaştırma" olarak yorumlanabilir

---

## 3. Silah Sistemi

### VS'de Nasıl Çalışır?

Her silahın parametreleri:

| Parametre | Açıklama | Bizde var mı? |
|-----------|---------|--------------|
| Base Damage | Tek mermi/vuruş hasarı | ✅ `damage` |
| Area | Saldırı alanı | ✅ `get_area_multiplier()` |
| Speed | Mermi hızı | ✅ kısmen |
| Amount | Atılan mermi sayısı | ✅ `get_effective_multi_attack()` |
| Duration | Efekt süresi | ✅ `get_duration_multiplier()` |
| Pierce | Kaç düşmandan geçer | ❌ **YOK** |
| Cooldown | Yeniden ateş süresi | ✅ `get_effective_cooldown()` |
| Knockback | İtme gücü | ✅ `enemy_base.gd`'de |
| Luck | Item havuzundaki ağırlığı (Rarity) | ❌ YOK |
| Projectile Interval | Aynı attack içinde mermiler arası bekleme | ❌ YOK |

**VS'de silahlar Might, Area, Speed, Amount, Duration, Cooldown statlarından etkilenir.**  
Silahın max level'ı genellikle 8'dir (biz 5 kullanıyoruz).

### VS Silah Tipleri (Kategori olarak)

- **Projectile:** Düz giden mermiler (Knife, Magic Wand, Fire Wand...)
- **Area/Aura:** Etraf alan hasarı (Garlic, Santa Water, Lightning Ring...)
- **Orbit:** Oyuncunun etrafında dönen (King Bible, Gatti Amari...)
- **Beam/Laser:** Sürekli veya anlık ışın (Clock Lancet, Phiera...)
- **Chain/Bounce:** Düşmanlar arasında zıplayan (Runetracer...)
- **Boomerang:** Gidip geri dönen (Shadow Pinion...)
- **Summon:** Çağrılan yardımcılar (Peachone, Ebony Wings → Vandalier)

---

### 🎯 Oyunumuza Uyarlama Notları — Silah Sistemi

**Şu an sahip olduklarımız:** 15 silah, weapon_base.gd üzerinde çalışan sistem ✅

**Eklenecekler:**
1. **Pierce parametresi** → `bullet.gd`'de `pierce_count` eklenebilir; her düşmana çarptığında azalır
2. **Rarity/weight sistemi** → Upgrade UI'da nadir silahların daha az çıkması için ağırlık sistemi
3. **Projectile Interval** → Bir attack içinde birden fazla mermi atıldığında aralarına gecikme
4. **Silah max level 5 → 8** → VS baz alınırsa; evrim için zaten max gerekiyor, 8 daha iyi hissettiriyor

---

## 4. Evrim Sistemi

### VS'de Nasıl Çalışır?

**Temel Kural:**
> Evrim için hem **silah MAX level** hem de **passive item MAX level** gerekir.  
> İkisi de doluyken bir sandık (Treasure Chest) açıldığında evrim seçeneği çıkar.

**Evrim Türleri:**

| Tür | Açıklama | Örnek |
|-----|---------|-------|
| **Evolution** | 1 silah + 1 passive → yeni silah | Whip + Hollow Heart = Bloody Tear |
| **Union** | 2 silah + 1 passive → yeni silah | Phiera + Eight + Tirajisú = Phieraggi |
| **Gift** | Silah max seviyeye gelince otomatik verilen bonus | Candybox → Super Candybox II Turbo |
| **Morph** | Silah + Karakter + Relic + Level koşulu | Bone + Mortaccio + Chaos Malachite + Level 80 = Anima |

**Bazı evrimler için Passive Item'ın da MAX level olması gerekir.**  
Örn: `Clock Lancet + Silver Ring (max) + Gold Ring (max) = Infinite Corridor`

**Evrim zinciri de mümkün:**  
`Bracelet → Bi-Bracelet → Tri-Bracelet` (passive gerekmez, her biri bir öncekinin evrimi)

---

### 🎯 Oyunumuza Uyarlama Notları — Evrim Sistemi

**Şu an sahip olduklarımız:**  
`WeaponEvolution.gd` var, `evolve_weapon()` çalışıyor ✅  
Ama **passive item MAX level kontrolü YOK** ❌ → Bu kritik bir bug!

**Düzeltilecekler:**
```gdscript
# evolve_weapon() içinde passive kontrolü eklenecek:
func can_evolve(evo_id: String) -> bool:
    var evo = WeaponEvolution.EVOLUTIONS[evo_id]
    # Silah max seviyede mi?
    for w in evo["requires_weapons"]:
        if not active_weapons.has(w) or active_weapons[w].level < active_weapons[w].max_level:
            return false
    # Passive item max seviyede mi?
    if evo.has("requires_items"):
        for item_type in evo["requires_items"]:
            if not active_items.has(item_type) or active_items[item_type].level < active_items[item_type].max_level:
                return false
    return true
```

**Eklenecekler:**
1. **Evrim zinciri** → Örn: `weapon_storm` evrilince `weapon_storm_evolved` olabilir; ikincisi için ilki gerekli
2. **Gift tipi** → Özel koşul olmadan MAX gelince verilen bonus (örn: kan prens karakterine özel)
3. **Morph tipi** → Belirli karakter + belirli passive + belirli level koşulunda özel evrim

---

## 5. Passive Item Sistemi

### VS'de Nasıl Çalışır?

VS'de base game passive item'lar ve etkileri:

| Item | Etki | Max Level | Evrime Katkısı |
|------|------|-----------|----------------|
| Spinach | +%10 Might (max +%50) | 5 | Hellfire, Soul Eater, vb. |
| Armor | +1 Armor, +%10 retaliatory damage | 5 | NO FUTURE, Legionnaire |
| Hollow Heart | x1.2 MaxHP (max x2) | 5 | Bloody Tear, Mazo Familiar |
| Pummarola | +0.2 Recovery/sn (max +1) | 5 | Soul Eater, Festive Winds |
| Empty Tome | -%8 Cooldown (max -%40) | 5 | Holy Wand, Photonstorm |
| Candelabrador | +%10 Area (max +%50) | 5 | Death Spiral, Godai Shuffle |
| Bracer | +%10 Projectile Speed (max +%50) | 5 | Thousand Edge, Millionaire |
| Spellbinder | +%10 Duration (max +%50) | 5 | Unholy Vespers, Mannajja |
| Duplicator | +1 Amount (max +5) | 5 | Thunder Loop, Echo Night |
| Wings | +%10 MoveSpeed (max +%50) | 5 | Valkyrie Turner, Shadow Servant (max) |
| Attractorb | +%10 Magnet (max +%50) | 5 | La Borra, J'Odore |
| Clover | +%10 Luck (max +%50) | 5 | Heaven Sword, Seraphic Cry (max) |
| Crown | +%8 Growth (max +%40) | 5 | Gorgeous Moon, Luminaire |
| Stone Mask | +%10 Greed (max +%50) | 5 | Vicious Hunger, Muramasa (max) |
| Skull O'Maniac | +%10 Curse (max +%50) | 5 | Mannajja, Ophion (max) |
| Tirajisú | +1 Revival (max +3) | 3 | Phieraggi, Vampire Killer |

**Dikkat:** VS'de passive item'ların çoğu hem kendi stat etkisi hem de evrim malzemesi olarak kullanılır.

---

### 🎯 Oyunumuza Uyarlama Notları — Passive Item

**Şu an sahip olduklarımız:** 10 item (lifesteal, armor, crit, explosion, magnet, poison, shield, speed_charm, blood_pool, luck_stone) ✅

**Eksikler:**
1. **Growth/Greed/Crown tipi item'lar yok** → XP kazanım ve gold kazanım passive'leri eklenebilir
2. **Revival item'ı yok** → Tirajisú karşılığı; steampunk tema için "Clockwork Soul" olabilir
3. **Duration item'ı yok** → Zehir ve yavaşlatma süresini uzatan item
4. **Amount item'ı yok** → Mermi sayısı artıran item (Duplicator karşılığı)
5. **Item Rarity sistemi yok** → Her item aynı olasılıkla çıkıyor; VS'de nadir item'lar daha az çıkar

**Hedef:** 10 → 15-20 arası passive item (bağlam dosyasındaki uzun vadeli hedefle uyuşuyor)

---

## 6. Pickup Sistemi

### VS'de Nasıl Çalışır?

Pickup'lar düşman öldürünce veya ışık kaynağı kırılınca düşer. Magnet stat çekim yarıçapını etkiler. Çoğunun drop rate'i Luck'tan etkilenir.

### Tam Pickup Listesi

| Pickup | Efekt | Özel Not |
|--------|-------|---------|
| **Experience Gem** | XP verir | Growth stat çarpanından etkilenir |
| **Gold Coin** | +1 gold | Greed çarpanından etkilenir |
| **Coin Bag** | +10 gold | Greed çarpanından etkilenir |
| **Big Coin Bag** | +25 gold | Tüm slotlar doluyken level up'ta çıkar |
| **Rich Coin Bag** | +100 gold | Luck'tan etkilenir |
| **Rosary** | Ekrandaki tüm düşmanları öldür | Dirençli düşmanlara işe yaramaz |
| **Orologion** | 10 saniyeliğine tüm düşmanları dondur | Dirençli düşmanlara bile işe yarar |
| **Vacuum** | Haritadaki tüm XP gem'lerini çek | Sadece XP gem'leri, diğer pickup'lar değil |
| **Floor Chicken** | +30 HP | Tüm slotlar doluyken level up'ta çıkar |
| **Gilded Clover** | Tüm altınları çek + Gold Fever başlatır | Luck'tan etkilenir |
| **Little Clover** | +%10 Luck (sınırsız) | Hiçbir slotu doldurmaz, sınırsız toplanabilir |
| **Gold Finger** | Geçici yenilmezlik + Charm + min Cooldown | Öldürülen düşman sayısına göre ödül |
| **Friendship Amulet** | Co-op'ta TÜM oyuncular bir silah level atlar | Sadece co-op modda çıkar |
| **Nduja Fritta Tanto** | 10 saniyeliğine alev konileri fırlatır | Player stat'larından etkilenir |
| **Treasure Chest** | Coin + silah/item level up veya evrim | Luck chest kalitesini etkiler; 1/3/5 item evolve eder |

---

### 🎯 Oyunumuza Uyarlama Notları — Pickup Sistemi

**Şu an sahip olduklarımız:**  
XP orb, gold orb, floor chicken benzeri heal, chest ✅

**Eklenecekler (öncelik sırasıyla):**

| Öncelik | Pickup | Bizim Versiyonumuz |
|---------|--------|-------------------|
| 🔴 Kritik | **Rosary** karşılığı | "Steam Bomb" → ekrandaki tüm düşmanları öldür |
| 🔴 Kritik | **Orologion** karşılığı | "Time Gear" → 10sn dondur |
| 🟡 Önemli | **Vacuum** | "Magnet Pulse" → tüm XP'yi çek |
| 🟡 Önemli | **Little Clover** karşılığı | "Lucky Cog" → +%10 Luck, sınırsız toplanabilir |
| 🟡 Önemli | **Friendship Amulet** | Aynen ekle; co-op için süper |
| 🟢 Uzun vade | **Gold Finger** benzeri | "Power Core" → geçici yenilmezlik + efekt |
| 🟢 Uzun vade | **Big Coin Bag** | Slotlar dolunca level up'ta çıksın |

**Haritaya fiziksel item spawn:**  
VS'de haritada item'lar fiziksel olarak durur, oyuncu gidip alır.  
Bizim `environment_manager.gd`'de sandık sistemi var → aynı altyapıyla eklenebilir.

---

## 7. Düşman Sistemi ve Wave Events

### VS'de Nasıl Çalışır?

#### Temel Düşman Stat'ları

| Stat | Açıklama |
|------|---------|
| Health | Can; öldürmek için gereken hasar |
| Power | Oyuncuya temas hasarı |
| Speed (MoveSpeed) | Hareket hızı |
| Knockback | Geri itme çarpanı (bizde sabit 4.0) |
| XP | Öldürünce verilen deneyim |

#### Direnç Sistemi

| Direnç | Açıklama |
|--------|---------|
| Freeze resistance | Dondurma direnci; sayısal değer |
| Kill resistance | Anlık öldürme efektlerine bağışıklık (Rosary, Pentagram vb.) |
| Debuff resistance | Yavaşlatma, knockback azaltma vb. debuff'lara bağışıklık |
| Knockback resistance | Geri itilmez |

#### Özel Düşman Özellikleri (Skills)

| Özellik | Açıklama |
|---------|---------|
| **HP x Level** | Düşman, oyuncunun level'ına göre scale eder (spawn anında) |
| **Fixed Direction** | Sabit yönde gider; oyuncuyu takip etmez |
| **Floaty** | Sinüs dalgası hareketi (Medusa efekti) |
| **Self-destruct** | Yaklaşınca veya tetiklenince patlar |
| **Ignores collision** | Duvarlardan veya diğer düşmanlardan geçer |
| **Teleport** | Oyuncu çok uzaklaşınca ışınlanır (Reaper) |

#### Curse Efekti (Formül)

```
effectiveSpawnInterval = spawnInterval / totalCurse
```

**Bizim mevcut formülümüz:**  
`max(0.15, wave["interval"] / (1 + curse * 0.10))`  
→ Bu VS'den farklı. VS'de `totalCurse` direkt bölen. Düzeltilmeli.

#### Hyper Mode Düşman Etkisi

- Düşman hareket hızı +%65-75
- Bazı haritalar için düşman HP de artar

---

### Wave Event Sistemi (VS'den Detaylı)

VS'de normal spawn döngüsünün dışında, haritaya bağlı **kısa event'ler** tetiklenir.

#### Event Türleri

| Tür | Açıklama | VS Örneği |
|-----|---------|----------|
| **Swarm** | Düşmanlar sabit yönde çizgi halinde gelir (Fixed Direction) | Bat Swarm, Ghost Swarm, Skull Swarm |
| **Wall** | Yatay/dikey büyük bir düşman duvarı geçer | Medusa Wall, Jellyfish Wall |
| **Circle / Encircle** | Oyuncunun etrafını saran ring formasyonu | Foscari Mantichana Circle, Eyespin |
| **Pile Assault** | Etrafta sabit duran ateş eden düşmanlar spawn olur | Pile Assault (Gallo Tower) |
| **Rush** | Belirli bir düşman tipi hızla koşarak gelir | Minotaur Rush |
| **Special Event** | Global timer veya koşula bağlı, tek seferlik | The Reaper, The Stalker, The Drowner |

#### Wave Event Formülü

```
chanceWithLuck = eventChance / totalLuck
```

Her event'in tetiklenme şansı Luck tarafından azaltılır (daha şanslı oyuncu daha az event görür).  
Eğer event'in chance değeri 0 veya tanımsızsa her zaman gerçekleşir.

Her event şunları belirtir:
- Kaç düşman spawn olur
- Kaç kere tekrarlanır
- Tekrarlar arası interval

#### Trap Sistemi

VS'nin bazı haritalarında yerde **basınçlı plakalar** var. Üstüne basınca rastgele bir event tetiklenir.  
Trap cooldown'u:
```
effectiveCooldown = trapCooldown × totalLuck
```
(Şanslı oyuncu daha sık trap görür — ilginç bir tasarım tercihi!)

---

### VS'deki Wave Events — Bizim Oyunumuza Uyarlama

**Şu an sahip olduklarımız:**  
Normal spawn, siege modu (3x multiplier), reaper modu ✅  
Wave event sistemi YOK ❌

**Eklenecekler:**

#### 1. Swarm Event 🔴 KRİTİK
- 40-80 düşman, `Fixed Direction`, tek yönden hızla geçer
- Oyuncu etrafından 600px uzakta spawn, karşı tarafa geçince despawn
- 8-12 saniyede tamamlanır
- Her 3 dakikada bir şans hesabı yapılır

```gdscript
# spawn_manager.gd'ye eklenecek
func spawn_swarm_event(game_timer: float):
    var count = 50 + randi() % 30  # 50-80 arası
    var players = get_tree().get_nodes_in_group("player")
    var center = players[0].global_position
    var direction = Vector2([-1, 1].pick_random(), 0)  # sol veya sağ
    for i in count:
        var enemy = _pick_swarm_enemy(game_timer)
        main_node.add_child(enemy)
        enemy.global_position = center + Vector2(direction.x * -800, randf_range(-300, 300))
        enemy.set("fixed_direction", direction)
        enemy.set("fixed_speed", 180.0)
```

#### 2. Encircle Event 🔴 KRİTİK
- 20-40 düşman oyuncunun etrafında ring oluşturur
- Yavaş ama çok HP'li düşmanlar
- Dışarıdan sıkıştırarak gelir

```gdscript
func spawn_encircle_event(game_timer: float):
    var count = 24 + randi() % 16  # 24-40 arası
    var players = get_tree().get_nodes_in_group("player")
    var center = players[0].global_position
    for i in count:
        var angle = (2 * PI / count) * i
        var enemy = tank_enemy_scene.instantiate()  # kalın düşmanlar
        main_node.add_child(enemy)
        enemy.global_position = center + Vector2(cos(angle), sin(angle)) * 700
        _apply_scaling(enemy, game_timer)
```

#### 3. Wall Event 🟡 ÖNEMLI
- Düşmanlar yatay veya dikey bir duvar oluşturarak geçer

#### 4. Trap Sistemi 🟢 UZUN VADE
- `environment_manager.gd`'deki sunak/tuzak sistemiyle entegre edilebilir

---

## 8. Oyunumuza Alacaklarımız — Öncelik Listesi

### 🔴 KRİTİK (Bu Sprint)

| # | Görev | Dosya | Notlar |
|---|-------|-------|--------|
| 1 | **Wave Event: Swarm** | spawn_manager.gd | Fixed Direction düşman desteği gerekiyor |
| 2 | **Wave Event: Encircle** | spawn_manager.gd | Ring formasyonu |
| 3 | **Passive item max level → Evrim kontrolü** | player.gd, WeaponEvolution.gd | can_evolve() fonksiyonu |
| 4 | **Pickup: Steam Bomb (Rosary)** | effects/ | Yeni pickup scene |
| 5 | **Pickup: Time Gear (Orologion)** | effects/ | Tüm düşmanları dondur |

### 🟡 ÖNEMLİ (Sonraki 2-3 Sprint)

| # | Görev | Notlar |
|---|-------|--------|
| 6 | **XP Formülü** | VS: 5 → 15 → 25 → ... (seviye başı +10, sonra +13, +16) |
| 7 | **Pierce parametresi** | bullet.gd'ye pierce_count ekle |
| 8 | **Pickup: Vacuum / Magnet Pulse** | Haritadaki tüm XP'yi çek |
| 9 | **Pickup: Little Clover karşılığı** | Sınırsız toplanabilir Luck bonusu |
| 10 | **Friendship Amulet (Co-op)** | Co-op exclusive pickup |
| 11 | **Haritada fiziksel item spawn** | environment_manager.gd üzerine |
| 12 | **Curse formülü düzeltme** | spawnInterval / totalCurse |

### 🟢 UZUN VADE

| # | Görev | Notlar |
|---|-------|--------|
| 13 | Passive item genişletme (10→20) | Growth, Greed, Revival, Duration, Amount tipleri |
| 14 | Karakter özel mechanic derinleştirme | Her X level'da bonus vs VS tarzı |
| 15 | Item Rarity / Weight sistemi | Nadir item'lar daha az çıkacak |
| 16 | Hyper Mode harita modifier'ı | Harita seçim ekranında toggle |
| 17 | Endless Mode | Cycle sistemi |
| 18 | Trap sistemi | Basınçlı plakalar, event tetikleyiciler |
| 19 | Random Events | Her dakika rastgele event roulette |
| 20 | Wall Event | Düşman duvarı |
| 21 | Pile Assault | Etrafta ateş eden düşman kümeleri |

---

## EK: Oyunumuza Özgün Ekleyebileceklerimiz

> VS'de olmayan ama Steampunk temasına ve oyunumuza uygun fikirler:

| Fikir | Açıklama |
|-------|---------|
| **Gear Pickup** | Toplanınca anlık cooldown sıfırlar; tüm silahlar bir sonraki atışı hemen yapar |
| **Steam Vent** | Haritada sabit konumda buhar fışkırtır, yaklaşan düşmana hasar verir |
| **Sync Upgrade (Co-op)** | İki oyuncu aynı silahı seçerse her ikisi de +1 bonus seviye alır |
| **Overload** | Silah MAX seviyedeyken bir sonraki level up'ta "Overload" seçeneği çıkar; hasar +%50 ama cooldown +%30 |
| **Blueprint** | Pasif item; silahın Pierce değerini +1 yapar (Steampunk mühendis teması) |
| **Clockwork Soul** | VS Tirajisú karşılığı; Revival +1; steampunk temasında saat mekanizması |

---

*Aşama 1 tamamlandı. Aşama 2: Arcana sistemi, PowerUps, karakter unlock mekaniği, meta progression detayları.*  
*Aşama 3: Bizim oyunumuza özel tasarım kararları, mimari önerileri, sprint planı.*