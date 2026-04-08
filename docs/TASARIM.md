# Ironfall — Tasarım envanteri ve takip listesi

Oyunda **görsel, ses sunumu, UI/ikon ve pazarlama** tarafında yapılması veya iyileştirilmesi gereken her şeyin tek adresi.  
Kod mimarisi ve “nasıl eklenir” adımları: `docs/GELISTIRICI_REHBERI.md`.  
Erişilebilirlik/bağlılık maddelerinin **Var / Kısmi / Yok** teknik durumu: `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`.

**Son güncelleme:** 2026-04-07 (karakter görselleri envanteri; run HUD / dalga ödülü yerelleştirmesi)

---

## Meta UI, profil ve rehber (planlı hedefler)

Oyuncunun statü hissi ve yönlendirme için ürün maddeleri `docs/YOL_HARITASI.md` → **Ürün vizyonu** B ve D altında takip edilir. Özet:

| Hedef | Tasarım / UI durumu |
|--------|----------------------|
| Profil genişlemesi (takma ad, ikon, çerçeve, arka plan) | Henüz yok; Ayarlar → Profil şu an istatistik + başarılar. |
| Hesap seviyesi / rank | Henüz yok. |
| Kodeks — evrim sekmesi veya alt bölüm | Run içi evrim var; koleksiyon menüsünde ayrı evrim sekmesi yok. |
| Oyun içi sözlük (cooldown, area, vb.) | Planlı; kodeks içi veya ayrı giriş. |
| Idle-benzeri görev menüsü (C) | Planlı; ana menü akışına entegrasyon tasarım aşamasında. |

Karakter sınıfı ve rol envanteri (oyun dizaynı metni): `docs/KARAKTER_SINIFLARI_VE_TASARIM.md`.

---

## İşaretleme

| Sembol | Anlam |
|--------|--------|
| ✅ | Bu hedefe uygun bir **ilk geçiş** var (asset veya uygulama oyunda kullanılıyor). |
| ❌ | **Eksik**, placeholder, geometrik geçici çözüm veya hedeflenen kaliteye henüz ulaşılmadı. |

*(İnce ayar / “final art pass” gerekiyorsa satır notunda belirtilir.)*

---

## Oyuncu karakterleri (sprite / animasyon)

`core/character_data.gd` içindeki oynanabilir kimlikler.

| Karakter ID | Özel karakter görseli (sahne + asset klasörü) | Not |
|-------------|-----------------------------------------------|-----|
| warrior | ✅ | `assets/warrior assetleri/` |
| mage | ✅ | `assets/büyücü/` |
| vampire | ✅ | `assets/vampir/` |
| hunter | ✅ | `assets/character assets/hunter assets/` |
| stormer | ✅ | `assets/character assets/stormer assets/` |
| frost | ✅ | `assets/character assets/Frost assets/` |
| shadow_walker | ✅ | `assets/character assets/sw assets/` |
| engineer | ✅ | `assets/character assets/engineer assets/` |
| paladin | ✅ | `assets/character assets/paladin assets/` |
| blood_prince | ✅ | `assets/character assets/bp assets/` |
| nomad | ✅ | `assets/character assets/nomad/` — `characters/nomad/nomad.tscn` (idle/walk sprite’lar). |
| death_knight | ✅ | `assets/character assets/dk assets/` |
| chaos | ✅ | `assets/character assets/Kaos assets/` |
| omega | ✅ | `assets/character assets/omega assets/` (`characters/omega/omega.tscn`) |
| sigil_warden | ✅ | `assets/character assets/sigil_warden assets/` — `characters/sigil_warden/sigil_warden.tscn`. |
| grav_binder | ✅ | `assets/character assets/grav_binder/` — `characters/grav_binder/grav_binder.tscn`. |
| ironclad | ✅ | `assets/character assets/ironclad assets/` — `characters/ironclad/ironclad.tscn`. |
| linebreaker | ✅ | `assets/character assets/linebreaker/` — `characters/linebreaker/linebreaker.tscn`. |

