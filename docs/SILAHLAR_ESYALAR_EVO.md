# Ironfall — Silahlar, eşyalar ve evrimler (Dengelenmiş)

**Kaynak:** `weapons/weapon_*.gd`, `items/item_*.gd`, `weapons/weapon_evolution.gd` — oyun verisi bu dosyalarla senkron; denge güncellemesi PDF “Oyun Dengesi İçin Silah Verileri” ile hizalandı.

**Not:** Oyuncu çarpanları (`get_area_multiplier()`, `get_total_damage()`, `get_cooldown_multiplier()`, `get_effective_multi_attack()`, `get_duration_multiplier()`) tablolardaki **taban** değerleri ölçekler; minimum cooldown silah bazında `WeaponBase.get_effective_cooldown()` ile **≥ 0.15s** altına inmez.

---

## 1. Level-up havuzundaki taban silahlar

Sütunlar: **Hasar** = script `damage` (oyuncu bonusları öncesi). **Alan** = yarıçap / menzil / koni (px veya °). **Miktar** = atış başına hedef / projektil / zincir (+ `multi_attack`). **CD** = `cooldown` (s).

### Mermi (`bullet`)

| Lv | Hasar | Alan / menzil | Miktar | CD | Diğer |
|----|-------|---------------|--------|-----|--------|
| 1 | 8 | max_range 500 | 1 | 1.4 | En yakın hedeflere mermi |
| 2 | 10 | 500 | 2 | 1.4 | |
| 3 | 12 | 500 | 2 | 1.2 | |
| 4 | 15 | 500 | 3 | 1.2 | |
| 5 | 18 | 500 | 4 | 1.0 | |

### Aura (`aura`)

| Lv | Hasar | Alan (yarıçap) | CD | Diğer |
|----|-------|----------------|-----|--------|
| 1 | 10 | 80 | 1.2 | Alan hasar; yavaşlatma 0.2 × 1.5s; düşman başına vuruş aralığı 1.0s |
| 2 | 14 | 100 | 1.2 | |
| 3 | 18 | 100 | 1.0 | slow 0.25 |
| 4 | 22 | 120 | 1.0 | |
| 5 | 28 | 140 | 0.8 | slow 0.3 |

### Zincir (`chain`)

| Lv | Hasar | Alan (zincir menzili) | Miktar (sekme) | CD | Diğer |
|----|-------|------------------------|----------------|-----|--------|
| 1 | 15 | 150 | 2 | 1.6 | Sekmede × bounce_mult (1.1→1.2) |
| 2 | 18 | 150 | 3 | 1.6 | |
| 3 | 22 | 180 | 3 | 1.5 | bounce 1.15 |
| 4 | 26 | 180 | 4 | 1.5 | |
| 5 | 32 | 220 | 5 | 1.2 | bounce 1.2 |

### Bumerang (`boomerang`)

| Lv | Hasar | Miktar | CD |
|----|-------|--------|-----|
| 1 | 14 | 1 | 2.2 |
| 2 | 18 | 1 | 2.0 |
| 3 | 22 | 2 | 2.0 |
| 4 | 26 | 2 | 1.8 |
| 5 | 32 | 3 | 1.5 |

### Yıldırım (`lightning`)

| Lv | Hasar | Alan (atlama menzili) | Miktar | CD |
|----|-------|------------------------|--------|-----|
| 1 | 20 | 200 | 2 | 2.2 |
| 2 | 25 | 200 | 3 | 2.2 |
| 3 | 30 | 250 | 3 | 2.0 |
| 4 | 35 | 250 | 4 | 2.0 |
| 5 | 45 | 300 | 5 | 1.8 |

### Buz topu (`ice_ball`)

| Lv | Hasar | Miktar | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 18 | 1 | 2.2 | Yavaşlatma |
| 2 | 24 | 1 | 2.0 | |
| 3 | 30 | 2 | 2.0 | |
| 4 | 36 | 2 | 1.8 | |
| 5 | 45 | 3 | 1.5 | |

### Gölge (`shadow`)

