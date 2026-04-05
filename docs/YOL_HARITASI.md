# Ironfall — Yol haritası ve yapılacaklar

Bu dosya **ürün / geliştirme planı**dır: öncelikler, tamamlananlar ve ileride eklenecek fikirler burada toplanır.  
*(İngilizce projelerde genelde `ROADMAP.md` adı kullanılır.)*

**Son güncelleme:** Nisan 2026

> Yeni fikir geldikçe uygun başlığın altına madde ekleyin; iş bitince **Tamamlananlar** bölümüne taşıyın veya maddeyi `[x]` ile işaretleyin.

---

## Tamamlananlar (son dönem)

- [x] **Göçebe (nomad)** — Karakter verisi, sahne, harita spawn, kilit: toplam 175 kill → 350 altın satın alma, seçim ekranı konumu.
- [x] **Yelpaze Bıçak (fan_blade)** — Yakın menzil silah, `fan_blade_shard` projectile (Polygon2D), havuz, level-up havuzu.
- [x] **Kor Kalbi (ember_heart)** — Öldürünce can, sandık havuzu, UI isimleri.
- [x] **Kor Yelpazesi (ember_fan)** — Evrim: MAX `fan_blade` + MAX `ember_heart`.
- [x] **Karakter sırası kaydı** — `character_order_v2` ile indeks migrasyonu; P2 seçiminin kayda yazılması.
- [x] **Türbin, Buharlı Zırh, Enerji Hücresi** — Test / doğrulama notu (plan kaynağında tamam işaretli).
- [x] **Cog Shard HUD sayacı** — Oyuncu HUD’da gösterim.

---

## Acil — Yarım kalan veya kısa vadede bitirilecek işler

| Durum | İş |
|--------|-----|
| [ ] | **XP / Gold orb** — Spritesheet ile orb animasyonu (şu anki görsel/placeholder iyileştirmesi). |

*(Buraya “build kırıyor”, “kritik bug” gibi maddeler eklenebilir.)*

---

## Önemli — Sistem temelleri

| Durum | İş |
|--------|-----|
| [x] | **Göçebe + fan_blade + ember_heart + ember_fan** — Entegrasyon (yukarıda tamamlandı). |
| [ ] | **Dil sistemi (localization)** — Örn. `Localization` autoload veya `core/localization.gd`, `locales/tr.json`, `en.json` … uzun vadede çok dil için zemin; UI metinlerinin yavaş yavaş anahtarlara taşınması. |
| [ ] | **Evrim sistemi derinleştirme** — Yeni karakter/silah eklemeden önce: daha fazla kombinasyon, UI açıklamaları, denge, kenar durumlar (kan basitliği). |
| [ ] | **README.md** — GitHub için proje özeti: kurulum (Godot sürümü), çalıştırma, klasör yapısı, lisans. |
| [ ] | **Bağlam belgesi** — `survivors_clone_context.md` (veya eşdeğeri): Ironfall isimlendirmesi, yeni sistemler (Göçebe, shard projectile, evrim), güncel autoload listesi. |

---

## Orta vadeli — İçerik genişletme

| Alan | Hedef / not |
|------|----------------|
| **Karakterler** | Örn. 20 satın alınabilir + 3 gizli = 23 toplam (hedef rakam tartışılabilir). |
| **Silahlar** | Örn. ~20 silah; uzun vadede karakter–silah teması güçlendirme. |
| **Pasif eşyalar** | Çeşitlendirme (ör. growth / greed / revival tipleri); havuz 10 → 20 bandı gibi hedefler. |
| **Düşmanlar** | Harita başına 6–8 çeşit gibi çeşitlendirme hedefi. |
| **Haritalar** | Örn. 5 hikaye + 5 arena haritası (arena modu ile birlikte planlanmalı). |

---

## Uzun vadeli — Oyun derinliği

- [ ] **Lore** — Hikaye metinleri, boss açıklamaları, harita öyküleri.
- [ ] **Görsel tasarım** — Silah efektleri, pasif ikonlar, pickup görselleri (tutarlı stil rehberi).
- [ ] **Arena modu** — Dalga sistemi, zorluk seçimi, ödül yapısı (`map_select` içindeki planla uyumlu).
- [ ] **Koleksiyon / Wiki menüsü** — Silah, eşya, düşman, karakter lexicon (genelde en sona bırakılır).

---

## Steam / yayın hazırlığı

- [ ] Oyun içi **fragman** için kayıt (görsel tasarım olgunlaştıktan sonra).
- [ ] **Steam mağaza** sayfası — fragman, ekran görüntüleri, kısa / uzun açıklama.
- [ ] **Early Access** veya tam çıkış stratejisi ve tarih penceresi.

---

## Fikir havuzu (henüz önceliklendirilmemiş)

*Buraya tek satırlık fikirler eklenebilir; periyodik olarak yukarıdaki bölümlere taşınır.*

- …

---

## Nasıl kullanılır?

1. Yeni iş → uygun öncelik bölümüne madde ekle.  
2. İş bitince → **Tamamlananlar**’a taşı veya tabloda `[x]` yap.  
3. Büyük mimari karar → `docs/GELISTIRICI_REHBERI.md` içinde ilgili bölümü güncelle.
