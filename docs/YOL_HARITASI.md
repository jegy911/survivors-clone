# Ironfall — Yol haritası ve yapılacaklar

Bu dosya **ürün / geliştirme planı**dır: öncelikler, tamamlananlar ve ileride eklenecek fikirler burada toplanır.  
*(İngilizce projelerde genelde `ROADMAP.md` adı kullanılır.)*

**Son güncelleme:** 2026-04-07

---

## Bu dosyayı ve geliştirici rehberini nasıl güncellemeliyiz?

| Ne zaman? | Ne yap? |
|-------------|---------|
| Bir plan maddesini **bitirdiğinde** | Aşağıdaki **Yapılan iş günlüğü**ne tarih + kısa açıklama ekle; ilgili tabloda `[x]` yap veya maddeyi sil / “İptal” notu düş. |
| Oyuna **yeni tür içerik** eklediğinde (orb, silah, karakter, vb.) | `docs/GELISTIRICI_REHBERI.md` içinde ilgili checklist veya yeni bölümü güncelle (ör. orb için bölüm 8). |
| `docs/TASARIM.md` kapsamındaki bir madde kod + asset olarak **bittiğinde** | O dosyadaki ilgili satırları güncelle. |
| Bir şeyi **koddan kaldırdığında** | Rehberdeki checklist’lerden ve bu dosyadaki maddelerden kaldır veya “kaldırıldı” diye günlüğe yaz. |
| Repo / çalıştırma **değiştiyse** | `README.md` güncelle. |
| **Erişilebilirlik / bağlılık** satırı kodda değişti | `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md` ilgili satırı güncelle. |

> Cursor kullanıyorsan: `.cursor/rules/ironfall-docs.mdc` bu kuralları otomatik hatırlatır.

---

## Tamamlanan sistemler (özet, 2026-04)

Aşağıdakiler kod + dokümantasyon ile **teslim edilmiş** kabul edilir; ayrıntı günlük satırlarında.

| Alan | Ne var? |
|------|---------|
| **Yerelleştirme** | `LocalizationManager` autoload; `LANGUAGE_CATALOG` + `locales/tr.json`, `en.json`, `zh_CN.json`; Ayarlar → Dil; ilk kurulumda kayıt yoksa OS dili; `internationalization/locale/fallback` `en`; `check_locale_parity.py` (`en.json` referansı). |
| **Kayıt / ayarlar** | `SaveManager.settings.locale` ve diğer ayarlar; geçersiz dil kodu düzeltmesi. |
| **İçerik (örnekler)** | Göçebe (nomad), Yelpaze Bıçak + shard, Kor Kalbi + Kor Yelpazesi evrimi; karakter sırası / `character_order_v2` migrasyonu. |
| **Dokümantasyon disiplini** | `GELISTIRICI_REHBERI`, `YOL_HARITASI`, `TASARIM`, erişilebilirlik matrisi, kök `README`, `.cursor/rules/ironfall-docs.mdc`. |

**Not (dil):** Yeni locale dosyası ekleme işi **şimdilik durduruldu**; sıradaki diller `GELISTIRICI_REHBERI.md` içindeki plan tablosunda listelenir.

---

## Yapılan iş günlüğü (tarihli)

| Tarih | Özet |
|--------|------|
| 2026-04-07 | **Evrim sistemi (ilk derinleştirme)** — `WeaponEvolution.is_evolution_ready`, `evolve_weapon` güvenli çıkış; `get_available_evolutions` karıştırma; isteğe bağlı `weight`; `ui.evolution_defs` + level-up / yüzen metin yerelleştirmesi; `upgrade_ui` 4. seçenek (cog shard) ve reroll’da `pick_count` düzeltmesi. |
| 2026-04-07 | **Godot çıktı / derleme** — `LocalizationManager`: geçersiz `TranslationServer.set_fallback_locale` kaldırıldı; `ProjectSettings` + `project.godot` `internationalization/locale/fallback`; `nomad.tscn` tekil sahne UID; `enemy1.png` ile uyumlu `ext_resource` UID; UI/damage_number sahnelerinde hatalı script UID’leri kaldırıldı; 16k+ px geniş texture’lar `process/size_limit=8192` + ilgili `AtlasTexture` bölgeleri ölçeklendi (`warrior` / `nomad` / `player` / `omega`). |
| 2026-04-07 | **Yerelleştirme paketi (tamam)** — `LANGUAGE_CATALOG`, OS ile ilk kurulum dili, `internationalization/locale/fallback`, geçersiz `locale` düzeltmesi, `check_locale_parity.py` (tüm `locales/*.json` ↔ `en.json`); **简体中文** `zh_CN.json` + `lang_*` anahtarları + OS `zh` eşlemesi (繁体 bölgeler şimdilik `en`). |
| 2026-04-06 | **Yerelleştirme (ilk sürüm)** — `LocalizationManager` autoload, `locales/tr.json` + `en.json`, `SaveManager.settings.locale`, Ayarlar → Dil; ana UI metinleri `tr()` ile anahtarlandı. |
| 2026-04-04 | **Dokümantasyon** — `docs/TASARIM.md` eklendi; sanat/yayın envanteri oraya taşındı; erişilebilirlik matrisi yalnızca kod durumuna indirgendi. |
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

