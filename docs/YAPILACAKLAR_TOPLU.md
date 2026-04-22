# Yapılacaklar — toplu liste

**Amaç:** Sadece **henüz yapılmamış** işler; plan seçerken tek bakış.

**İş akışı:** Bir madde bittiğinde  
1. **Buradan** ilgili satırı **sil** (tik yok — kalan satır = yapılacak).  
2. **Kaynak dosyada** aynı maddeyi **[x]** yap, ✓ koy, metni güncelle veya satırı kaldır (`YOL` öncelik tabloları, matris **Var/Kısmi**, `TASARIM` ✅/❌ vb.).

Kaynaklar: `GELISTIRICI_REHBERI.md`, `YOL_HARITASI.md`, `ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`, `TASARIM.md`, `sesler-muzikler-efektler.md`, `colorrect.md`, `KARAKTER_SINIFLARI_VE_TASARIM.md`, `lore.md`, `README.md`, **`docs/vs wiki analizi/`** (VS/Brotato referans arşivi — özeti `YOL_HARITASI` «Referans» bölümünde).

---

## `docs/vs wiki analizi/` (arşiv → ürün işleri)

Ayrıntılı tablolar ve pseudo-kod **klasördeki dört `.md` dosyasında**; burada yalnızca **henüz kapanmamış** ve arşivle hizalanan işler. Madde bitince hem buradan sil hem `YOL` / `TASARIM` / `lore` içindeki ilgili notu güncelle.

- VS dalga **event**’leri (swarm / encircle / wall) — `spawn_manager` + düşman davranışı (`fixed_direction` vb.); Aşama 1 §7.
- Özel **pickup**’lar (tema buhar/dişli: alan hasarı, kısa donma, XP toplama darbesi) — `effects/` + orb; `lore.md` §4.1 isimlendirme.
- **Harita modifier** sözlüğü (harita başına move/gold/enemy çarpanları) — tek veri kaynağı tasarımı; Aşama 1 §1.
- Brotato tarzı **arena tam paket** — 20 dalga süre tablosu, wave arası mola + upgrade, elite/horde, boss **faz/mutasyon**, zorluk kademeleri, max düşman 80–100; mevcut arena v0 (`run_variant` + `ARENA_RUN_GOAL_SEC`) ile birleştirme.
- **Rün / Buhar run kartı** (Arcana karşılığı) — run başı + boss anları; Aşama 2 §1.
- Run içi **tüccar NPC** — altınla reroll / eşya / silah; Aşama 2 §4.
- **Grimuar** (evrim tarifleri UI) + meta upgrade **VS fiyat formülü** ile `SaveManager` denklik kontrolü; Aşama 2 §6–7.
- Haritada **relic / enkaz kapsülü** (kalıcı özellik veya karakter açılışı); Aşama 2 §3 + Aşama 3 §4.
- Silah **weight/rarity**, **pierce**, atış içi **projectile interval**; pasif tipleri (Growth, Greed, Revival, Duration, Amount); VS tarzı **level bazlı kahraman pasifi**; Aşama 1 §2–5, Aşama 3 §1 §7.
- **Limit Break → Aşım** kartları (tüm slot MAX sonrası level-up seçenekleri); Aşama 3 §2.
- Düşman **kill resistance** / debuff dirençleri; Aşama 1 §7 tablo.

---

## `docs/YOL_HARITASI.md`

- Evrim sistemi derinleştirme (kombinasyonlar, denge, UI, kenar durumlar). *(2026-04-17: `death_laser` / `frost_nova` tarifeleri `weapon_evolution.gd` + Frost Nova yansıtma; kalan: kodeks evrim sekmesi, genel denge.)*
- Bağlam belgesi: `survivors_clone_context.md` (autoload / akış özeti).
- Lore — hikâye, boss, harita metinleri (`TASARIM.md` ile). *(2026-04-18: `lore.md` özeti + Çöküş → ana menü + kodeks `en.json` “World” metinleri.)*
- Arena modu (**tam** paket) — ayrı arena haritası, dalga savunma ritmi, ödül ekonomisi. *(v0: `map_select` + `run_variant` **arena** + ~10 dk; **2026-04-18** `wave_manager` + `spawn_manager` arena tempo cilası.)*
- P2P / co-op destek kahramanları (takım buff mekaniği).
- Sınıfın **denge/oynanışa** bağlanması (`hero_class` → çarpanlar vb.) — seçim kartı: `hero_class` + `codex.character.*.role` (`en.json`) **2026-04-17** ile tasarım tablosuyla hizalı.
- Mevcut kahramanların sınıfa göre stat hizalaması.
- Profil genişlemesi (takma ad, ikon, çerçeve, arka plan).
- Rank sistemi (tasarım açık).
- Görev / idle-benzeri gönderim + ödüller + ölçekleme + sınırlar.
- Onboarding (deneyim seviyesine göre).
- Sağlam rehber kaynağı (UI + metin).
- Koleksiyonda evrim bölümü / sekmesi.
- İleride idle/görev ↔ rehber bağlantısı.
- Genel rehberlik önceliği (UX + metin).
- Acil: `git` `??` asset/sahne dosyalarını anlamlı commit(ler) ile topla.
- **Proje incelemesi (audit) P0 (kalan):** `shop_menu` placeholder beklentisi / oyuncu beklentisi yönetimi.
- **Audit P2–P4 + teknik borç:** `get_nodes_in_group("player")` / `player_bullets`; silah listeleri tek kaynak; `boomerang`/`hunter_axe` isim; `player.gd` bölme; `get_upgrade_text` tablolaştırma; `EnemyRegistry` menzil/profil; ObjectPool; ağır VFX; CI isteğe bağlı; yıldırım tam dikey; silah–tscn doğrulama script’i; silah sahne sprite politikası. *(Ayrıntı tablolar: `YOL_HARITASI` «Proje incelemesi» + «Teknik borç».)*

