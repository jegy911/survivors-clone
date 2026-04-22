# Brotato Wiki Analizi — Arena Modu Referansı
## Sadece Wave Sistemi, Düşman Scaling ve Zorluk Dengesi

> Bu belge survivors-clone projesinin **Arena Modu** tasarımı için referans kaynağıdır.  
> Brotato'nun item/silah/shop sistemleri kapsam dışıdır — sadece wave ve arena mekaniği.

---

## 1. Brotato'nun Temel Yapısı (Bizimle Farkı)

Brotato tamamen **kapalı arena** odaklıdır:
- Açık harita yok, oyuncu sabit bir alanda kalır
- Her wave **belirli süre** devam eder (timer bazlı)
- Wave biter → kısa mola → yeni wave başlar
- Toplam **20 wave**, 20. wave'de boss

VS'den temel farkı: VS'de "hayatta kalmak" hedeftir, Brotato'da "20 wave tamamlamak" hedeftir.  
**Bizim Arena modumuz tam da bu yapıyı alacak.**

---

## 2. Wave Süresi Sistemi

Brotato'da her wave'in süresi sabittir ve wave'den wave'e artar:

| Wave | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10-19 | 20 |
|------|---|---|---|---|---|---|---|---|---|-------|-----|
| Süre | 20s | 25s | 30s | 35s | 40s | 45s | 50s | 55s | 60s | 60s | 90s |

**Kural:** Her wave +5 saniye artar, 60 saniyede sabitlenir.  
**Son wave (20)** özel: 90 saniye, boss çıkar.

### 🎯 Bizim Arena Modumuz İçin Önerilen Süre Tablosu

| Wave | 1-3 | 4-7 | 8-12 | 13-17 | 18-19 | 20 |
|------|-----|-----|------|-------|-------|-----|
| Süre | 25s | 35s | 50s | 60s | 60s | 90s |

Bu daha rahat bir giriş verir, 8. wave'den sonra tam tempo başlar.

---

## 3. Düşman Skalama Sistemi

### HP Skalama
```
enemy.hp = base_hp + (hp_per_wave × wave_number - 1)
```

Örnek: Tree = base 10 HP, +5/wave → Wave 5'te 30 HP

**Ama bazı düşmanlar çok geç wave'lerde başlıyor:**  
Pursuer → Wave 11'den itibaren çıkar ama formula Wave 1'den hesaplar:  
`10 + (24 × 10) = 250 HP` — wave 11'de çok sağlam çıkar.

Bu tasarım **bilerek yapılmış**: geç wave'lere saklanan düşmanlar,  
birikmis scaling ile tehlikeli çıkar.

### Hasar Skalama
Hasar da aynı şekilde: `base_dmg + (dmg_per_wave × wave_number - 1)`

### Hız
**Hız wave'e göre değişmez.** Sadece Danger Level'a bağlıdır.

### Max Düşman Sınırı
Brotato'da ekranda aynı anda **maksimum 100 düşman** olabilir.  
Bu sayı aşılırsa rastgele bir düşman loot düşürmeden ölür.

### 🎯 Bizim Skalamız İle Karşılaştırma

| Parametre | Brotato | Bizim (şu an) | Öneri |
|-----------|---------|--------------|-------|
| HP scaling | base + x/wave | dakika başına +%5 | wave başına +%8 (arena için) |
| Hasar scaling | base + x/wave | dakika başına +%4 | wave başına +%6 (arena için) |
| Hız | sabit | dakika başına +0.005 | sabit bırak (wave bazlı arena) |
| Max düşman | 100 | 250 | Arena için 80-100 |

---

## 4. Elite ve Horde Wave Sistemi

### Elite Wave Nedir?
- Normal wave'den çok daha güçlü tek bir düşman (Elite) çıkar
- Elite'in **HP eşiği veya süre dolunca mutasyonu** değişir (farklı saldırı kalıpları)
- Öldürünce **Legendary Crate** düşürür (tier 4 garantili item)
- Elite'ler wave 11-12'de spawn olduğunda %75 HP ile gelir (biraz daha kolay)