| Lv | Hasar | Alan (yörünge R) | Orb | CD | Diğer |
|----|-------|------------------|-----|-----|--------|
| 1 | 12 | 80 | 1 | 0.8 | orbit_speed 2.0 |
| 2 | 16 | 80 | 2 | 0.8 | |
| 3 | 20 | 80 | 2 | 0.7 | orbit_speed 2.2 |
| 4 | 25 | 80 | 3 | 0.7 | |
| 5 | 32 | 90 | 4 | 0.6 | orbit_speed 2.5 |

### Lazer (`laser`)

| Lv | Hasar | Alan (ışın menzili) | CD |
|----|-------|----------------------|-----|
| 1 | 25 | 300 | 1.8 |
| 2 | 30 | 350 | 1.6 |
| 3 | 38 | 400 | 1.6 |
| 4 | 45 | 450 | 1.4 |
| 5 | 55 | 500 | 1.2 |

### Yelpaze bıçak (`fan_blade`)

| Lv | Hasar | Alan (menzil / yay °) | Bıçak | CD | Diğer |
|----|-------|------------------------|-------|-----|--------|
| 1 | 6 | 175 / 28 | 3 | 1.4 | shard_speed 240, lifetime 0.18 |
| 2 | 8 | 182 / 32 | 3 | 1.4 | |
| 3 | 8 | 182 / 32 | 4 | 1.2 | |
| 4 | 10 | 190 / 36 | 4 | 1.2 | |
| 5 | 13 | 190 / 36 | 5 | 1.0 | speed 265, lifetime 0.2 |

### Altıgön mühür (`hex_sigil`)

| Lv | Hasar | Yarıçap | CD | Yavaşlatma |
|----|-------|---------|-----|------------|
| 1 | 9 | 88 | 1.2 | 0.30 × 2.0s |
| 2 | 12 | 100 | 1.2 | 0.30 × 2.0s |
| 3 | 12 | 100 | 1.1 | 0.35 × 2.3s |
| 4 | 15 | 118 | 1.1 | 0.35 × 2.3s |
| 5 | 18 | 135 | 0.9 | 0.40 × 2.3s |

### Çekim çapası (`gravity_anchor`)

| Lv | Hasar | Yarıçap | Çekim gücü | CD |
|----|-------|---------|------------|-----|
| 1 | 8 | 118 | 10 | 1.3 |
| 2 | 10 | 118 | 12 | 1.3 |
| 3 | 10 | 132 | 12 | 1.1 |
| 4 | 13 | 132 | 14 | 1.1 |
| 5 | 16 | 148 | 16 | 0.95 |

### Kale gürzü (`bastion_flail`)

| Lv | Hasar | Yarıçap | İtme | CD |
|----|-------|---------|------|-----|
| 1 | 18 | 92 | 6 | 1.4 |
| 2 | 22 | 100 | 6 | 1.4 |
| 3 | 22 | 100 | 8 | 1.2 |
| 4 | 28 | 112 | 8 | 1.2 |
| 5 | 35 | 112 | 10 | 1.0 |

### Kalkan hamlesi (`shield_ram`)

| Lv | Hasar | Koni menzil | Koni ° | CD |
|----|-------|-------------|--------|-----|
| 1 | 20 | 108 | 72 | 2.2 |
| 2 | 25 | 118 | 72 | 2.2 |
| 3 | 25 | 118 | 80 | 1.9 |
| 4 | 32 | 128 | 80 | 1.9 |
| 5 | 40 | 128 | 88 | 1.6 |

---

## 2. Evrim silahları

### Holy Bullet (`holy_bullet`)

| Lv | Hasar | Miktar | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 25 | 3 | 1.0 | Zırh kırma |
| 2 | 30 | 3 | 1.0 | |
| 3 | 35 | 4 | 0.9 | |
| 4 | 42 | 4 | 0.9 | |
| 5 | 50 | 5 | 0.7 | |

### Toxic Chain (`toxic_chain`)

| Lv | Hasar | Zincir | Menzil | CD |
|----|-------|--------|--------|-----|
| 1 | 18 | 4 | 250 | 1.6 |
| 2 | 22 | 4 | 250 | 1.6 |
| 3 | 28 | 5 | 300 | 1.5 |
| 4 | 34 | 5 | 300 | 1.5 |
| 5 | 42 | 6 | 350 | 1.3 |

### Death Laser (`death_laser`)

