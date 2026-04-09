# Ironfall — Silahlar, eşyalar ve evrimler (veri tabloları)

**Kaynak:** `weapons/weapon_*.gd`, `items/item_*.gd`, `weapons/weapon_evolution.gd`  
**Not:** Oyuncu çarpanları (`get_area_multiplier()`, `get_total_damage()`, `get_cooldown_multiplier()`, `get_effective_multi_attack()`, `get_duration_multiplier()`) tablolardaki **taban** değerleri ölçekler; minimum cooldown silah bazında `WeaponBase.get_effective_cooldown()` ile **≥ 0.15s** altına inmez.

---

## 1. Level-up havuzundaki taban silahlar

Sütunlar: **Hasar** = script `damage` (oyuncu bonusları öncesi). **Alan** = yarıçap / menzil / koni gibi geometri (px veya °). **Miktar** = atış başına hedef / projektil / zincir adedi (+ `multi_attack` eklenir). **CD** = `cooldown` (saniye).

### Mermi (`bullet`)

| Lv | Hasar | Alan / menzil | Miktar | CD | Diğer |
|----|-------|---------------|--------|-----|--------|
| 1 | 10 | max_range 500 | 1 | 1.2 | En yakın hedeflere mermi |
| 2 | 12 | 500 | 2 | 1.2 | |
| 3 | 15 | 500 | 2 | 1.0 | |
| 4 | 18 | 500 | 3 | 1.0 | |
| 5 | 25 | 500 | 4 | 0.8 | |

### Aura (`aura`)

| Lv | Hasar | Alan (yarıçap) | CD | Diğer |
|----|-------|----------------|-----|--------|
| 1 | 15 | 80 | 1.0 | Alan içi hasar; yavaşlatma 0.5 × 1.5s; düşman başına vuruş aralığı 0.8s |
| 2 | 20 | 100 | 1.0 | |
| 3 | 25 | 100 | 0.8 | slow 0.4 |
| 4 | 30 | 130 | 0.8 | |
| 5 | 40 | 160 | 0.6 | slow 0.3 |

### Zincir (`chain`)

| Lv | Hasar | Alan (zincir menzili) | Miktar (sekme) | CD | Diğer |
|----|-------|------------------------|----------------|-----|--------|
| 1 | 20 | 150 | 3 | 1.5 | Hasar sekmede × bounce_mult (1.2→1.4) |
| 2 | 25 | 150 | 4 | 1.5 | |
| 3 | 30 | 200 | 4 | 1.5 | bounce 1.3 |
| 4 | 35 | 200 | 5 | 1.5 | |
| 5 | 50 | 250 | 7 | 1.0 | bounce 1.4 |

### Bumerang (`boomerang`)

| Lv | Hasar | Miktar | CD |
|----|-------|--------|-----|
| 1 | 18 | 1 | 2.0 |
| 2 | 22 | 1 | 1.8 |
| 3 | 26 | 2 | 1.8 |
| 4 | 32 | 2 | 1.5 |
| 5 | 40 | 3 | 1.2 |

### Yıldırım (`lightning`)

| Lv | Hasar | Alan (atlama menzili) | Miktar | CD |
|----|-------|------------------------|--------|-----|
| 1 | 25 | 200 | 3 | 2.0 |
| 2 | 30 | 200 | 4 | 2.0 |
| 3 | 35 | 250 | 4 | 1.8 |
| 4 | 42 | 250 | 5 | 1.8 |
| 5 | 55 | 300 | 7 | 1.5 |

### Buz topu (`ice_ball`)

| Lv | Hasar | Miktar | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 22 | 1 | 2.0 | Yavaşlatma |
| 2 | 30 | 1 | 1.8 | |
| 3 | 38 | 2 | 1.8 | |
| 4 | 48 | 2 | 1.5 | |
| 5 | 60 | 3 | 1.2 | |

### Gölge (`shadow`)

