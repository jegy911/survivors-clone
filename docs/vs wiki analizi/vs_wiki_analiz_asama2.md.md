# Vampire Survivors Wiki Analizi — Aşama 2
## Arcana · Curse · Relics · Merchant · PowerUps · Meta Progression

> Bu belge survivors-clone projesinin referans kaynağıdır.  
> Aşama 1'in devamıdır. Aşama 1: Stage, Karakter, Silah, Evrim, Passive, Pickup, Düşman.  
> **Bu Aşama 2: Derin sistemler ve meta progression.**

---

## İÇİNDEKİLER

1. [Arcana Sistemi](#1-arcana-sistemi)
2. [Curse Sistemi (Detaylı)](#2-curse-sistemi-detaylı)
3. [Relics Sistemi](#3-relics-sistemi)
4. [Merchant (Tüccar)](#4-merchant-tüccar)
5. [PowerUps — Meta Progression](#5-powerups--meta-progression)
6. [Fiyat Formülü (Kritik!)](#6-fiyat-formülü-kritik)
7. [Collection Sistemi](#7-collection-sistemi)
8. [Oyunumuza Uyarlama — Aşama 2 Özeti](#8-oyunumuza-uyarlama--aşama-2-özeti)

---

## 1. Arcana Sistemi

### VS'de Nasıl Çalışır?

Arcana, run boyunca seçilen **büyük oyun değiştiricilerdir** — tarot kartı temasıyla sunulur.  
Toplamda **22 Arcana + 6 Darkana** bulunur.

**Run boyunca elde etme:**
- **Başlangıçta:** Açılmış arcana'lardan birini seçersin
- **11. dakikada:** Özel boss düşer → Arcana sandığı → 4 seçenekten biri
- **21. dakikada:** Aynı şey tekrar
- Eğer oyuncunun 3+ arcana'sı varsa boss normal sandık düşürür
- 23+ arcana açılmışsa sandıklar 4 yerine 6 seçenek sunar

**3'ten fazla nasıl alınır?**
- Inverse Mode'da Merchant'tan satın alınabilir (20.000 altın)
- Endless Mode'da her cycle'da Merchant tekrar gelir
- Bazı özel karakterler ekstra arcana slotu ile başlar

---

### Tüm 22 Arcana — Tam Liste

| # | İsim | Efekt |
|---|------|-------|
| 0 | **Game Killer** | XP kazanımı durur; XP gemleri patlayan mermiye dönüşür; tüm sandıklar min. 3 item verir |
| I | **Gemini** | Listedeki silahlara bir kopya eşlik eder |
| II | **Twilight Requiem** | Mermi bitince patlama oluşur; patlama hasarı Curse'ten etkilenir |
| III | **Tragic Princess** | Hareket ederken listedeki silahların cooldown'u azalır |
| IV | **Awake** | +3 Revival; her Revival kullanımında +%10 MaxHP, +1 Armor, +%5 Might/Area/Duration/Speed |
| V | **Chaos in the Dark Night** | Mermi hızı 10sn boyunca -%50/+%50 arasında sürekli değişir; her level +%1 Speed |
| VI | **Sarabande of Healing** | Heal iki katına çıkar; HP yenilenince yakındaki düşmanlara aynı miktarda hasar verir |
| VII | **Iron Blue Will** | Listeki silah mermileri +3 sekme kazanır, düşman ve duvardan geçebilir |
| VIII | **Mad Groove** | Her 2 dakikada haritadaki tüm stage item, pickup ve ışık kaynakları karaktere çekilir |
| IX | **Divine Bloodline** | Zırh aynı zamanda listedeki silahların hasarını etkiler; eksik HP'ye göre bonus hasar; retaliatory öldürme +0.5 MaxHP verir |
| X | **Beginning** | Listedeki silahlara +1 Amount; başlangıç silahı ve evrimi +3 Amount alır |
| XI | **Waltz of Pearls** | Listedeki silah mermileri +3 sekme kazanır |
| XII | **Out of Bounds** | Dondurma patlamaya neden olur; Orologion daha kolay bulunur |
| XIII | **Wicked Season** | Growth/Luck/Greed/Curse her 2 level'da +%1 artar; sabit aralıklarda ikiye katlanır |
| XIV | **Jail of Crystal** | Listedeki silahların düşmanları dondurma şansı olur |
| XV | **Disco of Gold** | Yerden coin bag alınca Gold Fever başlar; altın kazanmak aynı miktarda HP yeniler |
| XVI | **Slash** | Listedeki silahlara kritik isabet aktif olur; tüm kritik hasar iki katına çıkar |
| XVII | **Lost & Found Painting** | Duration -%50/+%50 arasında sürekli değişir; her level +%1 Duration |
| XVIII | **Boogaloo of Illusions** | Area -%25/+%25 arasında sürekli değişir; her level +%1 Area |
| XIX | **Heart of Fire** | Listedeki silah mermileri çarpışmada patlar; ışık kaynakları patlar; oyuncu hasar alınca patlar |
| XX | **Silent Old Sanctuary** | +3 Reroll/Skip/Banish; boş silah slotu başına +%20 Might ve -%8 Cooldown |
| XXI | **Blood Astronomia** | Listedeki silahlar Amount ve Magnet'ten etkilenen özel hasar bölgeleri de yayar |

---

### 6 Darkana — Tam Liste

| # | İsim | Efekt |
|---|------|-------|
| I | **Sapphire Mist** | Tüm silahlar aktivasyonda iki kez ateş edebilir; listedekiler daha fazla |
| III | **Hidden Anathema** | Yiyecek pickup'ları nadirlikleri/heal değerlerine göre rastgele stat bonusu verir |
| VI | **Moonlight Bolero** | Her dakika ekstra bir treasure boss gelir; taşıdığı sandık bazen arcana içerebilir |
| X | **Hail from the Future** | Level atlayınca listedeki itemlardan biri verilir |
| XII | **Crystal Cries** | Donmuş düşmanı öldürmek MaxHP/Recovery/Growth bonusu verir; HP kritik seviyeye düşünce Orologion tetiklenir |
| XXI | **Wandering the Jet Black** | Hasar almak patlayan mermiler üretir; patlama Magnet ve toplam iyileşmeden etkilenir |

---

### 🎯 Oyunumuza Uyarlama Notları — Arcana

**Bizim oyunumuzda Arcana karşılığı:** `category_bonus` sistemi + `tag_crit_bonus` sistemi var ama Arcana kadar derin değil.

**Önerilen yaklaşım:** Arcana sistemini ileride **"Rune Kartı"** veya **"Steam Kartı"** adıyla ekle.  
- Run başında 1 tane seç
- 10. dakikada boss'tan 1 daha
- 20. dakikada 1 daha
- Toplam 3 kart

**Bizim oyunumuza uyarlanmış ilk 5 Arcana fikri (steampunk tema):**

| Kart | Efekt |
|------|-------|
| **Çift Dişli (Gemini)** | Tüm silahlar bir kopya mermi daha atar |
| **Buhar Şifa (Sarabande)** | Heal iki katı; HP yenilenince çevreye hasar |
| **Kritik Rune (Slash)** | Tüm silahlara kritik aktif; kritik hasar x2 |
| **Boş Slot Efendi (Silent Sanctuary)** | Boş silah slotu başına +%20 Might ve -%8 Cooldown |
| **Altın Ateş (Disco of Gold)** | Altın alınca HP yenilenir; Gold Fever tetiklenebilir |

---

## 2. Curse Sistemi (Detaylı)

### VS'de Tam Formül

**Oyuncu her zaman %100 base Curse ile başlar.**  
Stat panelinde gösterilen değer base'e göre farktır (+%30 = toplam %130 Curse).

**Etkilediği şeyler:**
- Spawn interval → daha sık düşman
- Düşman min. sayısı → daha kalabalık
- Düşman hızı → daha hızlı
- Düşman HP → daha sağlam

**Kesin Formüller:**

```
effectiveSpawnInterval = spawnInterval / totalCurse
effectiveEnemyHP       = baseHP * totalCurse
effectiveEnemySpeed    = baseSpeed * totalCurse
```

`totalCurse` = 1.0 + (curse_percentage / 100)  
Örn: +%50 Curse → totalCurse = 1.5

**Curse nasıl artar?**
- PowerUp ile satın alınabilir (+%10/rank, max +%50)
- Skull O'Maniac passive item (+%10/level)
- Bazı karakterlerin başlangıç Curse'ü yüksek (Lama: +%10)
- Wicked Season arcana (dinamik artış)

**Önemli not:** VS'de Curse hem zorluk hem ödül mekanizması —  
Curse arttıkça düşmanlar güçlenir ama oyuncu daha fazla XP/Gold kazanır (çünkü daha fazla düşman ölür).

---

### 🎯 Oyunumuza Uyarlama — Curse

**Mevcut kod (hatalı):**
```gdscript
# spawn_manager.gd
var total_curse = 1.0 + curse * 0.10
return max(0.15, wave["interval"] / total_curse)
```

**Doğru formül:**
```gdscript
# curse = SaveManager.meta_upgrades.get("curse_level", 0)
# Her level +%10 Curse ekler
var total_curse = 1.0 + curse * 0.10  # Bu kısım doğru
return max(0.15, wave["interval"] / total_curse)  # Bu da doğru aslında!
```

Aslında formülümüz VS ile uyumlu! Tek fark: VS'de `totalCurse` doğrudan yüzde olarak kullanılıyor (1.0 = %100 base). Bizim sistemimiz de bunu yapıyor.

**Eksik olan:** HP ve speed scaling'e Curse'ün dahil edilmesi.
```gdscript
# _apply_scaling() içine eklenecek:
var curse = SaveManager.meta_upgrades.get("curse_level", 0)
var curse_mult = 1.0 + curse * 0.10
enemy.hp = int(enemy.hp * hp_mult * curse_mult)      # Curse HP'yi de etkilesin
enemy.current_speed *= (spd_mult * (1.0 + curse * 0.05))  # Curse hızı da etkilesin
```

---

## 3. Relics Sistemi

### VS'de Nasıl Çalışır?

Relics = **haritada fiziksel olarak duran, bir kez alınınca kalıcı olan kilit açma itemları.**  
Yeşil ok ile gösterilir. Alındıktan sonra bir daha görünmez.

**Base game Relics tam listesi:**

| Relic | Efekt | Konum |
|-------|-------|-------|
| Grim Grimoire | Pause menüde evrim listesini gösterir | Inlaid Library, batı |
| Ars Gouda | Bestiary menüsünü açar | Dairy Plant, güney |
| Milky Way Map | Pause menüde haritayı açar; stage item konumlarını gösterir | Dairy Plant, güney |
| Magic Banger | Stage Selection'da müzik değiştirmeye izin verir | Green Acres |
| Randomazzo | Arcana sistemini açar; ilk arcana'yı verir (Sarabande of Healing) | Gallo Tower |
| Glass Vizard | Merchant'ın tüm haritalar aktif olmasını sağlar | Moongolow (satın alma) |
| Sorceress' Tears | Hurry Mode'u açar | Gallo Tower |
| Gracia's Mirror | Inverse Mode'u açar | Eudaimonia Machine |
| Seventh Trumpet | Endless Mode'u açar | Eudaimonia Machine |
| Yellow Sign | Özel boss spawn'larını ve gizli içerikleri açar | Holy Forbidden |
| Great Gospel | Limit Break'i açar | Cappella Magna |
| Forbidden Scrolls of Morbane | Gizli şifre sistemini açar | The Bone Zone |
| Darkasso | Darkana sistemini açar | Room 1665 |

**Haritaya özel relics (birden fazla):**  
Chaos Malachite, Chaos Rosalia, Chaos Altemanna (Morph evrimi için), Trisection (Random Events), Brave Story (Random LevelUp), vb.

---

### 🎯 Oyunumuza Uyarlama — Relics

Bu sistem bizim **meta upgrade** + **achievement** sistemiyle örtüşüyor ama daha ilginç bir şekilde tasarlanmış.  

VS'de Relics kalıcı feature unlock'tur — **run içinde haritada bulunur.**  
Bizde meta upgrade menüsü üzerinden satın alınıyor.

**Öneri:** Bazı sistemleri meta upgrade'den çıkarıp **"harita içinde relic bul"** mekanik olarak sunabiliriz. Örnek:

| Relic (bizim versyion) | Efekt | Nerede |
|------------------------|-------|--------|
| **Dişli Grimuar** | Pause menüde evrim listesini göster | 1. haritada |
| **Buhar Haritası** | Harita görünümünü aç | 2. haritada |
| **Kron Sinyali** | Arcana/Rune Kartı sistemini aç | 3. haritada |

---

## 4. Merchant (Tüccar)

### VS'de Nasıl Çalışır?

Merchant başlangıçta sadece Moongolow'da görünür.  
Glass Vizard satın alınınca tüm haritalar aktif olur.

**Satılan ürünler:**

| Ürün | Fiyat | Not |
|------|-------|-----|
| Golden Egg | 10.000 | Kalıcı rastgele stat +; sınırsız alınabilir |
| Pick a Card (Arcana) | 20.000 | Sadece Inverse Mode |
| Skip | 100 | Sadece Inverse Mode, max 20 |
| Banish | 500 | Sadece Inverse Mode, max 20 |
| Reroll | 1.000 | Sadece Inverse Mode, max 20 |
| Bone / Cherry Bomb / vb. | 1.000 | Karakter bazlı özel silahlar |
| Candybox | 1.000 | Sadece Queen Sigma karakteriyle |

**Golden Egg özelliği:** Rastgele bir stat'ı çok küçük miktarda kalıcı artırır. Run sonunda da alınabilir. Endless Mode'da her cycle'da Merchant tekrar gelir.

---

### 🎯 Oyunumuza Uyarlama — Merchant

Bizde şu an tüccar yok.  

**Öneri:** `environment_manager.gd`'deki sandık/sunak sistemine ek olarak run içinde bir **Tüccar NPC** eklenebilir.

| Tüccar Ürünü | Fiyat | Etki |
|-------------|-------|------|
| Ekstra Reroll | 50 gold | O level up için +1 reroll |
| Pasif Item | 100-200 gold | Rastgele passive |
| Silah | 150-300 gold | Rastgele silah |
| Kalıcı Stat (Şans Yumurtası) | 500 gold | Küçük kalıcı stat artışı (meta'ya kaydedilir) |

---

## 5. PowerUps — Meta Progression

### VS'de Nasıl Çalışır?

PowerUps = **run'lar arası kalıcı iyileştirmeler.** Altın harcayarak satın alınır.  
Bizim "meta upgrade" sistemimizin tam karşılığı.

**Tüm 24 PowerUp — Tam Liste:**

| PowerUp | Etki/Rank | Max Rank | Base Fiyat |
|---------|----------|---------|-----------|
| **Might** | +%5 hasar | 5 | 200 |
| **Armor** | +1 zırh | 3 | 600 |
| **Max Health** | +%10 max HP | 3 | 200 |
| **Recovery** | +0.1 HP/sn | 5 | 200 |
| **Cooldown** | -%2.5 cooldown | 2 | 900 |
| **Area** | +%5 alan | 2 | 300 |
| **Speed** | +%10 mermi hızı | 2 | 300 |
| **Duration** | +%15 süre | 2 | 300 |
| **Amount** | +1 mermi (tüm silahlara) | 1 | 5.000 |
| **Move Speed** | +%5 hareket hızı | 2 | 300 |
| **Magnet** | +%25 pickup menzili | 2 | 300 |
| **Luck** | +%10 şans | 3 | 600 |
| **Growth** | +%3 XP kazanımı | 5 | 900 |
| **Greed** | +%10 altın kazanımı | 5 | 200 |
| **Curse** | +%10 düşman güç/sıklık | 5 | 1.666 |
| **Revival** | +1 canlanma hakkı | 1 | 10.000 |
| **Omni** | +%2 Might/Speed/Duration/Area | 5 | 1.000 |
| **Charm** | +20 düşman spawn sayısı | 5 | 10.000 |
| **Defang** | Düşmanlar %3 ihtimalle hasarsız spawn olur | 5 | 10 |
| **Reroll** | +2 reroll/rank | 5 | 1.000 |
| **Skip** | +2 skip/rank | 5 | 100 |
| **Banish** | +2 banish/rank | 5 | 100 |
| **Seal I/II/III** | Belirli item'ları kalıcı banish et | 10 | 10.000 |

**Önemli notlar:**
- MAX rank sonra PowerUp **devre dışı bırakılabilir** (Curse'ü kapatmak için kullanışlı)
- Refund yapılabilir (az altın kaybıyla)

---

## 6. Fiyat Formülü (Kritik!)

### VS'nin Kesin Formülü

```
Price = BaseCost + Fees

BaseCost = InitialPrice × (1 + Bought)
Fees     = floor(20 × 1.1^TotalBought)   [TotalBought=0 ise Fees=0]
```

**Terimler:**
- `InitialPrice` = O PowerUp'ın sıfır rank'taki fiyatı
- `Bought` = O PowerUp'tan kaç rank alınmış
- `TotalBought` = Tüm PowerUp'lardan toplam alınan rank sayısı

**Örnek:**  
Might'ın (InitialPrice=200) 3. rank'ını alıyoruz, toplam TotalBought=10 olmuş:
```
BaseCost = 200 × (1 + 2) = 600
Fees     = floor(20 × 1.1^10) = floor(20 × 2.5937) = floor(51.87) = 51
Price    = 600 + 51 = 651
```

**Sıranın önemi yok** — v0.7.2'den beri fees additive, sıra fark etmez.

---

### 🎯 Oyunumuza Uyarlama — Fiyat Formülü

**Mevcut `save_manager.gd`'deki formül** kontrol edilmeli.  
Bağlam dosyasında şu hedef yazıyor:
```
Meta upgrade fiyat formülü: InitialPrice*(1+bought) + floor(20*1.1^totalBought)
```

Bu tam VS formülü — henüz implement edilmemiş. Örnek implementasyon:

```gdscript
# save_manager.gd'ye eklenecek
func get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
    var defs = {
        "max_hp_bonus":    {"price": 200, "max": 5},
        "damage_bonus":    {"price": 300, "max": 5},
        "speed_bonus":     {"price": 300, "max": 5},
        "xp_bonus":        {"price": 900, "max": 5},
        "luck_bonus":      {"price": 600, "max": 5},
        "cooldown_bonus":  {"price": 900, "max": 5},
        "curse_level":     {"price": 1666, "max": 5},
        "reroll_bonus":    {"price": 1000, "max": 3},
        "skip_bonus":      {"price": 100, "max": 3},
        # ... diğerleri
    }
    if not defs.has(upgrade_id):
        return 999999
    var initial = defs[upgrade_id]["price"]
    var bought = current_level
    var total_bought = _get_total_bought()
    var base_cost = initial * (1 + bought)
    var fees = 0 if total_bought == 0 else int(20.0 * pow(1.1, total_bought))
    return base_cost + fees

func _get_total_bought() -> int:
    var total = 0
    for key in meta_upgrades:
        total += meta_upgrades[key]
    return total
```

---

## 7. Collection Sistemi

### VS'de Nasıl Çalışır?

Collection = Oyunda görülen tüm silah/item'ların **görsel kataloğu.**  
Her item için: adı, ikonu, evrimi varsa ikon zinciri.  

**Özel Collection özellikleri:**
- **Seal:** Belirli item'ları level up havuzundan kalıcı çıkar
- **Bestiary:** Düşmanların detaylı stat'ları (Ars Gouda relic'i gerekir)
- **Grimoire:** Evrim koşulları (Grim Grimoire relic'i gerekir)

VS'de oyuncu merak ettiği evrim kombinasyonunu Grimoire'dan görebilir — spoiler olmadan.  
Bu, oyun içi kılavuz görevi görür.

---

### 🎯 Oyunumuza Uyarlama — Collection

**Öneri:** Bizim oyunumuzda da benzer bir sistem:

1. **Grimuar / Blueprint Menüsü:** Hangi silah + passive ile ne evriliyor, göster
2. **Bestiary:** Run sırasında kaç düşman öldürdüğünü takip et, üzerine tıklayınca stat'larını gör
3. **Silah Kataloğu:** Sahip olduğun/olmadığın silahları gösteren scroll listesi
4. **Seal benzeri:** Belirli item'ları gelecek run'larda havuzdan çıkarma hakkı

---

## 8. Oyunumuza Uyarlama — Aşama 2 Özeti

### Kesinlikle Eklenecekler (Aşama 2 Öncelik Listesi)

#### 🔴 KRİTİK

| Görev | Kaynak | Notlar |
|-------|--------|--------|
| **Curse → HP ve Speed scaling'e dahil et** | save_manager + spawn_manager | `_apply_scaling()`'e curse_mult ekle |
| **PowerUp fiyat formülü** | save_manager.gd | VS formülü: `InitialPrice*(1+bought) + floor(20*1.1^total)` |
| **Evrim passive max level kontrolü** | player.gd | `can_evolve()` fonksiyonu; Aşama 1'de taslak var |

#### 🟡 ÖNEMLİ

| Görev | Kaynak | Notlar |
|-------|--------|--------|
| **Arcana/Rune Kart sistemi** | wave_manager + yeni ui | Run başında 1; boss'tan 2; toplam 3 |
| **Tüccar NPC** | environment_manager | Run içinde; reroll/passive/silah satar |
| **Grimuar menüsü** | ui/ | Evrim koşullarını gösterir |
| **PowerUp devre dışı bırakma** | meta_upgrade.gd | MAX rank'taki upgrade'i toggle edebilmek |

#### 🟢 UZUN VADE

| Görev | Kaynak | Notlar |
|-------|--------|--------|
| **Relic sistemi** | harita tasarımı | Haritada fiziksel relic; kalıcı feature unlock |
| **Golden Egg** | save_manager | Küçük kalıcı stat artışı; tüccarda satılır |
| **Seal sistemi** | meta_upgrade + collection | Item'ı kalıcı banish et |
| **Bestiary** | ui/ + enemy_base | Öldürülen düşman sayısı + stat'ları |
| **Endless Mode** | wave_manager | 30dk sonrası cycle; her cycle düşman +%100 HP |
| **Limit Break** | weapon_base | Tüm slotlar doluyken silah limit ötesi upgrade |

---

### Oyunumuza Özgün Arcana Fikirleri (VS'de Yok)

> Steampunk temamıza uygun, kendi sesimizle tasarlanmış kart fikirleri:

| Kart Adı | Efekt |
|----------|-------|
| **Çift Kazan** | Bir sonraki her level-up'ta 2 seçim yerine 4 seçim çıkar |
| **Buhar Fazla Basınç** | HP %50'nin altındayken tüm hasar +%40 artar (Berserk) |
| **Dişli Fırtına** | Her 5. öldürme ekstra XP orb bırakır |
| **Zaman Kristali** | Tüm cooldown'lar anlık sıfırlanır; 10sn boyunca -%30 cooldown |
| **Demir Kalkan** | İlk aldığın hasar her 30sn'de bir sıfırlanır (shield recharge) |
| **Kan Antlaşması** | HP'nin %10'unu feda et; tüm silahlar +%50 hasar kazanır (30sn) |
| **Yankı** | Son kullanılan silah 2sn içinde otomatik tekrar tetiklenir |

---

*Aşama 2 tamamlandı.*  
*Aşama 3: Brotato + Megabonk wiki analizi; oyunumuza özgün tasarım kararları.*