| Lv | Hasar | Menzil | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 40 | 400 | 1.2 | Her vuruş kritik (×1.5 hasar) |
| 2 | 48 | 450 | 1.2 | |
| 3 | 55 | 500 | 1.1 | |
| 4 | 65 | 550 | 1.1 | |
| 5 | 80 | 600 | 0.9 | |

### Blood Boomerang (`blood_boomerang`)

| Lv | Hasar | Miktar | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 25 | 2 | 1.8 | Lifesteal |
| 2 | 30 | 2 | 1.8 | |
| 3 | 36 | 3 | 1.6 | |
| 4 | 44 | 3 | 1.6 | |
| 5 | 55 | 4 | 1.3 | |

### Storm (`storm`)

| Lv | Hasar | Zincir | Menzil | CD | Diğer |
|----|-------|--------|--------|-----|--------|
| 1 | 30 | 3 | 200 | 1.4 | Öldürmede ekstra yıldırım |
| 2 | 36 | 3 | 200 | 1.4 | |
| 3 | 44 | 4 | 250 | 1.3 | |
| 4 | 52 | 4 | 250 | 1.3 | |
| 5 | 65 | 5 | 300 | 1.1 | |

### Gölge fırtınası (`shadow_storm`)

| Lv | Hasar | Yörünge R | CD | Diğer |
|----|-------|-----------|-----|--------|
| 1 | 25 | 80 | 0.8 | Ek zincir hasarı ~%40 taban hasar |
| 2 | 30 | 90 | 0.8 | |
| 3 | 36 | 90 | 0.7 | |
| 4 | 44 | 110 | 0.7 | |
| 5 | 55 | 130 | 0.5 | |

### Buz novası (`frost_nova`)

| Lv | Hasar | Yarıçap | CD | Diğer |
|----|-------|---------|-----|--------|
| 1 | 20 | 120 | 2.2 | Dondurma; yansıtma 0.2 |
| 2 | 26 | 135 | 2.2 | |
| 3 | 32 | 135 | 2.0 | |
| 4 | 40 | 150 | 2.0 | reflect 0.3 |
| 5 | 52 | 175 | 1.7 | |

### Kor yelpazesi (`ember_fan`)

| Lv | Hasar | Bıçak | CD | Menzil | Yay ° | Delici |
|----|-------|-------|-----|--------|-------|--------|
| 1 | 10 | 4 | 1.2 | 200 | 40 | 1 |
| 2 | 12 | 4 | 1.2 | 200 | 44 | 1 |
| 3 | 12 | 5 | 1.0 | 200 | 44 | 1 |
| 4 | 15 | 5 | 1.0 | 215 | 44 | 1 |
| 5 | 19 | 6 | 0.9 | 215 | 44 | 2 |

### Bağlayıcı halka (`binding_circle`)

| Lv | Hasar | Yarıçap | CD | Yavaşlatma |
|----|-------|---------|-----|------------|
| 1 | 15 | 138 | 1.0 | 0.25 × 2.6s |
| 2 | 18 | 150 | 1.0 | 0.25 × 2.6s |
| 3 | 18 | 150 | 0.9 | 0.30 × 2.6s |
| 4 | 22 | 165 | 0.9 | 0.30 × 2.6s |
| 5 | 28 | 165 | 0.8 | 0.35 × 3.0s |

### Uçurum merceği (`void_lens`)

| Lv | Hasar | Yarıçap | Çekim gücü | CD |
|----|-------|---------|------------|-----|
| 1 | 12 | 158 | 14 | 1.1 |
| 2 | 15 | 158 | 16 | 1.1 |
| 3 | 15 | 172 | 16 | 0.9 |
| 4 | 18 | 172 | 18 | 0.9 |
| 5 | 23 | 188 | 20 | 0.8 |

### Hisar zinciri (`citadel_flail`)

| Lv | Hasar | Yarıçap | İtme | CD |
|----|-------|---------|------|-----|
| 1 | 28 | 128 | 10 | 1.2 |
| 2 | 34 | 138 | 10 | 1.2 |
| 3 | 34 | 138 | 12 | 1.0 |
| 4 | 40 | 150 | 12 | 1.0 |
| 5 | 48 | 150 | 14 | 0.9 |

### Kale sur koşusu (`fortress_ram`)

