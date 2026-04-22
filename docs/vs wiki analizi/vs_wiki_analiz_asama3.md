# Vampire Survivors Wiki Analizi — Aşama 3
## Silah Stat Tabloları · Limit Break · Golden Egg · Coffin · Treasure Chest · Curse Detayları

> Bu belge Aşama 1 ve Aşama 2'nin devamıdır.
> Ironfall için referans — birebir kopyalamıyoruz, kendi sesimizle yorumluyoruz.

---

## 1. Silah Sistemi — Ek Detaylar

### VS'de Silah Havuzu Nasıl Çalışır?
- Oyuncu aynı anda **maksimum 6 silah** taşıyabilir
- Her silah benzersizdir — aynı silahtan 2 tane olamaz
- Bazı silahlar haritada fiziksel olarak spawn olur ve direkt alınabilir
- Çoğu silah önce unlock edilmeli, sonra havuza girer

### Önemli Silah Mekanikleri

| Mekanik | Açıklama |
|---------|---------|
| **Projectile Interval** | Bir atışta birden fazla mermi varsa aralarındaki bekleme süresi |
| **Rarity (Ağırlık)** | Silahın level up havuzunda çıkma olasılığı — nadir silahlar daha az çıkar |
| **Ignores X** | Bazı silahlar belirli stat'lardan etkilenmez (örn. Song of Mana Speed'i yok sayar) |
| **Scales with MoveSpeed** | Bazı silahlar hareket hızından da güç alır (Shadow Pinion gibi) |

### 🎯 Ironfall'a Uyarlama
- **Rarity sistemi:** Şu an tüm silahlar eşit ağırlıkla çıkıyor → ileride nadir silahlar için `weight` parametresi eklenebilir
- **Ignores X:** Bazı Ironfall silahlarına "bu silah cooldown bonusundan etkilenmez" gibi özel kurallar eklenebilir
- **MoveSpeed scale:** Türbin ile zaten benzer bir şey yaptık — silah bazında da yapılabilir

---

## 2. Limit Break Sistemi

### VS'de Nasıl Çalışır?
- **Great Gospel** relici ile açılır
- Tüm silah ve passive item'lar MAX level'a gelince normal seçenekler (gold, chicken) yerine **Limit Break upgrade'leri** çıkar
- Her upgrade belirli bir silahın belirli bir stat'ını artırır (hasar, alan, hız, mermi sayısı vb.)
- Çoğu stat **sınırsız** stack edilebilir
- Bazı stat'ların cap'i var ama bu base değere göre, bonus'a göre değil
- Evrim sonrası Limit Break stat'ları **sıfırlanır** (bazı istisnalar hariç: SpellStrom, Alucard Shield)

### Limit Break Stat Örnekleri (Knife için)
- Damage +, Area +, Speed +, Duration +, Amount +, Pierce + (max 3 base'e göre cap'li)

### 🎯 Ironfall'a Uyarlama — "Aşım Sistemi"
VS'deki Limit Break'e karşılık bizim oyunumuzda **"Aşım"** sistemi olabilir:

> Tüm slotlar dolunca ve her şey MAX'a gelince, level up'ta normal seçenekler yerine **"Aşım Kartları"** çıkar. Her kart bir silahın sınırını zorlar — ama Ironfall temasına uygun:
> - "Buhar Basıncı Aşımı" → Silah hasarı +X ama cooldown hafif artar
> - "Rün Güçlendirme" → Alan +X ama enerji tüketimi artar (görsel efekt olarak)
> - "Teknolojik Yeniden Yapılandırma" → Tamamen yeni bir ateş modu açar

---

## 3. Golden Egg — Kalıcı Stat Sistemi

### VS'de Nasıl Çalışır?
- Merchant'tan 10.000 altına satın alınabilir (sınırsız)
- Bazı özel düşmanlar düşürür (Atlanteans, Reaper belirli koşullarda)
- Alınınca **rastgele bir stat'ı kalıcı olarak çok küçük miktarda artırır**
- Artış karaktere özeldir — o karakterin tüm run'larına kalıcı olarak eklenir
- Sınır yok — teorik olarak sonsuz toplanabilir