**Teknik not:** `characters/warrior/omega.tscn` savaşçı asset’lerini kullanan yedek/legacy sahne; oyun `characters/omega/omega.tscn` ile spawn ediyor — tasarım envanterinde ana Omega ✅ satırı geçerlidir.

---

## Düşmanlar (görsel kimlik)

Her düşman `.tscn` içinde **`AnimatedSprite2D`** + atlas / spritesheet ile **yürüme / idle** animasyonları kullanıyor; tür başına asset klasörü var. `EnemyBase` kodu hâlâ `ColorRect` (`body`) üzerinden boyut, renk flash ve bazı VFX bağlar — sahnelerde genelde hem `ColorRect` hem sprite bulunur; **oyuncunun gördüğü ana siluet sprite’dır**.

| Tür / sahne | Sprite / animasyon seti | Not |
|-------------|-------------------------|-----|
| enemy | ✅ | `assets/warrior assetleri/enemy1.png` |
| fast_enemy | ✅ | `assets/enemy2/spritesheet (13).png` |
| dasher | ✅ | `assets/enemy assets/dasher assets/` |
| ranged_enemy | ✅ | `assets/enemy assets/ranged assets/` |
| tank_enemy | ✅ | `assets/enemy assets/tank assets/` |
| shield_enemy | ✅ | `assets/enemy assets/shield assets/` |
| healer | ✅ | `assets/enemy assets/healer assets/` |
| giant | ✅ | `assets/enemy assets/giant assets/` |
| exploder | ✅ | `assets/enemy assets/exploder assets/` — yakınlıkta **modulate nabız** ön uyarısı (`exploder.gd`); matris Tablo 1 satır 15 **Var** |
| boss | ✅ | `assets/enemy assets/boss assets/` — Reaper renk override kodda (`spawn_manager`) |

**İnce ayar / ürün hedefi:** türler arası stil birliği ve siluet okunurluğu — isteğe bağlı **yüksek kontrast** (`enemy_high_contrast_outline`) kodda; ek sanat polish matris / ürün notlarında takip edilebilir.

---

## Taban silahlar (VFX / projectile / okunabilirlik)

| Silah ID | Oyunda mantık | Final VFX / okunaklı mermi görselleri |
|----------|----------------|----------------------------------------|
| bullet | ✅ | `projectiles/bullet.gd` — `player_vfx_opacity` → ColorRect/Sprite2D `modulate.a` |
| aura | ✅ / ❌ | Alan efekti; yoğunlukta “kendi efektlerim” ayrımı yok |
| chain | ✅ / ❌ | |
| boomerang | ✅ | `projectiles/boomerang.tscn` |
| lightning | ✅ / ❌ | |
| ice_ball | ✅ | `projectiles/ice_ball.tscn` |
| shadow | ✅ / ❌ | |
| laser | ✅ / ❌ | |
| holy_bullet | ✅ / ❌ | Evrim hedefi: `holy_bullet` |
| fan_blade | ❌ | Shard: `Polygon2D` — final bıçak / parça sprite’ı yok |
| toxic_chain, death_laser, blood_boomerang, storm, shadow_storm, frost_nova, ember_fan | ✅ / ❌ | Çoğu mevcut; **pasif ikonları ve level-up kart görselleri** ayrı bölümde |

*(“✅ / ❌” = çalışıyor ancak final sanat / ayarlanabilir opaklık / palet uyumu eksik olabilir.)*

---

## Evrim silahları

`weapon_evolution.gd` ile bağlı sonuçlar (görsel olarak taban silahla aynı VFX hattını paylaşabilir).  
Level-up kartı ve yüzen evrim bildirimi metinleri: `locales/*.json` → `ui.evolution_defs.<id>` ve `ui.upgrade_ui.evolution_pick_title` / `evolution_floating`.

