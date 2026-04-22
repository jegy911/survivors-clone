# Ironfall — Lore (canon notları)

Bu dosya, **oyun evreni ve anlatı** üzerinde bu sohbet ve tasarım sürecinde netleşen bilgileri toplar. Amaç: yeni **karakter, silah, eşya, harita, düşman ve boss** tasarımlarının aynı çerçevede tutarlı kalması; gerektiğinde kasıtlı “weird” seçimlerin bile lore ile gerekçelenebilmesi.

**Kullanım:** İçerik eklerken veya kod/UI tarafında isim–görsel–yetenek üçlüsünü hizalamak için buraya bakılır. Bu belge güncellendikçe alt bölümlere tarih veya “not” satırları eklenebilir.

---

## 1. Dünya özeti (yüksek seviye)

İnsan uygarlığı bir zamanlar **olağanüstü teknoloji**ye sahipti: enerji silahları, gelişmiş zırh ve hareket/güç artırıcı eşyalar, güçlü artefaktlar ve benzeri sistemler.

**Çöküş:** Uygarlığın yıkımına yol açan olay, **şeytani bir uyanış / karanlık güç** ile bağlantılıdır. Bu süreçte ortaya çıkan **rün teknolojisi** (veya rünlerin dünyaya yayılması), eski düzenin parçalanmasında merkezi bir rol oynar.

**Günümüz (oyun anı):** Kalan insanlık, dışarıdan bakınca **orta çağ benzeri** bir yaşam sürer: kaleler, basit üretim, sınırlı altyapı. Buna karşılık ellerinde hâlâ **eski çağdan kalma silah ve cihazlar**, **ilkel görünümlü ama rünlerle güçlendirilmiş** ekipman ve **rün bilgisine dayanan** kullanım biçimleri vardır. Yani estetik “feodal + harabe teknoloji + rün işçiliği” karışımıdır.

**Hikâye modu hedefi (endgame):** Oyuncunun uzun vadeli anlatı hedefi, bu şeytani gücün başındaki **Şeytani Kral**’ı (veya eşdeğer baş düşman otoritesi) yenmektir. Boss sahneleri ve üst düzey düşmanlar bu çatışmanın hiyerarşisine göre tasarlanır.

---

## 2. Tasarım ilkeleri (lore ↔ oyun içeriği)

- **Uyum:** Karakterin silahı, zırhı ve taşıdığı eşyalar aynı dünyadan geliyormuş hissini güçlendirmeli; bir araya gelince “rastgele asset” değil, **aynı çöküş sonrası kültürün parçaları** gibi durmalı.
- **Kasıtlı tuhaflık:** Bazı kahramanlar veya kombinasyonlar bilinçli olarak alışılmadık görünebilir; bu, lore ile **gerekçelendirildiği sürece** sorun değildir (ör. nadir kalıntı, sapkın rün ustası, tarikat silahı).
- **Teknoloji–rün ekseni:** Bir öğe ya **Antik Kalıntı** (eski düzen), ya **Rün İşlemeli** (çöküş sonrası bilgi), ya da ikisinin **hibriti** olarak düşünülebilir; yeni içerik eklerken hangi koldan geldiğini netleştirmek faydalıdır.
- **Başlangıç yükü:** Kahraman seçiminde **yalnızca başlangıç silahı** verilir; imza **eşya** (evrime giden çiftin ikinci parçası) **koşu içinde** level-up / sandık vb. ile toplanır — seçim ekranı ve kodeks metinleri “silah / eşya / evrim” bilgisini anlatı amaçlı sunar.

---

## 3. Kahramanlar (mevcut netleşen örnekler)

### 3.1 Savaşçı (Warrior)

- **Görsel kimlik:** Orta çağ tarzı zırhlı savaşçı; elinde **Desert Eagle** benzeri bir tabanca (eski dünyadan kalma veya ona eşdeğer “anakronik” ateşli silah).
- **Oyun notu:** Ana saldırı kimliği kodda geçici olarak **`bullet`** adıyla tutulmuştur; ileride **`weapon`** (veya evrene uygun nihai isim) ile hizalanacaktır. Lore tarafında bu, “ateşli/antik mekanizmalı birincil silah” olarak düşünülür.

