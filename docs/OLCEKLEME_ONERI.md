# Ölçekleme önerisi — yüzdelik (`%`) vs düz (+N) tasarım

Oyunda çok sayıda **flat** artış (+5 hasar, +60 px magnet, +10 zırh) kullanılıyor. Late-game’de **alan / menzil / pickup yarıçapı** için birkaç piksel (örn. `field_lens` + kartlar → +7–8 px) sahada zor fark edilir; düz **hasar** ise hâlâ okunabilir kalabilir.

Bu dosya bir **tasarım çerçevesi** önerir — kod tek seferde değişmez; kararınıza göre `SILAHLAR_ESYALAR_EVO`, `weapon_base`, `player.get_area_multiplier`, meta vb. ile senkron uygulanır.

---

## İlkeler

| Yaklaşım | Mantıklı olduğu sistemler | Dikkat |
|-----------|---------------------------|--------|
| **Çarpımsal / %** (`×1.08`, `+%8`) | Alan yarıçapı, süre (DoT/sn), pickup/magnet px, bazı CD’ler | Her kaynak **aynı şekilde çarpılırsa** bileşik büyüme (stack) izlenmeli |
| **Toplamsal düz + N** | Taban sabit güç (“+5 düz hasar”), küçük meta adımlar | Tek başına güçlü; çok yükselince % ile birleştirilir |
| **Üst/alt sınır (clamp)** | Oyuncunun ekranı taşırmasını önlemek için alan px, süre saniye | Tasarımcı dostu |

---

## Önerilen hedefler (örnek tablo)

Taban değer **B**, seviye veya kart **rank** **k** olsun.

| Stat | Şu an (örnek davranış) | Öneri A — “görünür alan” | Öneri B — “yumuşak %” |
|------|-------------------------|---------------------------|-------------------------|
| **Alan çarpanı** (`area`) | Bazı yerlerde düz px ekleri | Her rank **+%12–18** taban alana (veya **×(1 + 0.14×k)**) | Son adımı **clamp** (örn. max +%120 toplam) |
| **Süre** (`duration`) | +0.5 sn düz | **+%10 / rank** veya **×1.08^rank** | Boss / CC için üst cap |
| **Magnet / pickup px** | +60×level düz | **+%25 / rank** mevcut taban üzerinden veya **×1.12^rank × taban_px** | Co-op’ta çekim mesafesi cap |
| **Taban silah hasarı** | +2 / level düz | Erken düz + geç **+%5 / level** hibrit | Meta ile çarpım tablosu |
| **Wave ödülü “+hasar”** | +5 düz | **+%4–6** mevcut `bullet_damage` veya **+%5 max can** ile ölçekli | Tek tip ödül okunabilirliği |

### Sayısal mini örnek — alan yarıçapı

- Taban görsel yarıçap **100 px**.
- Üç kaynak her biri **+%15** veriyorsa (çarpımsal):

`100 × 1.15³ ≈ 152 px` → oyunda net görünür.

- Aynı üç kaynak **toplamsal +15 px** ise:

`100 + 45 = 145 px` → yine güçlü; tek kaynak **+7 px** ise kullanıcı fark etmeyebilir → **+% veya daha büyük düz adım** tercih edilir.

---

## Öncelik sırası (ürün kararına göre)

1. **Alan + süre + magnet** → yüzdelik veya exponential küçük adım + clamp  
2. **Koşu içi flat hasar ödülleri** → % veya düz+küçük % hibrit  
3. Temel düşman ölçeği / dalga çarpanı → zaten zamanla büyüyen sistemlerle **aynı dilde** tutun (`spawn_manager`, `enemy_base`)

---

## Repo içi tetikleyiciler (nerede dokunulur)

- **`player.gd`** — `get_magnet_bonus`, `get_area_multiplier`, `get_duration_multiplier`
- **`WeaponBase` / ilgili `weapon_*.gd`** — kart başına artışların tanımı
- **`wave_manager`** — dakikalık ödül hasarı
- **`SILAHLAR_ESYALAR_EVO.md`** — taban sayıların tek kaynak özeti

Bu dokümandaki rakamlar **örnek aralıklar**dır; tek bir “doğru” tablo yoktur — bir koşuda **DPS / süre / alan** hissini hedefleyip sonra sayıları kilitleyin.