### Horde Wave Nedir?
- Normalden çok daha fazla düşman gelir (yoğunluk artışı)
- Item düşürmez, sadece survival challenge

### Hangi Difficulty'de Kaç Elite/Horde Wave?

| Danger Level | Elite/Horde Wave Sayısı | Hangi Wave'ler |
|-------------|------------------------|----------------|
| 0-1 | 0 | — |
| 2-3 | 1 | Wave 11 veya 12 |
| 4-5 | 3 | Wave 11-12, 14-15, 17-18 (3. kesinlikle Elite) |

**Şans:** %40 Horde, %60 Elite (2. ve 3. wave için rastgele)

### Elite'lerin Mutasyon Sistemi

Her Elite'in birden fazla "fazı" var:
- Belirli bir HP yüzdesine düşünce VEYA belirli süre geçince mutasyon geçirir
- Her mutasyonda farklı saldırı kalıbı

Örnek:
```
Rhino:
  Faz 0: Her 2sn bir charge, charge sırasında sağa-sola projectile
  Faz 1 (HP %60 / 25sn): Charge daha sık (1.3sn), daha kısa mesafe + charge başında 2 ekstra mermi
```

Bu **boss fight hissi** veriyor — tek bir büyük düşman, farklı fazları var.

---

## 5. Boss Wave (Wave 20)

- Her zaman 20. wave'de, 90 saniye sürer
- **Danger 0-4:** Tek boss (Predator VEYA Invoker, rastgele)
- **Danger 5:** İki boss aynı anda, ama her biri %75 HP ile (Danger 5 %40 HP artışıyla dengelenir)

### Boss'ların Mutasyon Sistemi

**Predator:**
- Faz 0: Chase + dash + etrafında dönen projectile'lar
- Faz 1 (HP %50 / 45sn): Dash durur, tüm yönlere projectile yağmuru

**Invoker:**
- Faz 0: Her 2sn oyuncunun etrafında 1sn sonra patlayan projectile alanı
- Faz 1 (HP %75 / 30sn): Daha fazla, daha geniş alan
- Faz 2 (HP %40 / 60sn): Hız +%150, harita çapında chase + projectile halka