---

## `docs/GELISTIRICI_REHBERI.md`

- Yeni diller: `ru`, `es`, `pt_BR`, `ja`, `de`, `fr`, `ko`, `pl`, `uk` (tablo + `LANGUAGE_CATALOG` + `locales/<code>.json`).
- Arena (**tam**): ayrı harita / dalga savunma / ödül — v0 sonrası genişletme. *(v0: `map_select` oynanabilir arena; `SaveManager.is_arena_run()` / `ARENA_RUN_GOAL_SEC`.)*
- Yeni silah / kahraman başlangıç silahı: `CharacterSelectHelpers.weapon_display_name` → `codex.weapon.<id>.name`; ayrıca `PlayerLoadoutRegistry`, `upgrade_ui` / `player` havuz dizileri, `collection_data.WEAPON_ENTRIES`, `locales` + `codex_extensions_*`.
- Orb/pickup checklist: co-op P1/P2 toplama davranışı yeni orb türlerinde netleştirilmeli. *(Night Vial / Rezonans px + `get_magnet_bonus` toplamsal sıra **2026-04-18** `player.gd` + `SILAHLAR_ESYALAR_EVO` ile hizalı.)*
- Matris / TASARIM senkronu (erişilebilirlik satırı değişince).

---

## `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`

**Tablo 1 — Kısmi**

- #2 Tek çubuk: P2 ikinci giriş haritası.
- #6 Düşük donanım: resmî benchmark; profil sonrası ince ayar.
- #11 Öğretici / güvenli ilk saniyeler.
- #13 Renk körlüğü: tam UI tema paleti.
- #14 Level-up: büyük sprite ikon seti.
- #16 `ui_scale`: tüm menü/HUD’da zorunlu uygulama.
- #18 Fare ile hareket (klavye remap var).
- #19 Lore: uzun ekran / ayrı hikâye sekmesi.
- **Tamamlandı (2026-04-18) — çoklu dil / run UI:** yüzen uyarılar, level-up loadout (`loadout_weapons` / `loadout_items`), evrim tarifleri (`weapon_evolution` → `ui.evolution_defs.*`); yeni metin rutini **yalnız `en.json`** + `tr()`. *(İleride yeni özellik: aynı rutin + matris §çoklu dil.)*

**Tablo 2**

- #15 Çevre rengi/tempo (şu an Yok — ürün kararı veya uygulama).
- #18 Harita geometrileri; arena kilitli.
- #19 Kozmetik: `shop_menu` placeholder, satın alma yok.
- #20 Net final / hedef süre; ayrı final fazı yok.

---

## `docs/TASARIM.md`

- Meta UI: profil genişlemesi, rank (YOL ile örtüşür). *(Hesap seviye / global XP **2026-04-19** + juiciness **2026-04-16**: tween, `level_up` sesi, Game Over vurgusu — tamam.)*
- Kodeks evrim sekmesi; oyun içi sözlük; idle görev menüsü.
- `shadow` / `laser` / `holy_bullet` vb. **final** sprite / kart sanatı (`TASARIM` tablo). *(2026-04-18: vuruş okunabilirliği — `CombatProjectileFx.spawn_hit_sparks` + silah/lazer/holy mermi cilası.)*
- `fan_blade` / `fan_blade_shard`: final sprite (Polygon2D yerine).
- Evrim silahları ayrı görsel kimlik.
- Pasif eşya ikonları.
- XP orb, gold orb, sandık: spritesheet / ritüel görsel.
- Dünya objeleri: tutarlı stil polish.
- `bullet` / `ice_ball` / `enemy_bullet` / HUD / pause / meta: final pass.
- Harita görselleri; arena ortamı; zamanla değişen ortam rengi; geometri çeşitliliği.
- Ses: level-up / sandık / boss ritüel katmanları.
- Steam: fragman, mağaza görseli, EA stratejisi.

---

## `docs/KARAKTER_SINIFLARI_VE_TASARIM.md`

- Co-op takım arkadaşına buff / destek yetenekleri (kod).
- Taslak sınıf → stat/kimlik hizalaması (`2.3`).
- Controller/Tank havuzunu bilinçli genişletme.

---

## `docs/lore.md`

- Ana saldırı kod adı (`bullet` → evren adı) lore ile hizalama.
- Boss başına kısa “kimdir / ne temsil eder” maddeleri.

---

## `README.md`

- Lisans bölümü (`*(İleride eklenecekse…)*`).