| Lv | Hasar | Alan (yörünge R) | Orb | CD | Diğer |
|----|-------|------------------|-----|-----|--------|
| 1 | 20 | 80 | 1 | 0.5 | orbit_speed 2.0 |
| 2 | 25 | 80 | 2 | 0.5 | |
| 3 | 30 | 80 | 2 | 0.5 | orbit_speed 2.5 |
| 4 | 38 | 80 | 3 | 0.5 | |
| 5 | 50 | 90 | 4 | 0.5 | orbit_speed 3.0 |

### Lazer (`laser`)

| Lv | Hasar | Alan (ışın menzili) | CD |
|----|-------|----------------------|-----|
| 1 | 30 | 600 | 1.5 |
| 2 | 38 | 600 | 1.4 |
| 3 | 45 | 600 | 1.4 |
| 4 | 55 | 600 | 1.2 |
| 5 | 70 | 600 | 1.0 |

### Yelpaze bıçak (`fan_blade`)

| Lv | Hasar | Alan (menzil / yay °) | Bıçak | CD | Diğer |
|----|-------|------------------------|-------|-----|--------|
| 1 | 7 | 175 / 28 | 3 | 1.35 | shard_speed 240, lifetime 0.18 |
| 2 | 9 | 182 / 32 | 3 | 1.35 | |
| 3 | 9 | 182 / 32 | 4 | 1.15 | |
| 4 | 12 | 190 / 36 | 4 | 1.15 | |
| 5 | 15 | 190 / 36 | 5 | 0.95 | speed 265, lifetime 0.2 |

### Altıgön mühür (`hex_sigil`)

| Lv | Hasar | Yarıçap | CD | Yavaşlatma |
|----|-------|---------|-----|------------|
| 1 | 11 | 88 | 1.05 | 0.42 × 2.0s |
| 2 | 14 | 100 | 1.05 | 0.42 × 2.0s |
| 3 | 14 | 100 | 0.92 | 0.42 × 2.3s |
| 4 | 17 | 118 | 0.92 | 0.38 × 2.3s |
| 5 | 21 | 135 | 0.78 | 0.34 × 2.3s |

### Çekim çapası (`gravity_anchor`)

| Lv | Hasar | Yarıçap | Çekim gücü | CD |
|----|-------|---------|------------|-----|
| 1 | 9 | 118 | 11 | 1.15 |
| 2 | 11 | 118 | 13 | 1.15 |
| 3 | 11 | 132 | 13 | 1.0 |
| 4 | 14 | 132 | 16 | 1.0 |
| 5 | 17 | 148 | 19 | 0.88 |

### Kale gürzü (`bastion_flail`)

| Lv | Hasar | Yarıçap | İtme | CD |
|----|-------|---------|------|-----|
| 1 | 22 | 92 | 7 | 1.25 |
| 2 | 28 | 100 | 7 | 1.25 |
| 3 | 28 | 100 | 9 | 1.1 |
| 4 | 34 | 112 | 9 | 1.1 |
| 5 | 42 | 112 | 11 | 0.95 |

### Kalkan hamlesi (`shield_ram`)

| Lv | Hasar | Koni menzil | Koni ° | CD |
|----|-------|-------------|--------|-----|
| 1 | 26 | 108 | 72 | 2.0 |
| 2 | 32 | 118 | 72 | 2.0 |
| 3 | 32 | 118 | 80 | 1.75 |
| 4 | 40 | 128 | 80 | 1.75 |
| 5 | 50 | 128 | 88 | 1.5 |

---

## 2. Evrim silahları

### Holy Bullet (`holy_bullet`)

| Lv | Hasar | Miktar | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 35 | 3 | 0.8 | Zırh kırma |
| 2 | 42 | 4 | 0.8 | |
| 3 | 50 | 4 | 0.7 | |
| 4 | 60 | 5 | 0.7 | |
| 5 | 75 | 5 | 0.5 | |

### Toxic Chain (`toxic_chain`)