**Kod durumu matrisi:** [ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md](ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md)  
**`TASARIM.md`:** [TASARIM.md](TASARIM.md)

Teknik ayar anahtarları: `GELISTIRICI_REHBERI.md` §15.

---

## Öncelik tabloları (plan)

### Acil — Yarım kalan veya kısa vadede bitirilecek işler

*(Boş: acil işler buraya eklenir.)*

---

### Önemli — Sistem temelleri

| Durum | İş |
|--------|-----|
| [x] | **Dil sistemi (localization)** — `LocalizationManager`, `LANGUAGE_CATALOG`, `tr` / `en` / `zh_CN`, Ayarlar → Dil, OS ilk kurulum, parity script; *yeni diller sonraya bırakıldı.* |
| [ ] | **Evrim sistemi derinleştirme** — Kombinasyonlar, denge, UI, kenar durumlar. *(2026-04: doğrulama, locale, cog 4. slot, reroll/pick_count, havuz sırası; yeni evrim/denge için devam.)* |
| [x] | **README.md** — GitHub için özet, Godot ile çalıştırma, `docs/` linkleri. |
| [ ] | **Bağlam belgesi** — `survivors_clone_context.md` (veya eşdeğeri): Ironfall, yeni sistemler, autoload özeti. |

---

### Orta vadeli — İçerik genişletme

| Alan | Hedef / not |
|------|----------------|
| **Yerelleştirme (yeni diller)** | `ru`, `es`, `pt_BR`, `ja`, `de`, `fr`, `ko`, `pl`, `uk` — tablo ve `code`/`steam` eşlemesi: `GELISTIRICI_REHBERI.md` § yerelleştirme. |
| **Karakterler** | Örn. 20 satın alınabilir + 3 gizli = 23 toplam (hedef rakam tartışılabilir). |
| **Silahlar** | Örn. ~20 silah; karakter–silah teması. |
| **Pasif eşyalar** | Çeşitlendirme; havuz büyütme hedefleri. |
| **Düşmanlar** | Harita başına 6–8 çeşit gibi hedef. |
| **Haritalar** | Örn. 5 hikaye + 5 arena (arena modu ile birlikte). |

Paralel envanter: `docs/TASARIM.md`.

---

### Uzun vadeli — Oyun derinliği

- [ ] **Lore** — Hikaye, boss, harita metinleri (metin/envanter: `docs/TASARIM.md`).
- [ ] **Arena modu** — Dalga, zorluk, ödül (`map_select` ile uyumlu).

---

### Yayın (dış platformlar)

Checklist: `docs/TASARIM.md`.

---

## Fikir havuzu (henüz önceliklendirilmemiş)

- …

---

## Eski “tamamlananlar listesi” (özet)

Ayrıntılı kayıt için yukarıdaki **Tamamlanan sistemler (özet)** ve **Yapılan iş günlüğü** tablolarını kullanın. Burası yalnızca hızlı hatırlatma:

- Göçebe, Yelpaze Bıçak, Kor Kalbi, Kor Yelpazesi evrimi, karakter sırası / kayıt migrasyonu, dokümantasyon ve README tamamlandı (2026-04).
- Üç dilli arayüz (`tr` / `en` / `zh_CN`) ve yerelleştirme altyapısı tamamlandı (2026-04-07); ek diller planlı.