29.250 HP (Danger 5'te ~30.712 HP)

---

## 6. Zorluk Seviyeleri (Danger Levels)

Brotato'da run başlamadan önce 6 zorluk seviyesinden biri seçilir:

| Seviye | İsim | Modifikasyonlar |
|--------|------|----------------|
| 0 | No Modifiers | Standart oyun |
| 1 | Bull | Yeni düşmanlar çıkar |
| 2 | Soldier | Yeni düşmanlar + 1 Elite/Horde wave |
| 3 | Masochist | +%12 düşman hasar ve HP + 1 Elite/Horde wave |
| 4 | Knight | +%26 düşman hasar ve HP + 3 Elite/Horde wave |
| 5 | Demon | +%40 düşman hasar ve HP + 3 Elite/Horde wave + 2 boss |

**Önemli:** Her seviye bir öncekinin üstüne eklenir.  
**HP ve hasar artışları multiplicative** — Accessibility Slider ile çarpışır.

### Accessibility Sliders
Damage, HP ve Speed için 3 ayrı slider: %25-%200 arası ayarlanabilir.  
Bu hem kolaylaştırma hem zorlaştırma için kullanılır.

### 🎯 Bizim Arena Modumuz İçin Zorluk Önerisi

| Seviye | İsim | Modifikasyonlar |
|--------|------|----------------|
| 1 | Çaylak | Standart, Elite/Horde yok |
| 2 | Asker | +%15 düşman güç + 1 Elite wave (wave 10-12 arası) |
| 3 | Şövalye | +%30 düşman güç + 2 Elite wave + 1 Horde wave |
| 4 | Kahraman | +%50 düşman güç + 3 Elite wave + 2 boss |
| 5 | Efsane | +%75 düşman güç + 4 Elite wave + 2 boss + Endless seçeneği |

---

## 7. Düşman Davranış Çeşitliliği (Brotato'dan Notlar)

Brotato'da düşmanlar tek tip "chase" yapmaz, farklı davranış kalıpları var:

| Davranış | Açıklama | VS'de karşılığı |
|----------|---------|----------------|
| **Neutral** | Saldırmaz, sadece durur (Tree) | Yok |
| **Chaser** | Oyuncuyu takip eder | enemy_base temel AI |
| **Runner** | Oyuncudan kaçar, uzaktan ateş eder | ranged_enemy |
| **Charger** | Periyodik olarak hızlı hamle yapar | dasher |
| **Buffer** | Diğer düşmanları güçlendirir | healer (benzer) |
| **Spawner** | Ölünce yeni düşmanlar doğurur | Yok |
| **Pursuer** | Her saniye hızlanır, onu öldürmekte geç kalma | Yok |
| **Gobbler** | Materials yer, yiyince büyür | Yok |
| **Looter** | %10 ihtimalle çıkar, ölünce loot bırakır | Yok |

**Kritik fark:** Buffer düşmanı etkilediği düşmanları kırmızı çerçeve ile işaretler.  
Bizim healer'ımız da benzer ama görsel geri bildirim yok — eklenebilir.

---

## 8. Oyunumuza Direkt Uyarlama — Arena Modu Tasarımı

### Arena Modu Temel Kuralları (Önerilen)

```
- Kapalı, sabit alan (haritanın belirli bir bölümü)
- 20 wave
- Wave süresi: 25s → 60s (artan) → wave 20: 90s + boss
- Wave bitmesi için SÜRE dolmalı (Brotato gibi, VS'den farklı)
- Wave sonunda kısa mola (5-10sn) + upgrade seçimi
- Max düşman: 100 (VS'deki 250'nin aksine)
- Düşman HP: base + (wave × multiplier) formatı
- Difficulty seçimi: run başında 1-5 arası
```

### Bizim wave_manager.gd'ye Eklenecekler

```gdscript
# wave_manager.gd — Arena modu için yeni değişkenler

var arena_mode: bool = false
var arena_wave: int = 0
var arena_wave_timer: float = 0.0
var arena_difficulty: int = 1  # 1-5 arası

const ARENA_WAVE_DURATIONS = [
    0,   # index 0 kullanılmaz
    25, 25, 25,          # wave 1-3
    35, 35, 35, 35,      # wave 4-7
    50, 50, 50, 50, 50,  # wave 8-12
    60, 60, 60, 60, 60,  # wave 13-17
    60, 60,              # wave 18-19
    90                   # wave 20 (boss)
]

const ARENA_DIFFICULTY_MODIFIERS = {
    1: {"hp_mult": 1.0, "dmg_mult": 1.0, "elite_waves": []},
    2: {"hp_mult": 1.15, "dmg_mult": 1.15, "elite_waves": [11]},
    3: {"hp_mult": 1.30, "dmg_mult": 1.30, "elite_waves": [11, 15]},
    4: {"hp_mult": 1.50, "dmg_mult": 1.50, "elite_waves": [11, 14, 17]},
    5: {"hp_mult": 1.75, "dmg_mult": 1.75, "elite_waves": [11, 14, 17], "two_bosses": true},
}

func get_arena_wave_duration() -> float:
    if arena_wave <= 0 or arena_wave > 20:
        return 60.0
    return ARENA_WAVE_DURATIONS[arena_wave]

func is_elite_wave() -> bool:
    var diff = ARENA_DIFFICULTY_MODIFIERS[arena_difficulty]
    return diff["elite_waves"].has(arena_wave)

func is_boss_wave() -> bool:
    return arena_wave == 20
```

### Arena Düşman Skalama

```gdscript
# spawn_manager.gd — Arena modu için ayrı scaling
func _apply_arena_scaling(enemy: Node, wave: int, difficulty: int):
    var diff = ARENA_DIFFICULTY_MODIFIERS[difficulty]
    # HP: base + (wave - 1) × (base × 0.08)
    if enemy.get("hp") != null:
        var wave_hp = enemy.hp * (1.0 + (wave - 1) * 0.08)
        enemy.hp = int(wave_hp * diff["hp_mult"])
        enemy.max_hp = enemy.hp
    # Hasar: base + (wave - 1) × (base × 0.06)
    if enemy.get("DAMAGE") != null:
        var wave_dmg = enemy.DAMAGE * (1.0 + (wave - 1) * 0.06)
        enemy.DAMAGE = int(wave_dmg * diff["dmg_mult"])
    # Hız arena'da değişmez
```

### Wave Akışı (Arena)

```
Wave Başlar
  → Düşmanlar spawn olmaya başlar (süre boyunca)
  → Timer sayar (örn. 50 saniye)
  → Süre dolduğunda: kalan düşmanlar temizlenir
Wave Sona Erer
  → 5 saniye mola
  → Upgrade UI açılır (level atladıysa)
  → Elite wave geliyorsa uyarı gösterilir
Sonraki Wave
  → Arena difficulty modifier'ı uygulanır
  → Spawn başlar
```

---

## 9. Brotato'nun Elite Tasarımından Oyunumuza Alacaklarımız

### Bizim Boss'larımıza Mutasyon Sistemi Ekleyelim

Şu an `boss.gd`'de muhtemelen tek fazlı bir boss var.  
Brotato'nun mutasyon sistemi bize çok şey katabilir:

```gdscript
# boss.gd'ye eklenecek
var mutation_phase: int = 0
var mutation_timer: float = 0.0
const MUTATION_HP_THRESHOLDS = [0.6, 0.3]  # %60 ve %30 HP'de
const MUTATION_TIME_LIMITS = [30.0, 60.0]  # 30sn ve 60sn sonra

func _check_mutation():
    var hp_ratio = float(hp) / float(max_hp)
    if mutation_phase == 0:
        if hp_ratio <= MUTATION_HP_THRESHOLDS[0] or mutation_timer >= MUTATION_TIME_LIMITS[0]:
            _enter_mutation(1)
    elif mutation_phase == 1:
        if hp_ratio <= MUTATION_HP_THRESHOLDS[1] or mutation_timer >= MUTATION_TIME_LIMITS[1]:
            _enter_mutation(2)

func _enter_mutation(phase: int):
    mutation_phase = phase
    mutation_timer = 0.0
    # Görsel efekt
    modulate = Color("#FF4444") if phase == 1 else Color("#8B0000")
    # Hareket ve saldırı pattern değişir
    _apply_mutation_pattern(phase)
```

### Elite Düşman Ödül Sistemi

Brotato'da Elite öldürmek **Legendary item** garantiler.  
Bizim oyunumuzda Elite öldürmek şunları verebilir:

| Ödül | İhtimal |
|------|---------|
| Nadir silah upgrade | %40 |
| Tier 4 passive item | %30 |
| Büyük gold drop | %20 |
| Run boyunca kalıcı stat bonusu | %10 |

---

## 10. Özet: VS vs Brotato Arena Farkları

| Özellik | VS (Hikaye Modu) | Brotato Arena (Arena Modumuz) |
|---------|-----------------|-------------------------------|
| Alan | Açık, geniş harita | Kapalı, sabit arena |
| Süre | 30 dakika | 20 wave |
| Wave bitişi | Timer (süre dolar) | Timer (süre dolar) |
| Düşman scaling | Dakika bazlı %5 HP/dk | Wave bazlı +%8/wave |
| Boss | 30. dakikada Reaper | Wave 20'de arena boss'u |
| Elite | %15 şans, her wave | Belirli wave'lerde garantili |
| Zorluk | Curse sistemi | Difficulty Level seçimi |
| Max düşman | 250 | 80-100 |
| Wave arası | Yok (kesintisiz) | Kısa mola + upgrade |

---

*Bu belge Arena Modu implementasyonu için temel tasarım referansıdır.*  
*Hikaye Modu için VS Wiki Analizi Aşama 1 ve 2'ye bakınız.*