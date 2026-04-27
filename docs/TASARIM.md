# Ironfall — Tasarım envanteri ve takip listesi

Oyunda **görsel, ses sunumu, UI/ikon ve pazarlama** tarafında yapılması veya iyileştirilmesi gereken her şeyin tek adresi.  
Kod mimarisi ve “nasıl eklenir” adımları: `docs/GELISTIRICI_REHBERI.md`.  
Erişilebilirlik/bağlılık maddelerinin **Var / Kısmi / Yok** teknik durumu: `docs/ERISILEBILIRLIK_VE_BAGLILIK_MATRISI.md`.  
**Ses / müzik / SFX dosya ve tetik envanteri** (ayrıntılı): `docs/sesler-muzikler-efektler.md`.

**Son güncelleme:** 2026-04-25 (+ `assets/inbox` PNG dağıtımı: ikonlar, pickup sprite’ları, ember/frost/shadow/veil saha görselleri; buhar/zaman/buz fıçısı; patlama pasif VFX)

---

## Meta UI, profil ve rehber (planlı hedefler)

Oyuncunun statü hissi ve yönlendirme için ürün maddeleri `docs/YOL_HARITASI.md` → **Ürün vizyonu** B ve D altında takip edilir. Özet:

| Hedef | Tasarım / UI durumu |
|--------|----------------------|
| Profil genişlemesi (takma ad, kozmetik ikon, çerçeve, arka plan) | Henüz yok. |
| Hesap seviyesi / meta XP (Ayarlar → Profil) | **Var** — seviye, ilerleme, toplam bankalı XP; istatistik + başarılar aynı ekranda. |
| Rekabet / görünen **rank** veya lider tablosu | **Henüz yok** |
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
| **/** | Bu **sütun ilgili değil** veya içerik **henüz atanmadı** (ör. pasif eşyalarda dünya içi *projectile* hattı yok). |

*(İnce ayar / “final art pass” gerekiyorsa satır notunda belirtilir.)*

### Silah ve pasif eşya — satır şablonu (mantık / ikon / projectile / tasarım)

Koleksiyon ve level-up tarafında tutarlı takip için tablolarda beş sütun kullanılır:

| Sütun | Kapsam |
|--------|--------|
| **Mantık** | Oyun içi davranış: ilgili `weapon_*.gd` / `item` etkisi, havuz, istatistik bağları — çalışır durum. |
| **İkon** | Menü / level-up kartı / kodeks: `assets/ui/upgrade_icons/` (`weapons/`, `items/`, `evolutions/`) veya `codex_icons` / `codex_art` (bkz. `upgrade_icon_catalog.gd`, `codex_icon_catalog.gd`). |
| **Projectile** | Dünya içi görünür mermi veya doğrudan eşdeğeri: `projectiles/*.tscn`, `assets/projectiles/`, silaha özel VFX hattı (ör. zincir segmenti, yıldırım cismi). **Pasif eşyalar** için bu sütunda yalnızca **`/`** (şu an projectile hattı yok / tanımsız). |
| **Tasarım** | Final sanat, palet, okunabilirlik ve “ürün kalitesi” polish’i (ikon ve sahadaki sprite’ın birlikte oturması). |

Özet: eşya satırlarında **Projectile = /** sabit; silahlarda gerçekten saha objesi yoksa (yalnızca oyuncuya bağlı alan vb.) hücrede kısa not veya yine **`/`** kullanılabilir — o durumda **Mantık** veya **Tasarım** notunda neyin “mermi yerine” geçtiği yazılır.

---

## Oyuncu karakterleri (sprite / animasyon)

`core/character_data.gd` içindeki oynanabilir kimlikler.

| Karakter ID | Özel karakter görseli (sahne + asset klasörü) | Not |
|-------------|-----------------------------------------------|-----|
| warrior | ✅ | `assets/character assets/warrior assets/` |
| mage | ✅ | `assets/büyücü/` |
| vampire | ✅ | `assets/vampir/` |
| hunter | ✅ | `assets/character assets/hunter assets/` |
| stormer | ✅ | `assets/character assets/stormer assets/` |
| frost | ✅ | `assets/character assets/Frost assets/` |
| shadow_walker | ✅ | `assets/character assets/sw assets/` — `characters/shadow_walker/shadow_walker.tscn` |
| dusk_striker | ✅ | `assets/character assets/dusk assets/` — `characters/dusk/dusk.tscn` (`CharacterData` `id` = `dusk_striker`, klasör `dusk/`) |
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
| arcanist | ✅ | `assets/character assets/arcanist assets/` — `characters/arcanist/arcanist.tscn` |

**Teknik not:** `characters/warrior/omega.tscn` savaşçı asset’lerini kullanan yedek/legacy sahne; oyun `characters/omega/omega.tscn` ile spawn ediyor — tasarım envanterinde ana Omega ✅ satırı geçerlidir.

---

## Düşmanlar (görsel kimlik)

Her düşman `.tscn` içinde **`AnimatedSprite2D`** + atlas / spritesheet ile **yürüme / idle** animasyonları kullanıyor; tür başına asset klasörü var. `EnemyBase` kodu hâlâ `ColorRect` (`body`) üzerinden boyut, renk flash ve bazı VFX bağlar — sahnelerde genelde hem `ColorRect` hem sprite bulunur; **oyuncunun gördüğü ana siluet sprite’dır**.

| Tür / sahne | Sprite / animasyon seti | Not |
|-------------|-------------------------|-----|
| enemy | ✅ | `assets/enemy assets/enemy1 assets/enemy1.png` |
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

## Taban silahlar (mantık / ikon / projectile / tasarım)

| Silah ID | Mantık | İkon | Projectile | Tasarım |
|----------|--------|------|------------|---------|
| bullet | ✅ `projectiles/bullet.gd`; `player_vfx_opacity` → ColorRect/Sprite2D `modulate.a` | ✅ `upgrade_icons/weapons/bullet.png` | ✅ Mermi gövdesi + isabet hattı | ✅ / kısmi — opaklık / palet ince ayarı açık olabilir |
| dagger | ✅ `weapon_dagger.gd` + ikiz atış | ✅ `upgrade_icons/weapons/dagger.png` | ✅ `projectiles/dagger.tscn` (`bullet.gd`) | ✅ — ince sprite ölçeği |
| aura | ✅ `weapon_aura.gd` → `AuraWeaponRing` | ✅ `upgrade_icons/weapons/aura.png` | / — klasik `.tscn` mermi yok; saha etkisi oyuncuya bağlı halka | ✅ `assets/projectiles/aura/aura.png` |
| chain | ✅ `weapon_chain.gd` + `CombatProjectileFx.spawn_chain_segment` | ✅ `upgrade_icons/weapons/chain.png` | ✅ Segment Sprite2D + `assets/projectiles/chain/chain.png` | ✅ |
| boomerang | ✅ Oyun içi ID `boomerang` | ✅ `upgrade_icons/weapons/boomerang.png` | ✅ `projectiles/hunter_axe.tscn` + `assets/projectiles/axe/boomerang.png` | ✅ |
| lightning | ✅ Ana hat + storm/toxic varyantları | ✅ `upgrade_icons/weapons/lightning.png` | ✅ `projectiles/lightning_bolt.tscn` + `lightning_hit_fx` | ✅ / kısmi |
| ice_ball | ✅ | ✅ `upgrade_icons/weapons/ice_ball.png` | ✅ `projectiles/ice_ball.tscn` | ✅ / kısmi |
| shadow | ✅ Orbit isabet + sparks | ✅ `upgrade_icons/weapons/shadow.png` | ✅ / kısmi — `spawn_hit_sparks` odaklı | Kısmi — final mermi sprite ayrı |
| laser | ✅ Işın katmanları | ✅ `upgrade_icons/weapons/laser.png` | ✅ / kısmi — ışın geometrisi kodda | Kısmi — final sanat |
| holy_bullet | ✅ `bullet.gd` + `armor_piercing` kıvılcımı | ✅ `upgrade_icons/evolutions/holy_bullet.png` (`try_weapon_with_evolution_fallback` ile aynı ada) | ✅ Mermi hattı | Kısmi |
| fan_blade | ✅ | ✅ `upgrade_icons/weapons/fan_blade.png` | ✅ `assets/projectiles/fan_blade/shard.png` + sahne `Sprite2D` / `CollisionShape2D` (kullanıcı); menzil = `fire_range×area`, hareket taşması yok | Spawn `get_directional_attack_spawn`; nomad ölçekleriyle uyumlu |
| arc_pulse | ✅ | ✅ `upgrade_icons/weapons/arc_pulse.png` | ✅ / kısmi — silaha özel projeksiyon hattı | Kısmi |
| hex_sigil, shield_ram, binding_circle, citadel_flail, fortress_ram | ✅ (silah başına sahne/kod) | ✅ ilgili `weapons/*.png` mevcutsa | Silaha göre `projectiles/` / sahne sprite | Kısmi olabilir |
| gravity_anchor, void_lens | ✅ `weapon_*.gd` + `center_cataclysm_helper.gd` | gravity ✓ weapons; void_lens ✓ `evolutions/void_lens.png` | Runtime tekillik PNG (`assets/projectiles/...`) | ✅ oyun-içi tekillik |
| bastion_flail | ✅ `weapon_bastion_flail.gd` + sahne | ✅ `weapons/bastion_flail.png` | `OrbitPivot` + gürz `Sprite2D` + `FlailHitbox` | ✅ |
| veil_daggers, toxic_chain, death_laser, blood_boomerang, storm, shadow_storm, frost_nova, ember_fan, arc_surge | ✅ evrim / türev hatlar | Evrim PNG’leri (`evolutions/*.png`) kısmi set | Çoğunlukla taban silah projectile’ını paylaşır veya ek VFX | Çoğunlukla kısmi — kart / saha ayrımı `upgrade_icons` + bu tablo |

*(“✅ / kısmi” = çalışıyor; final sanat veya tek tip ikon seti eksik olabilir.)*

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
| veil_daggers | ❌ |

---

## Pasif eşyalar (mantık / ikon / projectile / tasarım)

Level-up ekranı: **Megabonk tarzı üç sütun** (envanter + dikey kartlar + istatistik), emoji/Unicode yedek; isteğe bağlı PNG: `assets/ui/upgrade_icons/items/` + `core/upgrade_icon_catalog.gd` (matris satır 14 — kısmi). Yerleşim: `ui/upgrade_ui.tscn` içindeki **`EditorRoot`** düğümü editörden taşınabilir; betik bu ağaca bağlanır veya yoksa kodla kabuk üretir.

**Projectile sütunu:** pasif eşyalar için hepsinde **`/`** (dünya içi mermi hattı yok; etkiler istatistik / proc / aura kodunda).

| Item ID | Mantık | İkon | Projectile | Tasarım |
|---------|---------|------|------------|---------|
| magnet | ✅ | ❌ | / | ❌ |
| armor | ✅ | ❌ | / | ❌ |
| crit | ✅ | ❌ | / | ❌ |
| explosion | ✅ | ❌ | / | ❌ |
| lifesteal | ✅ | ❌ | / | ❌ |
| poison | ✅ | ❌ | / | ❌ |
| shield | ✅ | ❌ | / | ❌ |
| speed_charm | ✅ | ❌ | / | Kısmi (`speed_charm_effect.png` ayak-altı boost+hareket) |
| blood_pool | ✅ | ❌ | / | ❌ |
| luck_stone | ✅ | ❌ | / | ❌ |
| turbine | ✅ | ❌ | / | ❌ |
| steam_armor | ✅ | ❌ | / | ❌ |
| energy_cell | ✅ | ❌ | / | ❌ |
| ember_heart | ✅ | ❌ | / | ❌ |
| glyph_charm | ✅ | ❌ | / | ❌ |
| resonance_stone | ✅ | ❌ | / | ❌ |
| rampart_plate | ✅ | ❌ | / | ❌ |
| iron_bulwark | ✅ | ❌ | / | ❌ |
| night_vial | ✅ | ❌ | / | ❌ |
| field_lens | ✅ | ✅ `upgrade_icons/items/field_lens.png` | / | Kısmi |

`items/item_vampire.gd` — oyunda bağlı değil (yalnızca dosya); envanter satırı yok.

---

## Pickup, orb ve dünya objeleri

Kod, düşen ve spawn edilen tüm cisimlerin listesi. **✅** doku/anim var veya oyunu taşıyor, **Kısmi** = ColorRect/emoji/placeholder, **❌** = ayrı sanat / ritüel / tutarlı tema henüz yok.

### XP orbları — **üç ayrı XP türü** (tasarım hedefi)

Bunlar ayrı tscn değil; `effects/xp_orb.tscn` + `enemy_base._spawn_xp_orb_drop()` ağırlıklarla aynı sahneyi **3 çarpan + hedef renk** ile doldurur (`XP_VALUE=5` taban):

| Üretim (olasılık) | XP çarpanı | Renk (kod) | Amaç: `assets/effects/…` ayrı tasarım? |
|-------------------|------------|------------|----------------------------------------|
| Standart (~%90) | 1× | mavi `#4A90E2` | Ayrı **Tür 1** orb sprite/anim; erişilebilirlik: `filter_accessibility_orb_color` |
| Zengin (~%8) | 3× | yeşil `#2ECC71` | Ayrı **Tür 2** (yüksek değer hissi) |
| Nadir (~%2) | 8× | kırmızı `#E74C3C` | Ayrı **Tür 3** (ödül hissi) |

**Teknik (şu an):** `effects/xp_orb.gd` tier (`0|1|2`) ile `Sprite2D` dokusunu seçer: **`xp.png`** (1×), **`green_xp.png`** (3×), **`red_xp.png`** (8×). Erişilebilirlik «friendly» paletinde yalnızca 3× / 8× için `Sprite2D.modulate` ← `filter_accessibility_orb_color` (yeşil / kırmızı semantic). Gizli `ColorRect` artık tür için kullanılmıyor. Boss tek küre: `init(XP_VALUE, pos, 0)` → standart doku.

| Kısım | Konum / içerik | Görsel / efekt (şu an) | Tasarım bacağı |
|--------|----------------|-------------------------|----------------|
| Altın küre | `effects/gold_orb` | `Sprite2D` + `assets/effects/gold.png` | Ayrı animasyon, parıltı, bırak anı: **Kısmi / ❌** |
| Sandık | `effects/chest.tscn` | Yalnızca `ColorRect` + açılış `tween` (kod) | Kutu modu, ritüel, ikon, tier: **❌** |

**Ölümden düşen (enemy_base) — tscn/üretim** | Açıklama | Görsel durum
|---|---|---
| Düşen XP küresi | yukarıdaki 3 tür | Üç ayrı tasarım (yukarı) |
| Altın küresi | `gold_orb` | yukarı |
| Sandık | `chest` | yukarı |
| Blood Oath | `blood_oath.tscn` — sadece `ColorRect` | **❌** ayrı sanat |
| Cog shard | `cog_shard.tscn` — `Sprite2D` + `assets/effects/cog.png` | **Kısmi** (doku var; parıltı/bırak VFX açık) |
| Steam bomb / Time gear | `steam_bomb.tscn` / `time_gear.tscn` | `Sprite2D` + `steam_bomb_icon` / `time_gear_icon`; parıltı/bırak açık |

**ORTAM (environment_manager) — programatik, çoğunlukla ColorRect** | Açıklama | Görsel
|---|---|---
| Vakum orb | `Node2D` + `Sprite2D` `magnet.png` (mıknatıs pickup), toplamada tüm XP/altın `vacuum_attract` | Yüzen metin **🌀 VAKUM!**; polisaj: ayrı VFX / ses ince ayarı açık |
| Buz fıçısı (freeze) | `freeze_barrel.gd` — varil `freeze_barrel_icon`, patlama `freeze_burst` | **Kısmi** (parçacık / ritüel açık) |
| Zehir tuzağı (poison) | `poison_trap.gd` — yeşil kare, zehir bulutu | **❌** aynı |
| Risk / Şeytan sunağı | `shrine_of_risk.gd` — mor/kan kırmızı kare, emoji `⚠` / `☠` | **❌** tütsü / alınlık hiyerarşi vs. ileri sanat |
| Kırılabilir sandık (crate) | `destructible_crate.gd` — kahverengi + sarı sınır | **❌** ayrı kutu mesh/sprite; içerik: bounce/speed/… floating |
| Enkaz önbelleği (ruin) | `environment_manager` içinde 28×28 kahverengi+altın glow pulse | **❌** ayrı “hazine”/enkaz cismi; ödül metni floating |

**Eşya yordamları (oyun-içi, pasif sınıf, çoğunlukla veri) — ayrı dünya mesh’i yok:** `item_blood_pool` Alan ColorRect; diğer pasiflerin çoğu sadece istat / proc. Detay: `colorrect.md` eşya satırları.

**Düşman mermileri (projectiles) — ayrı tabloda; final sanat açık:** `projectiles/bullet|dagger|hunter_axe|ice_ball|lightning_bolt|fan_blade_shard|enemy_bullet` — aşağıdaki «Projectile ve düşman mermisi» + silah bölümlerinde takip.

**Hasar sayıları (floating `damage_number`)** — `effects/damage_number` — oyunu taşır; özel stil, damage type renk ayrımı, büyük kritik: **Kısmi / açık**

**Görünmeyen / sadece kod (burada satır açmaya gerek yok):** `effects/combat_projectile_fx.gd`, `effects/lightning_hit_fx.tscn` — isabet/çizim yardımcıları; ayrı “cisim” değil, silah/chain sanatı ile birleşir.

**Kısa not:** Tüm yukarıdakiler, loadout/level-up ekranı ve silah tscn’leri dışındadır. Silah/ikon eksiği: `colorrect.md`. Aynı «dünya / spawn» envanteri, `colorrect.md` sonunda kısa özet tabloda yinelenir.

---

## Projectile ve düşman mermisi

| Sahne | Final sanat |
|-------|----------------|
| bullet.tscn | ✅ / ❌ |
| dagger.tscn | ✅ / ❌ | İnce `Sprite2D` + `bullet.gd` (ObjectPool) |
| hunter_axe.tscn | ✅ | Avcı baltası (ObjectPool); Sprite2D + `assets/projectiles/axe/boomerang.png` |
| ice_ball.tscn | ✅ / ❌ |
| fan_blade_shard.tscn | ✅ / kısmi — `assets/projectiles/fan_blade/shard.png` + `Sprite2D`; yoksa `Polygon2D` (`fan_blade_shard.gd`) |
| enemy_bullet.tscn | ✅ / ❌ |

---

## UI, HUD ve menüler

| Alan | Dosya / konum | İkon / layout / tutarlı tema |
|------|----------------|------------------------------|
| Açılış ekranı | `ui/intro_splash` | Aynı `main_menu_bg.*` adayı, tint yok (tam parlaklık); yalnızca başta siyah ~5 sn fade; 4–6. sn alttan kalkan “devam” metni (konum `intro_splash.gd` `PROMPT_*`); müzik track 1; tuş/tık/kol → ana menü |
| Ana menü | `ui/main_menu` | Tam ekran foto: `assets/ui/main_menu_bg.*` (yoksa düz renk + yıldızlar); **buton kapakları:** `assets/button covers/button1.png` → `StyleBoxTexture` (`main_menu.gd`), atlas `region_rect` + yatay nine-patch; Mağaza → `shop_menu` iskelet — ayrıntı **`docs/GELISTIRICI_REHBERI.md` §7.1** |
| Mağaza (kozmetik / pet / fragman) | `ui/shop_menu` | ❌ Placeholder sekmeler; satın alma UI yok |
| Karakter seçimi (+ P2) | `ui/character_select*` + `character_select_preview.gd` + `character_select_stats_panel.gd` | Dört rol filtresi; portre = `idle_left` (yoksa yedek) ilk kare, sabit çerçeve; kilit=siyah; koşul açık=silüet; satın alınmış=tam renk; tam ekran arka plan + margin’li layout; sağda meta taban + kahraman bonus özet istatistikleri |
| Harita / mod | `ui/map_select` | Story / fast / arena; harita önizlemesi; **koşu laneti** kaydırıcı + EN-only açıklama/ölçek çubukları (`tr_en_source`, `run_curse_stat_bar.gd`) |
| Level-up kartları | `ui/upgrade_ui` | Kısmi — üç panel + dikey kartlar + envanter `tooltip_text` + `en.json` kabuk metinleri; büyük sprite ikon seti yok |
| HUD (kill, altın, XP, silah/eşya) | `player` + CanvasLayer | Koşu envanteri: iki satır ikon + `LVL` (`PlayerUiHelpers.rebuild_run_loadout_hud`, teal panel); kill/altın satırı ayrı |
| Oyun sonu | `ui/game_over` | ✅ |
| Duraklat | `ui/pause_menu` | ✅ / ❌ |
| Meta upgrade | `ui/meta_upgrade` | ✅ — üst hizalı sütun + `ScrollContainer` ile kart ızgarası kaydırılabilir |
| Ayarlar | `ui/settings` | ✅ — Ses: müzik parça kontrolleri + `music_volume` + isteğe bağlı **`combat_music_duck`** (kısa müzik dip’i; etiket `tr_en_source` → yalnız `en.json`) |
| Arayüz dili (çeviri) | `locales/*.json`, `LocalizationManager`, Ayarlar → Dil | ✅ `tr` / `en` / `zh_CN`; level-up kabuk `ui.upgrade_ui.*`; run yüzen uyarılar `ui.alerts.*` + co-op kısa HUD `ui.game.*`; karakter seçimi ipucu/butonlar `ui.character_select.*` (`en` rutin); silah/eşya **etki** satırları çoğunlukla kod içi (`player.gd` / `get_description`) |
| Hasar sayıları | `effects/damage_number` | ✅ |
| Global font ölçeği (okunabilirlik) | `SaveManager.settings["ui_scale"]`, Ayarlar → Görüntü | Kısmi — bazı ekranlarda (`map_select`, `shop_menu`); tüm HUD/menüde zorunlu değil |
| Otomatik pause (odak kaybı) | `main.gd` + `SaveManager` | **Var** — pencere odağı kaybında (`focus_exited`) isteğe bağlı duraklatma: `SaveManager.settings["pause_on_focus_loss"]` (varsayılan açık); `pause_menu` + `get_tree().paused` *(matris «Otomatik duraklatma» satırıyla aynı)* |

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

Ürün hedefleri bu tabloda; **hangi dosyanın nerede çaldığı** için `docs/sesler-muzikler-efektler.md`.

| Konu | Durum |
|------|--------|
| XP toplama (`AudioManager.play_xp`) | ✅ Pentatonik pitch dizisi var |
| Ardışık toplamada “streak” / sürekli yükselen pitch | ✅ `AudioManager` `xp_streak` |
| Level-up / sandık / boss için ayırt edici “ritüel” ses katmanları | Kısmi — sandıkta kısa açılış tween var; ayrı ses katmanı sınırlı |

---

## Erişilebilirlik — görsel ve UI hedefleri (ürün taslağı özeti)

Aşağıdaki maddelerin **kod karşılığı** matriste; burada yalnızca **tasarım çıktısı** beklenenler özetlenir.

- **Görsel karmaşa:** Oyuncu mermi / efekt opaklığı — ✅ `player_vfx_opacity` (Ayarlar / Duraklatma → oynanış); matris Tablo 1 satır 4.
- **Yüksek kontrast düşman:** Ayarlarda açılabilir sarı siluet/çerçeve — ✅ (`enemy_high_contrast_outline`, **Görüntü** sekmesi); matris satır 5.
- **Tuş atamaları:** Ayarlar → **Kontroller** — P1/P2 hareket, duraklat, tam ekran (`InputRemap`); matris satır 18 (fare hareketi hâlâ yok).
- **Renk körlüğü paleti:** Alternatif tema — ❌.
- **Büyük net ikonlar:** Level-up — ❌ (Unicode/emoji ile kısmi okunabilirlik; `upgrade_ui` üç sütun).
- **Ön uyarı (exploder):** Yakınlıkta modulate nabız — ✅; matris satır 15.
- **Öğretici / ilk 10 sn:** Bilinçli “güvenli” görsel ve düşman yerleşimi — kısmi (ayrı tutorial sahnesi yok).

---

## Bağlılık — sunum ve koleksiyon

- **Sandık heyecanı:** Açılış animasyonu + VFX + ses — kısmi.
- **Koleksiyon / wiki / bestiary menüsü** (grid, keşfedilenler) — ✅ `ui/collection_menu`, `CollectionData` + `codex_discovered` / `codex_weapons` / `codex_items` / `codex_maps` + kahraman kilidi; 6 sekme (düşman, boss, silah, eşya, kahraman, harita), kart + detay.
- **Kozmetik ödüller** (şapka, mermi rengi, texture varyantı) — ❌.
- **Görsel juiciness:** Hit-stop, parçacık, orb — ✅ (genel); yoğun sahnede polish devam edebilir. **Meta (2026-04-16):** hesap seviye atlayınca `SaveManager.level_up` → `AudioManager.play_account_level_up` (`LevelUpPlayer` / `levelup.mp3`); Ayarlar → Profil’de hesap `ProgressBar` üzerinde modulate tween parlama; `account_profile_level_flash_pending` ile oyun sonu sonrası Profil açılışında da bir kez tetiklenir; Game Over’da “Account XP gained” satırı daha büyük punto + outline.

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

## Wiki-arşiv (VS / Brotato) — tasarım notları

Kaynak: `docs/vs wiki analizi/` (proje başı üç aşamalı VS özeti + Brotato arena notu). Burada yalnızca **görsel / isimlendirme / ürün sunumu** ile ilgili damıtılmış başlıklar; teknik özet **`YOL_HARITASI.md`** «Referans — VS / Brotato wiki analizi».

- **Sandık görsel hiyerarşisi:** Tema uyumlu tier isimleri (ör. pas rengi / demir / **rün** sandığı) — boss düşüşü ile normal sandığı ayıran ikon + çerçeve seti.
- **Özel pickup / orb:** “Buhar patlaması” (alan temizleme), “zaman dişlisi” (kısa donma), tek seferlik XP toplama darbesi — ikon (`upgrade_icons` / orb), VFX, kodeks kartı; `sesler-muzikler-efektler.md` ile tetik eşlemesi.
- **Arena (tam paket):** Brotato referansındaki **dalga süre eğrisi**, elite/horde dalga uyarısı UI, **boss çok faz** (HP eşiği veya süre ile faz değişimi) — Reaper dışı “arena sonu” için ayrı siluet / renk okuması.
- **Koleksiyon / rehber:** Evrim tariflerini gösteren **grimuar / blueprint** ekranı — mevcut kodeks grid’ine ek sekme veya ayrı menü (wiki Aşama 2 §7).

---

## Bu dosyayı ne zaman güncelle?

- Yeni karakter, silah, eşya, düşman veya orb eklenince ilgili satırları ekle; silah/eşya için **mantık / ikon / projectile / tasarım** beş sütununu doldur (eşyada projectile hücresi **`/`**).
- Bir görsel veya ikon **tamamlandığında** ✅ yap; placeholder kaldıysa ❌ bırak.
- `docs/YOL_HARITASI.md` artık görsel iş listesi taşımaz; görsel iş burada kapanır.