| Lv | Hasar | Zincir | Menzil | CD |
|----|-------|--------|--------|-----|
| 1 | 20 | 4 | 250 | 1.5 |
| 2 | 25 | 5 | 250 | 1.5 |
| 3 | 32 | 5 | 300 | 1.5 |
| 4 | 40 | 6 | 300 | 1.5 |
| 5 | 50 | 8 | 350 | 1.5 |

### Death Laser (`death_laser`)

| Lv | Hasar | Menzil | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 60 | 1200 | 1.0 | Her vuruş kritik (×1.5 hasar) |
| 2 | 70 | 1200 | 1.0 | |
| 3 | 85 | 1300 | 1.0 | |
| 4 | 100 | 1300 | 0.9 | |
| 5 | 120 | 1500 | 0.8 | |

### Blood Boomerang (`blood_boomerang`)

| Lv | Hasar | Miktar | CD | Diğer |
|----|-------|--------|-----|--------|
| 1 | 30 | 2 | 1.5 | Lifesteal |
| 2 | 38 | 3 | 1.5 | |
| 3 | 46 | 3 | 1.2 | |
| 4 | 56 | 4 | 1.2 | |
| 5 | 70 | 4 | 1.0 | |

### Storm (`storm`)

| Lv | Hasar | Zincir | Menzil | CD | Diğer |
|----|-------|--------|--------|-----|--------|
| 1 | 40 | 3 | 200 | 1.2 | Öldürmede ekstra yıldırım |
| 2 | 48 | 4 | 200 | 1.2 | |
| 3 | 58 | 4 | 250 | 1.2 | |
| 4 | 70 | 5 | 250 | 1.2 | |
| 5 | 85 | 6 | 300 | 1.2 | |

### Gölge fırtınası (`shadow_storm`)

| Lv | Hasar | Yörünge R | CD | Diğer |
|----|-------|-----------|-----|--------|
| 1 | 35 | 80 | 0.6 | Gölge pozunda vuruş; ek zincir hasarı ~%60 |
| 2 | 42 | 90 | 0.6 | |
| 3 | 50 | 90 | 0.5 | |
| 4 | 60 | 110 | 0.5 | |
| 5 | 75 | 130 | 0.4 | |

### Buz novası (`frost_nova`)

| Lv | Hasar | Yarıçap | CD | Diğer |
|----|-------|---------|-----|--------|
| 1 | 25 | 120 | 2.0 | Dondurma; yansıtma oranı 0.3 |
| 2 | 32 | 135 | 2.0 | |
| 3 | 40 | 135 | 1.8 | |
| 4 | 50 | 150 | 1.8 | reflect 0.4 |
| 5 | 65 | 175 | 1.5 | |

### Kor yelpazesi (`ember_fan`)

| Lv | Hasar | Bıçak | CD | Menzil | Yay ° | Delici |
|----|-------|-------|-----|--------|-------|--------|
| 1 | 12 | 5 | 1.05 | 200 | 40 | 1 |
| 2 | 15 | 5 | 1.05 | 200 | 44 | 1 |
| 3 | 15 | 6 | 0.92 | 200 | 44 | 1 |
| 4 | 19 | 6 | 0.92 | 215 | 44 | 1 |
| 5 | 24 | 7 | 0.82 | 215 | 44 | 2 |

### Bağlayıcı halka (`binding_circle`)

| Lv | Hasar | Yarıçap | CD | Yavaşlatma |
|----|-------|---------|-----|------------|
| 1 | 19 | 138 | 0.88 | 0.32 × 2.6s |
| 2 | 24 | 150 | 0.88 | 0.32 × 2.6s |
| 3 | 24 | 150 | 0.76 | 0.28 × 2.6s |
| 4 | 30 | 165 | 0.76 | 0.28 × 2.6s |
| 5 | 38 | 165 | 0.65 | 0.28 × 3.0s |

### Uçurum merceği (`void_lens`)

| Lv | Hasar | Yarıçap | Çekim gücü | CD |
|----|-------|---------|------------|-----|
| 1 | 15 | 158 | 17 | 0.95 |
| 2 | 19 | 158 | 20 | 0.95 |
| 3 | 19 | 172 | 20 | 0.82 |
| 4 | 24 | 172 | 23 | 0.82 |
| 5 | 30 | 188 | 23 | 0.72 |

