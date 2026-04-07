# Ironfall — Karakter sınıfları ve kahraman tasarım çerçevesi

Oyuncunun **kendine güveni**, takımda **rolünü bilmesi** ve yeni kahramanların **tutarlı tasarlanması** için dört ana sınıf ve (P2P / co-op için) destek vizyonu bu dosyada toplanır.  
Kod envanteri (`core/character_data.gd`, sahneler): `docs/GELISTIRICI_REHBERI.md` §3.  
Görsel envanter: `docs/TASARIM.md`.

**Son güncelleme:** 2026-04-07 (4 yeni kahraman: kontrolör ×2, tank ×2)

---

## Durum özeti (repo)

| Konu | Kod / içerik | Not |
|------|----------------|-----|
| Dört sınıf tanımı (tasarım metni) | Bu dosyada | Uygulama: `CharacterData.CHARACTERS[].hero_class` (`tank` / `fighter` / `mage` / `controller` / `special`) + seçim ekranı filtresi. |
| Co-op’ta takım arkadaşına buff / destek yetenekleri | **Yok** | İkinci oyuncu seçimi akışı var (`GELISTIRICI_REHBERI.md`); “support karakter” mekaniği planlı. |
| Mevcut kahramanların sınıfa oturtulması | **Taslak** (aşağıdaki tablo) | Statların sınıfa göre yeniden ayarlanması planlı (`2.3`). |
| Yeni kahramanlar | — | Bu sınıflardan ilham alınarak tasarlanacak (`2.1`). |

---

## A. Co-op / P2P ve destek (support) vizyonu

**Hedef:** P2P ve co-op modlarında oyuncular birbirine kısa süreli güçlendirmeler verebilsin; böylece “ben takıma katkı sağlıyorum” hissi artsın.

**Planlanan örnek destek etkileri (henüz oyunda yok):**

- Kısa süreli takım arkadaşına hasar gücü.
- Sağlık yenilenmesini artırma (veya anlık toparlanma penceresi).
- Silahlarda cooldown veya alan (area) büyümesi gibi geçici buff’lar.
- Bunların ötesinde çeşitli “support” kahraman kimlikleri.

**Mevcut durum:** Co-op akışında P2 karakter seçimi vardır; yukarıdaki türde **takım odaklı yetenek setleri** ve net “support” rolleri **tasarım aşamasındadır**.

---

## B. Karakter sınıfları (dört rol)

Her kahramanın bir **sınıfı** olacak. Yeni içerik bu çerçeveye oturtulur; mevcut kahramanlar da zamanla bu sınıflara göre güçlendirilir / inceltilir.

### Sınıf 1 — Controller (Kontrolör)

Kontrolörler müttefiklere güçlü yardımlar sağlar ve **kitle kontrolü** ile düşmanları uzak tutar. Tek başına zayıf sayılabilen destek oyuncuları, takım savaşlarında müttefik gücünü büyüterek kritik anlarda hayat kurtarır veya düşman takımını alt etmeyi mümkün kılar.

### Sınıf 2 — Fighter (Savaşçı / dövüşçü)

Hem hasar vermede hem hasardan kurtulmada güçlü, **kısa menzilli** çeşitlilik. Ağır / sürekli hasara (DPS) ve doğal savunmalara yakın olurlar; uzun süren çatışmalarda başarılı olurlar. **Kısıtlı menzil** ve **kiting** / kalabalık kontrolü karşısında risk altındadırlar.

### Sınıf 3 — Mage (Büyücü)

**Geniş menzil**, yetenek tabanlı **alan hasarı** ve kitle kontrolü; düşmanları uzaktan tuzağa düşürüp yok eder. Kombol ve eşya yatırımı ile güçlenir; yeteneklerin isabeti zor olabilir, iyi tepki veren hedefler etkiyi azaltabilir.

### Sınıf 4 — Tank

Dayanıklı **yakın dövüş** şampiyonları; güçlü **kitle kontrolü** ve tehdit çekme (aggro / dikkat toplama) ile öne çıkar. Birincil amaç her zaman öldürmek değil; hedefleri **etkisizleştirmek** veya müttefiklerden tehdidi uzaklaştırmaktır.

---

## B.1 Mevcut ve gelecek kahramanlar (`2.1`)

