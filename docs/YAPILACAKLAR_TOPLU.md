# Yapılacaklar — toplu liste

Kaynak: `GELISTIRICI_REHBERI.md`, `YOL_HARITASI.md`, `ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`, `TASARIM.md`, `KARAKTER_SINIFLARI_VE_TASARIM.md`, `lore.md`, `README.md`.  
Madde bittiğinde **kaynak dosyada** güncelle; bu liste senkron tutulmayabilir — ihtiyaçta yeniden üret veya elle işaretle.

---

## `docs/YOL_HARITASI.md`

- [ ] Evrim sistemi derinleştirme (kombinasyonlar, denge, UI, kenar durumlar).
- [ ] Bağlam belgesi: `survivors_clone_context.md` (autoload / akış özeti).
- [ ] Lore — hikâye, boss, harita metinleri (`TASARIM.md` ile).
- [ ] Arena modu — dalga, zorluk, ödül (`map_select` uyumu).
- [ ] P2P / co-op destek kahramanları (takım buff mekaniği).
- [ ] Sınıfın oyuna bağlanması (`CharacterData` / UI / denge).
- [ ] Mevcut kahramanların sınıfa göre stat hizalaması.
- [ ] Profil genişlemesi (takma ad, ikon, çerçeve, arka plan).
- [ ] Hesap / seviye sistemi.
- [ ] Rank sistemi (tasarım açık).
- [ ] Görev / idle-benzeri gönderim + ödüller + ölçekleme + sınırlar.
- [ ] Onboarding (deneyim seviyesine göre).
- [ ] Sağlam rehber kaynağı (UI + metin).
- [ ] Koleksiyonda evrim bölümü / sekmesi.
- [ ] İleride idle/görev ↔ rehber bağlantısı.
- [ ] Oyun içi sözlük (cooldown, area, …).
- [ ] Genel rehberlik önceliği (UX + metin).
- [ ] Acil: `git` `??` asset/sahne dosyalarını anlamlı commit(ler) ile topla.
- [ ] Audit P0: run içi sabit metin → locale; karakter seçimi kalan TR buton/ipucu; `print` temizliği; mağaza placeholder beklentisi.
- [ ] Audit P1: öğretici; co-op ikinci giriş; evrim+kodeks; `hero_class`→oyun; `survivors_clone_context`.
- [ ] Audit P2: `get_nodes_in_group("player")` yoğunluğu; `player_bullets`; silah listeleri drift; `boomerang`/`hunter_axe` isim; 600 px tek sabit; `player.gd` bölme; `get_upgrade_text` tablolaştırma.
- [ ] Audit P3: `EnemyRegistry` menzil/profil; ObjectPool boyutları; ağır VFX tavanı.
- [ ] Audit P4: CI (parity + sahne kontrolü isteğe bağlı).
- [ ] Teknik borç tablosu: 600 px birleştirme; silah sahne şablonu politikası; yıldırım tam dikey; ObjectPool notu; menzil ızgarası; weapon–tscn doğrulama script’i.

---

## `docs/GELISTIRICI_REHBERI.md`

- [ ] Yeni diller: `ru`, `es`, `pt_BR`, `ja`, `de`, `fr`, `ko`, `pl`, `uk` (tablo + `LANGUAGE_CATALOG` + `locales/<code>.json`).
- [ ] Arena: `map_select` kilitli; dalga mantığı YOL planı ile genişletilecek.
- [ ] Yeni silah: `character_select` `_get_weapon_name` / `_get_item_name` uyumu.
- [ ] Orb/pickup checklist: co-op P1/P2 toplama davranışı yeni orb türlerinde netleştirilmeli.
- [ ] Matris / TASARIM senkronu (erişilebilirlik satırı değişince).

---

## `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`

**Tablo 1 — Kısmi (tamamlanacak / iyileştirilecek)**