| Evrim sonucu | Ayrı “evrim” görsel kimliği |
|--------------|------------------------------|
| holy_bullet | ❌ |
| toxic_chain | ❌ |
| death_laser | ❌ |
| blood_boomerang | ❌ |
| storm | ❌ |
| shadow_storm | ❌ |
| frost_nova | ❌ |
| ember_fan | ❌ |

---

## Pasif eşyalar (ikon + upgrade kartı)

Level-up ekranı ağırlıklı **metin**; `upgrade_ui` için **büyük net ikon** seti yok (matris satır 14).

| Item ID | Menü/kart ikonu |
|---------|-----------------|
| magnet | ❌ |
| armor | ❌ |
| crit | ❌ |
| explosion | ❌ |
| lifesteal | ❌ |
| poison | ❌ |
| shield | ❌ |
| speed_charm | ❌ |
| blood_pool | ❌ |
| luck_stone | ❌ |
| turbine | ❌ |
| steam_armor | ❌ |
| energy_cell | ❌ |
| ember_heart | ❌ |

`items/item_vampire.gd` — oyunda bağlı değil (yalnızca dosya); ikon ihtiyacı yok.

---

## Pickup, orb ve dünya objeleri

| Öğe | Spritesheet / animasyon / cilalı görsel |
|-----|----------------------------------------|
| XP orb (`effects/xp_orb`) | ❌ | Hedef: spritesheet ile orb animasyonu |
| Gold orb (`effects/gold_orb`) | ❌ | Aynı |
| Sandık (`effects/chest`) | ❌ | Özel açılış animasyonu / ritüel yok |
| Cog shard | ✅ / ❌ | Sahne var; polish açık |
| Time gear, blood oath, shrine, steam bomb, poison trap, freeze barrel, destructible crate | ✅ / ❌ | Çoğu fonksiyonel; tutarlı stil geçişi hedefi |

---

## Projectile ve düşman mermisi

| Sahne | Final sanat |
|-------|----------------|
| bullet.tscn | ✅ / ❌ |
| boomerang.tscn | ✅ / ❌ |
| ice_ball.tscn | ✅ / ❌ |
| fan_blade_shard.tscn | ❌ | Polygon2D geçici |
| enemy_bullet.tscn | ✅ / ❌ |

---

## UI, HUD ve menüler

| Alan | Dosya / konum | İkon / layout / tutarlı tema |
|------|----------------|------------------------------|
| Ana menü | `ui/main_menu` | ✅ / ❌ |
| Karakter seçimi (+ P2) | `ui/character_select*` | Dört rol filtresi (`hero_class`); portre / kilit göstergeleri — iyileştirilebilir |
| Harita / mod | `ui/map_select` | Arena kilit görselleri placeholder |
| Level-up kartları | `ui/upgrade_ui` | ❌ Büyük ikon seti yok |
| HUD (kill, altın, çubuklar) | `player` + CanvasLayer | ✅ / ❌ |
| Oyun sonu | `ui/game_over` | ✅ |
| Duraklat | `ui/pause_menu` | ✅ / ❌ |
| Meta upgrade | `ui/meta_upgrade` | ✅ / ❌ |
| Ayarlar | `ui/settings` | ✅ |
| Arayüz dili (çeviri) | `locales/*.json`, `LocalizationManager`, Ayarlar → Dil | ✅ `tr` / `en` / `zh_CN`; silah-eşya kart metinleri hâlâ kod içi (`player.gd` / `upgrade_ui`) — ileride anahtarlanabilir |
| Hasar sayıları | `effects/damage_number` | ✅ |
| Global font ölçeği (okunabilirlik) | — | ❌ |
| Otomatik pause (odak kaybı) | — | Davranış yok; UI tasarımı gerektirmez ama ürün kararı |

---

## Harita, tileset, ortam