- **Mevcut** `CharacterData.CHARACTERS` girdileri bu sınıflar üzerinden **yeniden okunur**; metinler, bonuslar ve özel kurallar sınıf fantezisiyle hizalanır.
- **Yeni** kahramanlar doğrudan bir sınıf seçilerek tasarlanır; eksik rol (ör. daha fazla Controller / Tank) bilinçli doldurulur.

---

## B.2 Bu dosyanın rolü (`2.2`)

Tasarım ve oyun dizaynı için: sınıf tanımları, sınıf başına kahraman sayısı (hedef), mevcut ID’lerin taslak sınıfı ve kısa rol notları burada tutulur. Kod tarafında sınıf alanı eklendiğinde bu tablo ile senkron tutulmalıdır.

---

## B.3 Stat ve kimlik hizalaması (`2.3`)

**Plan:** Her kahramanın `bonus_*`, `origin_bonus`, `special` ve başlangıç yükü sınıfına uygun olacak şekilde gözden geçirilecek. Bu iş **henüz tamamlanmadı**; denge değişiklikleri `YOL_HARITASI.md` ve günlükte izlenir.

---

## Mevcut kahramanlar — taslak sınıf ataması

Aşağıdaki atamalar **taslak**tır; denge ve co-op destek tasarımı netleştikçe güncellenir.  
**Özel** satırlar klasik dörtlü rol dışında veya çoklu fantezi taşır.

| `id` | Görünen ad (TR) | Taslak sınıf | Kısa gerekçe |
|------|-----------------|--------------|--------------|
| warrior | Savaşçı | Fighter | Yakın / sürekli çatışma, düz hasar ve dayanıklılık eğilimi |
| mage | Büyücü | Mage | Alan hasarı, aura başlangıcı |
| vampire | Vampir | Fighter | Yakın zincir, can çalma, bruiser |
| hunter | Avcı | Fighter | Fiziksel projectile, menzil orta |
| stormer | Fırtına | Mage | Yetenek hızı / şimşek, burst eğilimi |
| frost | Buzcu | Controller | Yavaşlatma / CC odaklı |
| sigil_warden | Mühür Ustası | Controller | Rün mühürü, alan yavaşlatma + bağlayıcı evrim |
| grav_binder | Eğim Bağlayıcı | Controller | Çekim alanı, kalabalık sıkıştırma + rezonans |
| shadow_walker | Gölge Yürüyücü | Fighter | Mobilite + gölge hasarı, assassin-fighter |
| engineer | Mühendis | Mage | Lazer / alan, yetenek konumlandırma |
| paladin | Paladin | Tank | Zırh, kutsal mermi, ön saflar |
| ironclad | Tam Zırhlı | Tank | Gürz + siper plakası, itme ve ön hat |
| linebreaker | Hat Kıran | Tank | Kalkan koşusu, koni darbe, demir siper |
| blood_prince | Kan Prensi | Fighter | Vampir soyundan agresif fighter |
| nomad | Göçebe | Fighter | Yakın menzil bıçak, mobilite |
| death_knight | Ölüm Şövalyesi | Fighter | Yüksek risk / yüksek ödül burst (özel kurallar) |
| chaos | Kaos | Özel | Rastgele silah; sınıf dışı fantezi |
| omega | Omega | Özel | Tüm silahlar / 1 HP; sınıf dışı meydan okuma |

### Sınıf başına sayı (mevcut roaster)

| Sınıf | Adet (taslak) | Kimlikler |
|-------|-----------------|-----------|
| Controller | 3 | frost, sigil_warden, grav_binder |
| Fighter | 7 | warrior, vampire, hunter, shadow_walker, blood_prince, nomad, death_knight |
| Mage | 3 | mage, stormer, engineer |
| Tank | 3 | paladin, ironclad, linebreaker |
| Özel | 2 | chaos, omega |

**Not:** Controller ve Tank havuzları bilinçle genişletilecek; co-op destek kahramanları özellikle **Controller** (ve kısmen Tank) ile örtüşebilir.

---

## İlgili plan başlıkları

- Profil / hesap seviyesi / kozmetik çerçeveler: `docs/YOL_HARITASI.md` (B — oyuncu statüsü).
- Idle / görev gönderme (altın & XP): aynı dosya (C — verimlilik).
- Rehber, kodeks, evrim sekmesi, oyun içi sözlük: aynı dosya (D — direction).
