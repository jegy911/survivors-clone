# Ironfall — Yol haritası ve yapılacaklar

Bu dosya **ürün / geliştirme planı**dır: öncelikler, tamamlananlar ve ileride eklenecek fikirler burada toplanır.  
*(İngilizce projelerde genelde `ROADMAP.md` adı kullanılır.)*

**Son güncelleme:** 2026-04-06

---

## Bu dosyayı ve geliştirici rehberini nasıl güncellemeliyiz?

| Ne zaman? | Ne yap? |
|-------------|---------|
| Bir plan maddesini **bitirdiğinde** | Aşağıdaki **Yapılan iş günlüğü**ne tarih + kısa açıklama ekle; ilgili tabloda `[x]` yap veya maddeyi sil / “İptal” notu düş. |
| Oyuna **yeni tür içerik** eklediğinde (orb, silah, karakter, vb.) | `docs/GELISTIRICI_REHBERI.md` içinde ilgili checklist veya yeni bölümü güncelle (ör. orb için bölüm 8). |
| Bir şeyi **koddan kaldırdığında** | Rehberdeki checklist’lerden ve bu dosyadaki maddelerden kaldır veya “kaldırıldı” diye günlüğe yaz. |
| Repo / çalıştırma **değiştiyse** | `README.md` güncelle. |
| **Erişilebilirlik / bağlılık** satırı kodda değişti | `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md` ilgili satırı güncelle. |

> Cursor kullanıyorsan: `.cursor/rules/ironfall-docs.mdc` bu kuralları otomatik hatırlatır.

---

## Yapılan iş günlüğü (tarihli)

| Tarih | Özet |
|--------|------|
| 2026-04 | **Göçebe (nomad)** — Karakter, sahne, spawn, kilit (175 toplam kill → 350 altın), seçim ekranı sırası, indeks migrasyonu (`character_order_v2`). |
| 2026-04 | **Yelpaze Bıçak + shard** — `fan_blade`, `fan_blade_shard` (Polygon2D, ObjectPool), yakın menzil. |
| 2026-04 | **Kor Kalbi + Kor Yelpazesi** — `ember_heart`, evrim `ember_fan` (MAX fan_blade + MAX ember_heart). |
| 2026-04 | **Dokümantasyon** — `docs/GELISTIRICI_REHBERI.md`, `docs/YOL_HARITASI.md`, kök `README.md`, Cursor kuralı `ironfall-docs.mdc`. |
| 2026-04-05 | **Erişilebilirlik + devamlılık checklist** — Özet bölüm eklendi; kodla doğrulandı. |
| 2026-04-06 | **20+20 tam matris** — `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md` (CSV taslak sütunları + Var/Kısmi/Yok + repo notu). |
| (not) | Türbin, Buharlı Zırh, Enerji Hücresi testi; Cog Shard HUD — plan kaynağında tamam notu. |

*Yeni satır en üste veya en alta eklenebilir; takım tercihine göre “en yeni üstte” tutulması okumayı kolaylaştırır.*

---

## Erişilebilirlik ve devamlılık

**Tam matris (20 erişilebilirlik + 20 bağlılık maddesi, önem / geliştirilebilirlik, Var–Kısmi–Yok, kod yolu):**  
[ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md](ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md)

Özet: Matris, ürün taslağını satır satır repoya bağlar; yeni özellik yapılınca ilgili satır orada güncellenir. Teknik ayar anahtarları: `GELISTIRICI_REHBERI.md` §15.

---

## Öncelik tabloları (plan)

### Acil — Yarım kalan veya kısa vadede bitirilecek işler

| Durum | İş |
|--------|-----|
| [ ] | **XP / Gold orb** — Spritesheet ile orb animasyonu (görsel iyileştirme). |

---

### Önemli — Sistem temelleri

| Durum | İş |
|--------|-----|
| [ ] | **Dil sistemi (localization)** — Örn. autoload + `locales/tr.json`, `en.json`; UI metinlerinin anahtarlara taşınması. |
| [ ] | **Evrim sistemi derinleştirme** — Kombinasyonlar, denge, UI, kenar durumlar. |
| [x] | **README.md** — GitHub için özet, Godot ile çalıştırma, `docs/` linkleri. |
| [ ] | **Bağlam belgesi** — `survivors_clone_context.md` (veya eşdeğeri): Ironfall, yeni sistemler, autoload özeti. |

---

### Orta vadeli — İçerik genişletme

| Alan | Hedef / not |
|------|----------------|
| **Karakterler** | Örn. 20 satın alınabilir + 3 gizli = 23 toplam (hedef rakam tartışılabilir). |
| **Silahlar** | Örn. ~20 silah; karakter–silah teması. |
| **Pasif eşyalar** | Çeşitlendirme; havuz büyütme hedefleri. |
| **Düşmanlar** | Harita başına 6–8 çeşit gibi hedef. |
| **Haritalar** | Örn. 5 hikaye + 5 arena (arena modu ile birlikte). |

---

### Uzun vadeli — Oyun derinliği

- [ ] **Lore** — Hikaye, boss, harita metinleri.
- [ ] **Görsel tasarım** — Silah efektleri, pasif ikonlar, pickup görselleri.
- [ ] **Arena modu** — Dalga, zorluk, ödül (`map_select` ile uyumlu).
- [ ] **Koleksiyon / Wiki menüsü** — En sona bırakılabilir.

---

### Steam / yayın hazırlığı

- [ ] Oyun içi fragman kaydı.
- [ ] Steam mağaza sayfası.
- [ ] Early Access veya tam çıkış stratejisi.

---

## Fikir havuzu (henüz önceliklendirilmemiş)

- …

---

## Eski “tamamlananlar listesi” (özet)

Ayrıntılı kayıt için yukarıdaki **Yapılan iş günlüğü** tablosunu kullanın. Burası yalnızca hızlı hatırlatma:

- Göçebe, Yelpaze Bıçak, Kor Kalbi, Kor Yelpazesi evrimi, karakter sırası / kayıt migrasyonu, dokümantasyon ve README tamamlandı (2026-04).