| Konu | Durum |
|------|--------|
| Çoklu hikaye haritası görselleri | ❌ / kısmi — `map_select` çoğunlukla tek aktif hat |
| Arena modu ortam sanatı | ❌ — mod kilitli |
| Zamanla değişen ortam rengi (gerilim) | ❌ |
| Farklı geometriler (labirent hissi) | Kısmi |

---

## Ses tasarımı (sunum)

| Konu | Durum |
|------|--------|
| XP toplama (`AudioManager.play_xp`) | ✅ Pentatonik pitch dizisi var |
| Ardışık toplamada “streak” / sürekli yükselen pitch | ❌ |
| Level-up / sandık / boss için ayırt edici “ritüel” ses katmanları | Kısmi — sandık animasyonu zayıf olduğundan ses de sınırlı |

---

## Erişilebilirlik — görsel ve UI hedefleri (ürün taslağı özeti)

Aşağıdaki maddelerin **kod karşılığı** matriste; burada yalnızca **tasarım çıktısı** beklenenler özetlenir.

- **Görsel karmaşa:** Oyuncu mermi / efekt opaklığı — ✅ `player_vfx_opacity` (Ayarlar / Duraklatma → oynanış); matris Tablo 1 satır 4.
- **Yüksek kontrast düşman:** Ayarlarda açılabilir sarı siluet/çerçeve — ✅ (`enemy_high_contrast_outline`, **Görüntü** sekmesi); matris satır 5.
- **Tuş atamaları:** Ayarlar → **Kontroller** — P1/P2 hareket, duraklat, tam ekran (`InputRemap`); matris satır 18 (fare hareketi hâlâ yok).
- **Renk körlüğü paleti:** Alternatif tema — ❌.
- **Büyük net ikonlar:** Level-up — ❌.
- **Ön uyarı (exploder):** Yakınlıkta modulate nabız — ✅; matris satır 15.
- **Öğretici / ilk 10 sn:** Bilinçli “güvenli” görsel ve düşman yerleşimi — kısmi (ayrı tutorial sahnesi yok).

---

## Bağlılık — sunum ve koleksiyon

- **Sandık heyecanı:** Açılış animasyonu + VFX + ses — kısmi.
- **Koleksiyon / wiki / bestiary menüsü** (grid, keşfedilenler) — ✅ `ui/collection_menu`, `CollectionData` + `codex_discovered` / `codex_weapons` / `codex_items` / `codex_maps` + kahraman kilidi; 6 sekme (düşman, boss, silah, eşya, kahraman, harita), kart + detay.
- **Kozmetik ödüller** (şapka, mermi rengi, texture varyantı) — ❌.
- **Görsel juiciness:** Hit-stop, parçacık, orb — ✅ (genel); yoğun sahnede polish devam edebilir.

---

## Lore ve metin (ürün)

- Menü / ayar / başarım / meta upgrade gibi **UI metinleri** — ✅ `tr()` + `locales` (`tr`, `en`, `zh_CN`); ayrıntı: `GELISTIRICI_REHBERI.md` yerelleştirme bölümü.
- Boss / harita / karakter **lore** metinleri ve sunumu — ❌ (uzun vadeli içerik).
- Gereksiz lore’u gizleyen ayrı “hikaye sekmesi” — ❌.

---

## Steam ve pazarlama

- Oyun içi **fragman** kaydı — ❌.
- **Steam mağaza** sayfası (capsule, ekran görüntüleri, trailer) — ❌.
- Early Access / çıkış stratejisi — ürün kararı (görsel paket `TASARIM.md` ile paralel).

---

## Bu dosyayı ne zaman güncelle?

- Yeni karakter, silah, eşya, düşman veya orb eklenince ilgili satırları ekle.
- Bir görsel veya ikon **tamamlandığında** ✅ yap; placeholder kaldıysa ❌ bırak.
- `docs/YOL_HARITASI.md` artık görsel iş listesi taşımaz; görsel iş burada kapanır.
