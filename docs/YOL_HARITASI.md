# Ironfall — Yol haritası ve yapılacaklar

Bu dosya **ürün / geliştirme planı**dır: öncelikler, tamamlananlar ve ileride eklenecek fikirler burada toplanır.  
*(İngilizce projelerde genelde `ROADMAP.md` adı kullanılır.)*

**Son güncelleme:** 2026-04-07 (ürün vizyonu + karakter sınıfı belgesi)

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
| 2026-04-07 | **Performans / refaktör** — `EnemyRegistry` autoload (düşman listesi, `EnemyBase` kayıt); silah/efektlerde `get_nodes_in_group("enemies")` kaldırıldı; `ObjectPool` serbest yuva yığını; `PlayerLoadoutRegistry` (silah/eşya fabrikası); `CharacterData.CHARACTER_SCENE_BY_ID`; `player_ui_helpers`, `character_select_helpers`, `settings_ui_styles`; `MAX_ENEMIES` 1200; `ui.player` / `ui.character_select` locale anahtarları. |
| 2026-04-07 | **Ürün vizyonu** — Co-op destek kahramanları, dört karakter sınıfı, profil/meta, idle-benzeri görevler, rehber/kodeks/sözlük maddeleri `YOL_HARITASI.md` içinde işaretlendi; ayrıntılı sınıf ve kahraman taslağı: `docs/KARAKTER_SINIFLARI_VE_TASARIM.md`. |
| 2026-04-07 | **TASARIM.md — düşman görsel envanteri** — Tüm düşman türleri için `AnimatedSprite2D` + asset yolları doğrulandı; eski “yalnız ColorRect” satırları kaldırıldı; outline / exploder ön uyarısı ayrı hedef olarak not edildi. |
| 2026-04-07 | **Kodeks genişletme** — Sekmeler: düşman, boss, silah, eşya, kahraman, harita; `codex_weapons` / `codex_items` / `codex_maps`; `CollectionData` + `locales/codex_sources` + `merge_codex_extensions.py`. |
| 2026-04-07 | **Bağlılık matrisi Tablo 2 #11 (koleksiyon / bestiary)** — Ana menüden kodeks; grid + filtre + detay; ilk öldürmede `codex_discovered` kaydı; `tr` / `en` / `zh_CN` `codex.*` metinleri. |
| 2026-04-07 | **Erişilebilirlik matrisi #4** — `player_vfx_opacity`: kayıt, Ayarlar + duraklatma kaydırıcısı, oyuncu/silah/projeksiyon/item görsel opaklık çarpanı (`player.get_player_vfx_opacity()`). |
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

## Ürün vizyonu — güven, statü, verimlilik, rehber

Aşağıdaki maddeler **ürün / tasarım** kaynağıdır; kod durumu satır içi notlarla işaretlenir. Karakter sınıfları ve kahraman taslak tablosu: [KARAKTER_SINIFLARI_VE_TASARIM.md](KARAKTER_SINIFLARI_VE_TASARIM.md).

### A. Oyuncunun kendine güveni

| Durum | Madde |
|--------|--------|
| [ ] | **P2P / co-op destek kahramanları** — Takım arkadaşına kısa süreli hasar buff’ı, iyileşme oranı, cooldown / area büyütme vb.; çeşitli support kimlikleri. *(Co-op’ta P2 seçimi var; takım buff mekaniği yok.)* |
| [x] | **Dört sınıf tanımı (metin)** — Controller, Fighter, Mage, Tank açıklamaları `KARAKTER_SINIFLARI_VE_TASARIM.md` içinde. |
| [ ] | **Sınıfın oyuna bağlanması** — `CharacterData` veya eşdeğerinde `class` alanı, UI’da gösterim, denge. |
| [ ] | **Mevcut kahramanların sınıfa göre stat hizalaması** — Taslak atama belgede; sayısal denge beklemede. |
| [x] | **Yeni kahramanlar için sınıf çerçevesi** — Tasarım kuralı olarak belgelendi (`2.1`). |