- [ ] #2 Tek çubuk: P2 ikinci giriş haritası.
- [ ] #6 Düşük donanım: resmî benchmark yok; profil sonrası ince ayar.
- [ ] #11 Öğretici / güvenli ilk saniyeler: tutorial sahnesi veya yumuşak açılış.
- [ ] #13 Renk körlüğü: tam UI tema paleti yok.
- [ ] #14 Level-up: büyük sprite ikon seti yok.
- [ ] #16 `ui_scale`: tüm menü/HUD’da zorunlu uygulama yok.
- [ ] #18 Fare ile hareket yok; klavye remap var.
- [ ] #19 Lore: uzun ekran / ayrı hikâye sekmesi yok.
- [ ] Çoklu dil çapraz: yüzen metinler, `wave_manager` Reaper/kuşatma/bağışıklık vb. sabit string → `locales`.

**Tablo 2**

- [ ] #15 Çevre rengi/tempo — **Yok**, eklenecek veya madde kapatılacak şekilde tasarlanacak.
- [ ] #18 Harita geometrileri — **Kısmi**; arena kilitli.
- [ ] #19 Kozmetik — **Kısmi**; `shop_menu` placeholder, satın alma yok.
- [ ] #20 Net final / hedef süre — **Kısmi**; ayrı final fazı yok.

---

## `docs/TASARIM.md`

- [ ] Meta UI: profil genişlemesi, hesap/rank (YOL B ile örtüşür).
- [ ] Kodeks evrim sekmesi; oyun içi sözlük; idle görev menüsü (YOL ile örtüşür).
- [ ] `shadow` / `laser` / `holy_bullet` ve benzeri satırlarda final VFX/okunabilirlik (`✅/❌` satırları).
- [ ] `fan_blade` / `fan_blade_shard`: final sprite (şu an Polygon2D).
- [ ] Evrim silahları ayrı görsel kimlik (`holy_bullet` … `ember_fan` ❌ satırları).
- [ ] Pasif eşya ikonları (tablo ❌).
- [ ] XP orb, gold orb, sandık: spritesheet / ritüel görsel.
- [ ] Dünya objeleri: tutarlı stil polish (`time_gear`, …).
- [ ] `bullet` / `ice_ball` / `enemy_bullet` / HUD / pause / meta: `✅/❌` notlu satırların final pass’i.
- [ ] `upgrade_ui` / `player` / `upgrade_ui` kart metinleri kod içi → locale (TASARIM notu).
- [ ] Harita: çoklu hikâye görseli; arena ortam sanatı; zamanla değişen ortam rengi; geometri çeşitliliği.
- [ ] Ses: level-up / sandık / boss ayırt edici ritüel katmanları (kısmi).
- [ ] Lore sunumu menüde (❌).
- [ ] Steam: fragman, mağaza görseli, EA stratejisi (❌).

---

## `docs/KARAKTER_SINIFLARI_VE_TASARIM.md`

- [ ] Co-op takım arkadaşına buff / destek yetenekleri (kod yok).
- [ ] Taslak sınıf ataması → stat/kimlik hizalaması (`2.3` tamamlanmadı).
- [ ] Controller/Tank havuzunu bilinçli genişletme (not).

---

## `docs/lore.md`

- [ ] Ana saldırı kimliği kod adı (`bullet` → evrene uygun nihai isim) lore ile hizalama.
- [ ] Boss başına “kimdir, neyi temsil eder” maddeleri ekleme.

---

## `README.md`

- [ ] Lisans bölümü (`*(İleride eklenecekse…)*`).

---

## Hızlı özet (sayı)

| Kaynak | Yaklaşık madde sayısı (checkbox) |
|--------|----------------------------------|
| YOL_HARITASI | ~35 |
| GELISTIRICI_REHBERI | ~5 |
| ERISILEBILIRLIK | ~15 |
| TASARIM | ~25 |
| KARAKTER_SINIFLARI | ~3 |
| lore | ~2 |
| README | ~1 |