### 3.2 Büyücü (Mage)

- **Görsel kimlik:** Üzerinde **işlenmiş rünler** bulunan cübbe; elinde büyülü ışıklar yayan bir **fener** (veya fener formunda bir odak cihazı).
- **Oyun notu:** Birincil saldırı tipi **`aura`** benzeri bir yapıdadır (alan/emanasyon); lore’da bu, rünlerin ışık ve enerjiyi **fener üzerinden** yönlendirmesi olarak yorumlanabilir.

### 3.3 Mühür Ustası (Sigil Warden) — kontrolör

- **Tema:** Çöküş öncesi **rün mühürleri**ni taşıyan uzman; düşmanları yerinde tutan **altıgen işaretler** (oyunda `hex_sigil` / evrim `binding_circle`).
- **Eşya:** **Rün Tılsımı** (`glyph_charm`) — taşınan mühürlerin oyuncuya yansıyan koruyucu katmanı (düz hasar azaltma).

### 3.4 Eğim Bağlayıcı (Grav Binder) — kontrolör

- **Tema:** Harabe **çekim alanı** / antik yerçekimi kalıntısı; kalabalığı tek noktada toplar (`gravity_anchor` → `void_lens`).
- **Eşya:** **Rezonans Taşı** — alan içi enerjinin XP ve ganimet çekimine “rezonans” ile yansıması (genişletilmiş toplama yarıçapı).

### 3.5 Tam Zırhlı (Ironclad) — tank

- **Tema:** Ön hat **sur / kale** doktrini; gürzle çember çizip düşmanı iter (`bastion_flail` → `citadel_flail`).
- **Eşya:** **Rampa Plakası** — üst üste bağlanan levhalarla ek zırh (Paladin’den farklı, siper ağırlıklı fantezi).

### 3.6 Hat Kıran (Linebreaker) — tank

- **Tema:** **Kalkan hamlesi** ile hat yaran ağır piyade; koni darbesi (`shield_ram` → `fortress_ram`).
- **Eşya:** **Demir Siper** — kalın ön siper; düz hasar kesintisi (rampa plakasından ayrı kimlik).

### 3.7 Göçebe (Nomad) — fighter

- **Tema:** Sürgün edilmiş **yakın dövüş** avcısı; çöl / yol teması ile hizalı **yelpaze bıçak** ritmi.
- **Silah + eşya + evrim (koşu içi):** Başlangıçta yalnızca **Yelpaze Bıçak** (`fan_blade`). **Kor Kalbi** (`ember_heart`) koşuda toplanır; ikisi MAX iken **Kor Yelpazesi** (`ember_fan`) — diğer kahramanlardaki “imza silah + eşya çifti” anlatı çerçevesiyle aynı, fakat **başlangıç yükünde eşya verilmez**.

### 3.8 Alacakaranlık Hançeri (`dusk_striker`) — fighter

- **Tema:** Gölge Yürüyücü ile aynı “sessiz av” hattında; fakat silah **çift fırlatılabilir hançer** (`dagger`) — hafif, hızlı ritimli antik/hibrit bıçaklar. Arena’da Gölge Yürüyücü ile kanıtlanmış cesaret, loncada **Alacakaranlık Hançeri** unvanını açar (oyun: kısa Arena koşusunu kazanma + satın alma).
- **Kart özeti (`CharacterData` / kodeks ile uyumlu):** Silah `dagger` (İkiz Hançer); **Gece Şişesi** (`night_vial`) koşuda (level-up, sandık vb.) toplanır; evrim **Peçe Hançerleri** (`veil_daggers`): `dagger` + `night_vial` ikisi MAX; açılış Arena + Gölge Yürüyücü + **380** altın; köken hız / max can — `core/character_data.gd`, `codex.character.dusk`.
- **Sahne:** Oyuncu kökü `res://characters/dusk/dusk.tscn` (Gölge Yürüyücü’nden ayrı dosya). `AnimatedSprite2D` animasyon **isimleri** korunur; **frame** listeleri boş — dusk’a özel sprite/atlas eklendiğinde doldurulur.