| Lv | Hasar | Menzil | Koni ° | CD |
|----|-------|--------|--------|-----|
| 1 | 30 | 142 | 92 | 1.8 |
| 2 | 36 | 152 | 92 | 1.8 |
| 3 | 36 | 152 | 92 | 1.5 |
| 4 | 44 | 165 | 92 | 1.5 |
| 5 | 54 | 165 | 100 | 1.3 |

---

## 3. Pasif eşyalar (`max_level` = 5)

| ID | İsim | Kategori | Seviye başına özet (dengelenmiş) |
|----|------|----------|-----------------------------------|
| `lifesteal` | Can çalma | vampire | `steal_percent = 0.01 × level` (en fazla %5) |
| `armor` | Zırh | defense | `armor_value = 1.5 × level` |
| `crit` | Kritik | attack | `crit_chance = 0.04 × level`; kritik çarpanı **1.5×** (+ meta `crit_damage_bonus`) |
| `explosion` | Patlama | attack | Yarıçap `40 + 15×level`, hasar `8×level`, tetik `%10 + (level-1)×5` |
| `magnet` | Mıknatıs | utility | XP çekim +`60 × level` px |
| `poison` | Zehir | attack | Tick `2 + (level-1)`, süre `3 + 0.5×(level-1)` s |
| `shield` | Kalkan | defense | Absorb `10 + 5×(level-1)`, CD `8 − 0.5×(level-1)` s |
| `speed_charm` | Hız tılsımı | utility | Kill’de SPEED +`20 + 10×(level-1)`, süre `2 + 0.2×(level-1)` s |
| `blood_pool` | Kan havuzu | vampire | Hasar `5 + 3×(level-1)`, R `50 + 10×(level-1)`, süre `3 + 0.5×(level-1)`, tetik `%15 + 5×(level-1)` |
| `luck_stone` | Şans taşı | utility | Ek kritik `2% + 1.5%×(level-1)`; altın/öldürme `round(1 + 0.5×(level-1))` |
| `turbine` | Türbin | utility | Max düz hasar `3 + 3×(level-1)` (hareket birikimi) |
| `steam_armor` | Buharlı zırh | defense | Yenilmezlik `0.5 + 0.1×(level-1)` s, CD `10 − 1×(level-1)` s |
| `energy_cell` | Enerji hücresi | utility | Şarj `25 − 2×(level-1)` s, deşarj `2 − 0.2×(level-1)` s |
| `ember_heart` | Kor kalbi | vampire | Öldürme: `ceil(0.2 + 0.2×level)` HP (min 1; `heal` int) |
| `glyph_charm` | Rün tılsımı | utility | Ward `0.5 × level` |
| `resonance_stone` | Rezonans taşı | utility | Pickup bonusu `15 + 5×level` |
| `rampart_plate` | Rampa plakası | defense | Zırh `1 + 1.5×(level-1)` |
| `iron_bulwark` | Demir siper | defense | Zırh `2 × level` |

---

## 4. Evrim gereksinimleri (özet)

| Evrim ID | Gerekli silah(lar) (hepsi MAX) | Gerekli eşya(lar) (hepsi MAX) |
|----------|--------------------------------|-------------------------------|
| `holy_bullet` | `bullet` | `armor` |
| `toxic_chain` | `chain` | `poison` |
| `death_laser` | `laser` | `crit` |
| `blood_boomerang` | `boomerang` | `lifesteal` |
| `storm` | `lightning` | `speed_charm` |
| `shadow_storm` | `shadow`, `lightning` | `speed_charm` |
| `frost_nova` | `ice_ball` | `armor`, `shield` |
| `ember_fan` | `fan_blade` | `ember_heart` |
| `binding_circle` | `hex_sigil` | `glyph_charm` |
| `void_lens` | `gravity_anchor` | `resonance_stone` |
| `citadel_flail` | `bastion_flail` | `rampart_plate` |
| `fortress_ram` | `shield_ram` | `iron_bulwark` |

`Blood Oath` aktifken gerekli silah seviyesi yarıya yuvarlanır (`weapon_evolution.gd`).

---

## 5. Bakım

Denge değişince önce ilgili `.gd` dosyalarını güncelle, ardından bu belgedeki tabloları eşleştir.