### B. Oyuncunun “statüsü” hissi

| Durum | Madde |
|--------|--------|
| [x] | **Profil sekmesi (temel)** — Ayarlar → Profil: kalıcı istatistikler + başarı listesi (`ui/settings.gd` `_build_profil_tab`). |
| [ ] | **Profil genişlemesi** — Takma adlar, ikonlar, açılabilir profil arka planı ve çerçeveler. |
| [ ] | **Hesap / seviye sistemi** — Level atladıkça ödüller (yukarıdaki kozmetiklerle bağlantılı olabilir). |
| [ ] | **İleride rank sistemi** — Rekabetçi veya görünür derecelendirme (tasarım açık). |

### C. Verimlilik (idle-benzeri, ana oyunu gölgelemeden)

| Durum | Madde |
|--------|--------|
| [ ] | **Görev / idle-benzeri gönderim** — Oyun tam idle olmayacak; açılmış kahramanlardan bir veya birkaçını gerçek zamanlı süreli görevlere gönderme (ör. 30 dk → 24 saat arası birkaç süre seçeneği). |
| [ ] | **Ödüller** — Dönüşte altın ve/veya XP; hesap seviyesi veya modlara göre kullanılabilir para ayrımı (tasarım kararı). |
| [ ] | **Ölçekleme** — Rank / seviyeye göre görev açılımı; eşzamanlı görev sayısı; gönderilebilen kahraman sayısı; idle menü içi shop / güçlendirme. |
| [ ] | **Hedef** — Az vakitli oyuncular için alternatif kasma yolu; **asıl run deneyiminin önüne geçmeyecek** şekilde sınırlar. |

### D. Direction — rehber ve kodeks

| Durum | Madde |
|--------|--------|
| [ ] | **Her deneyim seviyesine onboarding** — İlk kez açan, türe yabancı veya deneyimli oyuncu için yönlendirme akışı. |
| [ ] | **Sağlam rehber kaynağı** — Tek yerden erişilen, güncellenebilir rehber (UI + metin). |
| [x] | **Koleksiyon / kodeks zemini** — Ana menüden kodeks; düşman, boss, silah, eşya, kahraman, harita sekmeleri (`CollectionData.TAB_ORDER`). |
| [ ] | **Koleksiyonda evrim bölümü** — Evrim silahları run içinde var; kodekste ayrı **Evrim** sekmesi veya alt bölüm yok. |
| [ ] | **İleride idle / görev sistemi** — Rehber veya kodeksten bağlantı (D + C entegrasyonu). |
| [ ] | **Oyun içi sözlük** — Cooldown, area ve benzeri terimlerin açıklaması; koleksiyon içi bölüm veya ayrı sözlük sekmesi. |
| [ ] | **Genel rehberlik önceliği** — Oyuncunun ne topladığını, neyin ne işe yaradığını anlaması (UX + metin). |

---

### Yayın (dış platformlar)

Checklist: `docs/TASARIM.md`.

---

## Fikir havuzu (henüz önceliklendirilmemiş)

- Üst bölüm **Ürün vizyonu — güven, statü, verimlilik, rehber** geniş planı toplar; buraya daha ince fikirler eklenebilir.
- …

---

## Eski “tamamlananlar listesi” (özet)

Ayrıntılı kayıt için yukarıdaki **Tamamlanan sistemler (özet)** ve **Yapılan iş günlüğü** tablolarını kullanın. Burası yalnızca hızlı hatırlatma:

- Göçebe, Yelpaze Bıçak, Kor Kalbi, Kor Yelpazesi evrimi, karakter sırası / kayıt migrasyonu, dokümantasyon ve README tamamlandı (2026-04).
- Üç dilli arayüz (`tr` / `en` / `zh_CN`) ve yerelleştirme altyapısı tamamlandı (2026-04-07); ek diller planlı.
