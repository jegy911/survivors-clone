# ColorRect — hızlı takip

**Kullanım (silah / kahraman / eşya):** Bir satırda **Kart ✓ + Oyun-içi görsel ✓** tamamlandıysa o satırı tablodan **sil**; ilgili `id` değerini aşağıdaki **Son tarama** listesine ekle. Kısmi gap (ör. ✓|✗) **satırda kalır**. Yeni gap açılırsa yeni satır **ekle**. Detay: `docs/TASARIM.md`. SFX envanteri: `docs/sesler-muzikler-efektler.md`.

**Dünya, orb, sandık, environment spawn:** Tam liste ve XP **3 tür** hedefi için ana kaynak: **`docs/TASARIM.md` -> "Pickup, orb ve dünya objeleri"** (burada kısa özet tutulur).

**İşaretler:** ✓ = var (dosya veya anlamlı oyun-içi görsel), ✗ = yok / henüz yok.

**Not:** Kahraman sahnelerindeki kök `ColorRect` çoğunlukla `player.gd` gövde rengi içindir; bu dosya özellikle **eksik ikon** ve **eksik oyun-içi silah/eşya görseli** takibi içindir.

---

## Kahraman

| Karakter ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------------|-------------------|-----------------|
| *(şu an açık gap yok)* | — | — |

**Kart / kodeks ikon:** `res://assets/ui/character_icons/<id>.png`, `res://characters/<id>/codex.png`, `res://assets/ui/codex_icons/...` vb. (`CodexIconCatalog` / `UpgradeIconCatalog` sırasıyla dener).

**Oyun-içi görsel:** `AnimatedSprite2D` + dolu frame / karakter dokuları (`assets/character assets/...`); burada satır yoksa hepsi bu anlamda kapsanıyor sayılır.

---

## Silah sahneleri (`weapons/scenes/`)

**Silah ID:** Dosya adından `weapon_` önekini ve `.tscn` uzantısını çıkar -> örn. `weapon_bastion_flail.tscn` -> `bastion_flail` -> ikon yolu `res://assets/ui/upgrade_icons/weapons/bastion_flail.png`; yoksa `.../evolutions/<aynı_id>.png` (`arc_surge` gibi). Kod: `UpgradeIconCatalog.try_weapon_with_evolution_fallback`.

**Kart / kodeks ikon:** Yukarıdaki PNG gerçekten var mı (evrim silahlarında çoğunlukla `evolutions/`).

**Oyun-içi görsel:** `assets/projectiles/...`, anlamlı `Sprite2D` + doku (sahne veya kod), veya `projectiles/*.tscn` içi sprite; **runtime** olarak ana dünyaya eklenen tekillik / mermi sprite'ı da ✓ (örn. `weapons/center_cataclysm_helper.gd`). Yalnızca gizli `ColorRect` + anlamlı sprite/hitbox yok + saf yarıçap hasarı = ✗.

Evrim kimlikleri tek kaynak: `weapons/weapon_evolution.gd` -> `EVOLUTIONS`.

### Taban silahlar

Level-up havuzundan doğrudan seçilen / evrim **sonucu olmayan** silah sahneleri — **yalnızca en az bir ✗ kalanlar** (ikisi ✓ olunca satır silinir).

| Sahne | Silah ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------|----------|-------------------|-----------------|
| *(taban gap yok)* | — | — | — |

### Evrim silahları

Yalnızca `EVOLUTIONS` ile elde edilen silah ID'leri — **yalnızca en az bir ✗ kalanlar**.

| Sahne | Silah ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------|----------|-------------------|-----------------|
| *(evrim gap yok)* | — | — | — |

**Son tarama (kart ✓ + oyun-içi ✓ — yukarıdaki gap tablolarında artık satır yok):**

- **Taban:** `arc_pulse`, `aura`, `bullet`, `chain`, `boomerang`, `dagger`, `fan_blade`, `hex_sigil`, `ice_ball`, `laser`, `lightning`, `shadow`, `shield_ram`, `bastion_flail`, `gravity_anchor`
- **Evrim:** `arc_surge`, `blood_boomerang`, `binding_circle`, `citadel_flail`, `death_laser`, `ember_fan`, `fortress_ram`, `frost_nova`, `holy_bullet`, `shadow_storm`, `storm`, `toxic_chain`, `veil_daggers`, `void_lens`

Runtime `ColorRect` / geçici blok (sahne `.tscn` dışı, “kalıcı sanat” değil): `weapon_shadow.gd`.

---

## Eşyalar (`items/` — sahne yok, script + ikon)