---

## 4. Düşmanlar ve bosslar (çerçeve)

- Düşman ve boss tasarımları **şeytani uyanış** hiyerarşisi ve **rün bozulması / yozlaşma** temalarıyla ilişkilendirilebilir.
- Boss sahneleri, anlatıda **Şeytani Kral**’a giden yolun kilometre taşları olarak düşünülür; her boss için kısa bir “kimdir, neyi temsil eder, rün/teknik ilişkisi nedir” maddesi ileride bu dosyaya eklenebilir.

### 4.1 Wiki-arşiv (VS / Brotato) — anlatıya oturtulabilecek motifler

Kaynak: `docs/vs wiki analizi/` (oyun fikrinin başında tutulan referans notları). Oyun metnine aktarırken **isimler uyarlanır**; çöküş sonrası + rün + kalıntı teknoloji çerçevesi (§1–3) ile çelişmemeli.

- **Enkaz kapsülü** — haritada kilitli bir **kalıntı koruma ünitesi**; çevredeki otomatonlar / yozlaşmış korumalar (düşman dalgası) susturulunca içerideki “kayıt” loncaya açılır: yeni kahraman veya kalıcı özellik (VS *Coffin* izi).
- **Rün taşı** — nadir düşme veya tüccarda; belirli bir kahramana bağlı **kalıcı minik güç artışı** — “eski uygarlığın işlenmiş enerjisi” olarak §1’deki rün ekseniyle örtüşür (VS *Golden Egg* izi).
- **Buhar / dişli / zaman dişlisi** — özel pickup’lar için **görünen dünya adı**: alan baskını, kısa duraksama, tek darbede XP toplanması vb.; kodeks “dünya” ve `sesler-muzikler-efektler.md` ile hizalanır.

---

## 5. Değişiklik günlüğü (özet)

| Tarih | Özet |
|-------|------|
| 2026-04-07 | İlk taslak: çöküş sonrası dünya, rün + kalıntı teknoloji, Şeytani Kral endgame hedefi; Warrior (Desert Eagle / bullet→weapon notu), Mage (rün cübbesi, fener, aura). |
| 2026-04-07 | Dört yeni kahraman (kontrolör ×2, tank ×2): Mühür Ustası, Eğim Bağlayıcı, Tam Zırhlı, Hat Kıran — her biri özel silah + eşya + evrim çifti; kod ID’leri `sigil_warden`, `grav_binder`, `ironclad`, `linebreaker`. |
| 2026-04-07 | **Göçebe (nomad)** — Yelpaze Bıçak + (koşuda) Kor Kalbi → Kor Yelpazesi (`ember_fan`); kahraman bilgi kartı Hat Kıran formatıyla hizalı; **hiçbir kahramanda `start_item` yok** (yalnız başlangıç silahı). |
| 2026-04-14 | **Alacakaranlık Hançeri (`dusk`)** — İkiz hançer menzili; Gece Şişesi koşuda toplanır; evrim `veil_daggers` (Peçe Hançerleri); Gölge Yürüyücü ile Arena zaferi sonrası lonca onayı + altın; oyuncu sahnesi `characters/dusk/dusk.tscn` (animasyon isimleri var, sprite frame’leri sonra). |
| 2026-04-17 | **`dusk` başlangıç yükü** — `start_item` boş; yalnız `dagger`. `night_vial` yalnızca koşuda; kodeks `en` + `character_data` açıklaması güncellendi. |
| 2026-04-22 | **Wiki-arşiv motifleri** — §4.1: Enkaz kapsülü, Rün taşı, buhar/dişli pickup adları; kaynak `docs/vs wiki analizi/`. |

---

*Sonraki sohbetlerde netleşen detaylar (fraksiyonlar, harita isimleri, boss isimleri, rün kuralları) bu yapıya yeni alt başlıklar veya tablolar olarak eklenecektir.*