### Artırdığı Stat'lar
Might, MaxHealth, Armor, MoveSpeed, Speed, Cooldown, Duration, Area, Luck, Growth, Greed, Curse, Revival, Amount, Magnet, Recovery, Banish, Reroll, Skip, Charm, Omni

### 🎯 Ironfall'a Uyarlama — "Rün Taşı"
VS'deki Golden Egg'e karşılık bizim oyunumuzda **"Rün Taşı"** olabilir:

> Tüccardan satın alınır veya nadir düşmanlardan düşer. Alınınca oyuncunun **aktif karakterine** kalıcı küçük bir stat bonusu verir. Lore olarak: "Eski uygarlıktan kalma rün enerjisi — karakterin gücüne işlenmiş."

**Sistem önerisi:**
```gdscript
# save_manager.gd'ye eklenebilir
var character_rune_bonuses = {}
# {"warrior": {"might": 0.05, "speed": 0.02}, "mage": {...}}
```

---

## 4. Coffin Sistemi — Haritada Karakter Unlock

### VS'de Nasıl Çalışır?
- Belirli haritaların belirli noktalarında **Coffin (Tabut)** spawn olur
- Haritada Milky Way Map ile konumu görünür
- Tabutun etrafında bir halka düşman belirir — hepsi öldürülünce tabut açılır
- Tabut açılınca o karakteri **satın almak için açılır** (kilidi kalkar)
- Karakter hâlâ satın alma gerektiriyor

### 🎯 Ironfall'a Uyarlama — "Enkaz Kapsülü"
VS'deki tabut gibi ama tema'ya uygun:

> Haritada **"Enkaz Kapsülleri"** var — eski uygarlıktan kalma koruma sistemleri. Yaklaşınca etrafında koruyucu makineler aktive olur (düşman dalgası). Hepsini yok edince kapsül açılır, içinde yeni bir karakter unlock olur.