Pasif eşyalar `items/item_<id>.gd` ile yüklenir; **`.tscn` yok**. İleride dünyada görünür efekt / özel doku eklendikçe **Oyun-içi görsel** sütununu güncelle.
Bu tabloda yalnızca **en az bir ✗** kalan satırlar tutulur (ikisi de ✓ olunca satır silinir).

**Kart / kodeks ikon:** `res://assets/ui/upgrade_icons/items/<id>.png` (`UpgradeIconCatalog.try_item`).

**Oyun-içi görsel:** Oyunda dünyaya eklenen görünür node / partikül / özel efekt doku yolu (yalnızca sayısal pasif etki = ✗).

**İşlev / görev:** Pasifin oyunda yaptığı iş (kısa özet; ayrıntı `items/item_<id>.gd` ve locale metinleri).

| Eşya ID | İşlev / görev | Kart / kodeks ikon | Oyun-içi görsel |
|---------|----------------|-------------------|-----------------|
| lifesteal | Verilen hasarın bir kısmı kadar can (vuruş başına) | ✓ | ✗ |
| armor | Alınan hasarı zırh değeriyle azaltma | ✓ | ✗ |
| crit | Kritik vuruş şansı; krit çarpanı | ✓ | ✗ |
| magnet | XP orb çekim menzili artışı | ✓ | ✗ |
| poison | Vuruşta düşmana zehir DoT uygulama | ✓ | ✗ |
| shield | Bekleme sonrası tek seferlik hasar absorbe (kalkan) | ✓ | ✗ |
| luck_stone | Ek krit şansı + altın toplama bonusu | ✓ | ✗ |
| turbine | Son hareket süresine göre biriken hasar bonusu | ✓ | ✗ |
| steam_armor | Hasar alınca kısa yenilmezlik, sonra bekleme | ✓ | ✗ |
| energy_cell | Periyodik: tüm silahları anında ateş + ardından geçici yavaş cooldown | ✓ | ✗ |
| ember_heart | Düşman öldürünce sabit can iyileşmesi | ✗ | ✗ |
| glyph_charm | Alınan hasara ek "ward" / zırh katkısı (`take_damage`) | ✗ | ✗ |
| resonance_stone | XP + altın pickup çekim yarıçapı (magnet bonusu ile toplanır) | ✗ | ✗ |
| rampart_plate | Ek zırh değeri (savunma) | ✗ | ✗ |
| iron_bulwark | Düz (flat) hasar kesintisi | ✗ | ✗ |
| night_vial | Hafif pickup çekim yarıçapı (evrim yolu / loadout) | ✗ | ✗ |
| field_lens | Alan ölçekli silahlara `%` alan bonusu (`get_area_multiplier`) | ✓ | ✗ |

**Listeden çıkan (✓ + ✓ tamam):** `explosion`, `speed_charm`, `blood_pool`

---

## Dünya / spawn cisimleri — oyun-içi görsel bacağı (özet)

*(Olasılık, kod ve kapsamın tamamı: `docs/TASARIM.md`. Burada istenen hızlı takip için yalnız görsel sütunları tutulur.)*

| Cisim / sistem | Kart / kodeks ikon | Oyun-içi görsel | Not (kısa) |
|----------------|-------------------|-----------------|------------|
| **XP 1× / 3× / 8×** (3 tür) | ✗ | ✓ | `xp.png` / `green_xp.png` / `red_xp.png` |
| Altın küre | ✗ | ✓ | `gold.png` |
| Sandık | ✗ | ✗ | ColorRect placeholder |
| Kan yemini (Blood Oath) | ✗ | ✗ | ColorRect placeholder |
| Dişli parçası (Cog) | ✗ | ✓ | `cog.png` sprite |
| Zaman dişlisi | ✗ | ✓ | `time_gear_icon.png` sprite |
| Buhar bombası | ✗ | ✓ | `steam_bomb_icon.png` sprite |
| Vakum toplayıcı | ✗ | ✗ | runtime cyan kare |
| Buz fıçısı (freeze) | ✗ | ✓ | `freeze_barrel_icon` + `freeze_burst` |
| Zehir tuzağı | ✗ | ✗ | kare + alan efekti |
| Risk sunağı | ✗ | ✗ | kare + `⚠` placeholder |
| Şeytan sunağı | ✗ | ✗ | kare + `☠` placeholder |
| Kırılabilir kutu (crate) | ✗ | ✗ | ColorRect placeholder |
| Enkaz (ruin cache) | ✗ | ✗ | brown/gold rect placeholder |
| Yüzen hasar metni | ✗ | ✓ | tema + kritik varyantı |
| Düşman mermileri + oyuncu mermileri | ✗ | ✓ | `projectiles/*.tscn` (kısmi/final karışık) |
| Pasif eşyalar (dünya) | ✗ | ✗ | çoğu veri/proc, ayrı mesh yok |