### Hisar zinciri (`citadel_flail`)

| Lv | Hasar | Yarıçap | İtme | CD |
|----|-------|---------|------|-----|
| 1 | 35 | 128 | 12 | 1.05 |
| 2 | 42 | 138 | 12 | 1.05 |
| 3 | 42 | 138 | 14 | 0.92 |
| 4 | 50 | 150 | 14 | 0.92 |
| 5 | 60 | 150 | 17 | 0.8 |

### Kale sur koşusu (`fortress_ram`)

| Lv sonu | Hasar | Menzil | Koni ° | CD |
|---------|-------|--------|--------|-----|
| 1 | 38 | 142 | 92 | 1.55 |
| 2 | 46 | 152 | 92 | 1.55 |
| 3 | 46 | 152 | 92 | 1.38 |
| 4 | 55 | 165 | 92 | 1.38 |
| 5 | 68 | 165 | 100 | 1.2 |

---

## 3. Pasif eşyalar (`max_level` = 5)

Formüller `level` = 1…5 için `apply()` içinden.

| ID | İsim | Kategori | Seviye başına özet |
|----|------|----------|---------------------|
| `lifesteal` | Can çalma | vampire | `steal_percent = 0.05 × level` (hasar → iyileşme) |
| `armor` | Zırh | defense | `armor_value = 2 × level` (düz hasar azaltma) |
| `crit` | Kritik | attack | `crit_chance = 0.1 × level`, çarpan 2× |
| `explosion` | Patlama | attack | Yarıçap `60 + 20×level`, hasar `10×level`, tetik `%50 + (level-1)×10` |
| `magnet` | Mıknatıs | utility | XP çekim +`80 × level` px |
| `poison` | Zehir | attack | Tick hasar `3 + 2×(level-1)`, süre `3 + 0.5×(level-1)` s (`duration_multiplier` ile) |
| `shield` | Kalkan | defense | Absorb `20 + 10×(level-1)`, CD `5 - 0.5×(level-1)` s |
| `speed_charm` | Hız tılsımı | utility | Kill’de SPEED +`40 + 15×(level-1)` süre `2 + 0.5×(level-1)` s |
| `blood_pool` | Kan havuzu | vampire | Havuz hasar `8 + 4×(level-1)`, R `60 + 15×(level-1)`, süre `3 + 0.5×(level-1)`, tetik `%40 + 12×(level-1)` |
| `luck_stone` | Şans taşı | utility | Ek kritik `5% + 3%×(level-1)`, altın/öldürme `1 + (level-1)` |
| `turbine` | Türbin | utility | Durarak biriken hareket bonusu; max düz hasar `5 + 5×(level-1)` |
| `steam_armor` | Buharlı zırh | defense | Yenilmezlik `0.8 + 0.2×(level-1)` s, CD `8 - 1×(level-1)` s |
| `energy_cell` | Enerji hücresi | utility | Şarj aralığı `20 - 3×(level-1)` s, deşarj `3 - 0.4×(level-1)` s; deşarjda tüm silahlar ateş + geçici CD×3 |
| `ember_heart` | Kor kalbi | vampire | Öldürme iyileşmesi `1 + level` HP |
| `glyph_charm` | Rün tılsımı | utility | Ward `level` (hasar azaltma, `take_damage` ile) |
| `resonance_stone` | Rezonans taşı | utility | Pickup yarıçap bonusu `22 + 10×level` |
| `rampart_plate` | Rampa plakası | defense | Zırh `2 + 2×(level-1)` |
| `iron_bulwark` | Demir siper | defense | Zırh `3 × level` |

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

Yeni silah / eşya / evrim eklediğinde bu dosyayı güncelle veya otomatik çıktı üreten bir script ekle. Tek doğruluk kaynağı her zaman ilgili `.gd` dosyalarıdır.