**Bu bize şunu katıyor:**
- Haritayı keşfetmeye teşvik (VS'deki gibi)
- Lore ile tutarlı (teknolojik kalıntı)
- Hikaye haritalarında anlatıyı derinleştirir

---

## 5. Treasure Chest (Sandık) Sistemi — Detaylı

### VS'de Nasıl Çalışır?

**4 Sandık Tipi:**

| Tip | Açıklama | İçerik |
|-----|---------|--------|
| **Bronze** | Normal boss drop | 1 item (Luck'a göre 3 veya 5) |
| **Silver** | Daha nadir, güçlü düşmanlar | Daha iyi item seçimi |
| **Arcana** | Özel boss'lardan | Arcana seçimi (11. ve 21. dk boss'ları) |
| **Black** | Çok nadir | Evrim garantili |

**İçerik mekanizması:**
- Genellikle oyuncunun **elindeki bir silah veya passive item'ı** bir level artırır
- Luck stat'ı hem drop rate'i hem içerik kalitesini etkiler
- Evrim koşulları sağlanmışsa sandık evrim seçeneği sunabilir
- 1, 3 veya 5 item verebilir (Luck'a bağlı)

### 🎯 Ironfall'a Uyarlama

**Mevcut sandbox sistemi zaten çalışıyor** (`chest.gd`). Geliştirilebilecekler:

| Öneri | Açıklama |
|-------|---------|
| **Sandık tipleri** | Bronze/Silver/Altın yerine: Pas Rengi / Demir / Rün Sandığı |
| **Luck etkisi** | Şu an sandık kalitesi sabit → Luck'a göre değişmeli |
| **Evrim sandığı** | Ayrı bir sandık tipi: koşullar sağlandıysa garantili evrim sunar |

---

## 6. Curse — Ek Detaylar

### VS'de Tam Etki Listesi

```
Spawn Interval  = baseInterval / totalCurse
Enemy MinCount  = baseMin × totalCurse  
Enemy HP        = baseHP × totalCurse
Enemy Speed     = baseSpeed × totalCurse
```

`totalCurse` = 1.0 + (curse_percentage / 100)  
Örn: +%50 Curse → totalCurse = 1.5

**Curse nasıl kazanılır:**
- PowerUp ile (en yaygın)
- Skull O'Maniac passive item (+%10/level)
- Lama karakteri başlangıç bonusu
- Wicked Season arcana (dinamik)
- Bazı harita modifier'ları

**Curse'ün avantajı:**
Daha fazla düşman = daha fazla XP + gold drop. Yüksek Curse ile oynanırsa teorik olarak daha hızlı levellenir.

### 🎯 Ironfall'a Uyarlama
Bizim mevcut Curse sistemi VS ile uyumlu. Henüz eksik olan:
- HP scaling'e Curse etkisi (spawn_manager'da `_apply_curse()` var ama test edilmeli)
- "Curse artınca XP bonusu" — şu an `gain_xp()` içinde `curse_multiplier` var ama doğru çalışıyor mu kontrol edilmeli

---

## 7. Karakter Sistemi — Ek Detaylar

### VS'de Karakter Unlock Yolları
1. **Başlangıçta açık** (Antonio, Imelda, Pasqualina vb.)
2. **Silah level** — belirli bir silahı belirli level'a çıkarınca
3. **Hayatta kalma süresi** — X dakika hayatta kalmak
4. **Kill sayısı** — toplam X düşman öldürmek
5. **Coffin açmak** — haritada tabut bulmak
6. **Gizli koşullar** — easter egg, özel kombinasyonlar
7. **Başka bir karakterle koşul** — X karakteriyle Y dakika hayatta kal

### Karakter Başlangıç Bonusları
VS'de her karakterin bir veya birkaç **başlangıç stat bonusu** var ve bunlar **level atladıkça artabiliyor**:

| Karakter | Mekanik |
|---------|---------|
| Antonio | Her 10 level'da +%10 Might (max +%50) |
| Arca | Her 10 level'da -%5 Cooldown (max -%15) |
| Lama | Her 10 level'da +%5 Might + MoveSpeed + Curse |
| Krochi | Level 33'te ekstra Revival kazanır |
| Alucard | Overheal'de özel yetenek, çoklu pasif mekanik |

### 🎯 Ironfall'a Uyarlama

Bizim karakterlerimiz şu an sabit bonus veriyor (başlangıçta +X hasar vb.). VS gibi **level bazlı büyüyen karakter yetenekleri** eklenebilir:

| Karakter | Mevcut | Öneri |
|---------|--------|-------|
| Warrior | +10 hasar | Her 5 level'da +2 hasar daha |
| Mage | +%30 alan | Her 10 level'da +%5 alan daha |
| Vampire | +%10 lifesteal | Level 15'te Kan Kalkanı açılır |
| Göçebe | fan_blade | Her öldürmede Kor Kalbi şarjı birikir |

---

## 8. Oyunumuza Yeni Eklenebilecek Fikirler (VS'den İlham, Ironfall Yorumu)

### Haritada Karakter Unlock — Enkaz Kapsülü
Hikaye haritalarında her haritaya 1 enkaz kapsülü yerleştir. Etrafında koruyucu makineler var, hepsini öldürünce kapsül açılır → yeni karakter unlock. Bu hem lore hem oynanış açısından mükemmel uyum sağlar.

### Sandık Tier Sistemi
```
Pas Sandığı    → 1 item, düşük ihtimalle
Demir Sandığı  → 1-3 item, orta kalite  
Rün Sandığı    → 3-5 item, evrim olabilir, boss'lardan düşer
```

### Rün Taşı (Golden Egg karşılığı)
Tüccardan 500-1000 altına satın alınabilir. Aktif karaktere kalıcı küçük stat bonusu. Run başına max 3 tane alınabilir.

### Aşım Sistemi (Limit Break karşılığı)
Tüm slotlar dolup her şey MAX'a gelince level up'ta Aşım Kartları çıkar. Her kart bir silahı sınırının ötesine taşır ama bir bedel getirir (steampunk teması: "aşırı basınç" = daha güçlü ama riskli).

### Level Bazlı Karakter Yetenekleri
Her karakterin her 10 level'da bir pasif yetenek kazandığı sistem. Oyunu çok daha derin hale getirir.

---

*Aşama 3 tamamlandı.*
*Bu üç aşamalık belge VS wiki'sinin Ironfall için kritik tüm sistemlerini kapsamaktadır.*