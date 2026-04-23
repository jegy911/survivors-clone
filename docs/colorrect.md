# ColorRect — hızlı takip

**Kullanım:** **Kart ✓ ve oyun-içi görsel ✓** aynı satırda ise o silah satırını bu tablolardan **sil**; silah `id`’sini aşağıdaki **Son tarama** listesine ekle. Kısmi gap (ör. ✓|✗) **satırda kalır**. Yeni gap açılırsa satır **ekle**. Detay: `docs/TASARIM.md`. SFX: `docs/sesler-muzikler-efektler.md`.

**İşaretler:** ✓ = var (dosya veya anlamlı oyun-içi görsel), ✗ = yok / henüz yok.

**Not:** Kahraman sahnelerinde kök `ColorRect` çoğunlukla `player.gd` gövde rengi; bu dosya özellikle **eksik ikon** ve **eksik oyun-içi silah/eşya görseli** takibi içindir.

---

## Kahraman

| Karakter ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------------|-------------------|-----------------|
| *(şu an açık gap yok)* | — | — |

**Kart / kodeks ikon:** `res://assets/ui/character_icons/<id>.png`, `res://characters/<id>/codex.png`, `res://assets/ui/codex_icons/...` vb. (`CodexIconCatalog` / `UpgradeIconCatalog` sırasıyla dener).

**Oyun-içi görsel:** `AnimatedSprite2D` + dolu frame / karakter dokuları (`assets/character assets/...`); burada satır yoksa hepsi bu anlamda kapsanıyor sayılır.

---

## Silah sahneleri (`weapons/scenes/`)

**Silah ID:** dosya adından `weapon_` önekini ve `.tscn` uzantısını çıkar → örn. `weapon_bastion_flail.tscn` → `bastion_flail` → ikon yolu `res://assets/ui/upgrade_icons/weapons/bastion_flail.png`; yoksa `.../evolutions/<aynı_id>.png` (`arc_surge` gibi). Kod: `UpgradeIconCatalog.try_weapon_with_evolution_fallback`.

**Kart / kodeks ikon:** yukarıdaki PNG gerçekten var mı (evrim silahlarında çoğunlukla `evolutions/`).

**Oyun-içi görsel:** `assets/projectiles/...`, anlamlı `Sprite2D` + doku (sahne veya kod), veya `projectiles/*.tscn` içi sprite; **runtime** olarak ana dünyaya eklenen tekillik / mermi sprite’ı da ✓ (ör. `weapons/center_cataclysm_helper.gd`). Yalnızca gizli `ColorRect` + anlamlı sprite/hitbox yok + saf yarıçap hasarı ✗ sayılır.

Evrim kimlikleri tek kaynak: `weapons/weapon_evolution.gd` → `EVOLUTIONS`.

### Taban silahlar

Level-up havuzundan doğrudan seçilen / evrim **sonucu olmayan** silah sahneleri — **yalnızca en az bir ✗ kalanlar** (ikisi ✓ olunca satır silinir).

| Sahne | Silah ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------|----------|-------------------|-----------------|
| *(taban gap yok)* | — | — | — |

### Evrim silahları

Yalnızca `EVOLUTIONS` ile elde edilen silah id’leri — **yalnızca en az bir ✗ kalanlar**.

| Sahne | Silah ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------|----------|-------------------|-----------------|
| `weapon_binding_circle.tscn` | binding_circle | ✗ (`evolutions/binding_circle.png` yok) | ✗ |
| `weapon_citadel_flail.tscn` | citadel_flail | ✗ | ✗ |
| `weapon_ember_fan.tscn` | ember_fan | ✗ (`evolutions/ember_fan.png` yok) | ✓ |
| `weapon_frost_nova.tscn` | frost_nova | ✗ | ✗ (kodda yarı saydam `ColorRect` alan; doku yok) |
| `weapon_shadow_storm.tscn` | shadow_storm | ✗ (`evolutions/shadow_storm.png` yok) | ✗ (kodda kısa ömürlü `ColorRect` orb; doku yok) |
| `weapon_veil_daggers.tscn` | veil_daggers | ✗ (`evolutions/veil_daggers.png` yok) | ✓ |

**Son tarama (kart ✓ + oyun-içi ✓ — yukarıdaki gap tablolarında artık satır yok):**

- **Taban:** `arc_pulse`, `aura`, `bullet`, `chain`, `boomerang`, `dagger`, `fan_blade`, `hex_sigil`, `ice_ball`, `laser`, `lightning`, `shadow`, `shield_ram`, `bastion_flail`, `gravity_anchor`
- **Evrim:** `arc_surge`, `blood_boomerang`, `death_laser`, `fortress_ram`, `holy_bullet`, `storm`, `toxic_chain`, `void_lens`

Runtime `ColorRect` / geçici blok (sahne `.tscn` dışı, “kalıcı sanat” değil): `weapon_frost_nova.gd`, `weapon_shadow.gd`, `weapon_shadow_storm.gd`.

---

## Eşyalar (`items/` — sahne yok, script + ikon)

Pasif eşyalar `items/item_<id>.gd` ile yüklenir; **`.tscn` yok**. İleride dünyada görünür efekt / özel doku eklendikçe **Oyun-içi görsel** sütununu güncelle.

**Kart / kodeks ikon:** `res://assets/ui/upgrade_icons/items/<id>.png` (`UpgradeIconCatalog.try_item`).

**Oyun-içi görsel:** Oyunda dünyaya eklenen görünür node / partikül / özel efekt doku yolu (yalnızca sayısal pasif etki ✗).

| Eşya ID | Kart / kodeks ikon | Oyun-içi görsel |
|---------|-------------------|-----------------|
| lifesteal | ✗ | ✗ |
| armor | ✗ | ✗ |
| crit | ✗ | ✗ |
| explosion | ✗ | ✗ |
| magnet | ✗ | ✗ |
| poison | ✗ | ✗ |
| shield | ✗ | ✗ |
| speed_charm | ✗ | ✗ |
| blood_pool | ✗ | ✓ |
| luck_stone | ✗ | ✗ |
| turbine | ✗ | ✗ |
| steam_armor | ✗ | ✗ |
| energy_cell | ✗ | ✗ |
| ember_heart | ✗ | ✗ |
| glyph_charm | ✗ | ✗ |
| resonance_stone | ✗ | ✗ |
| rampart_plate | ✗ | ✗ |
| iron_bulwark | ✗ | ✗ |
| night_vial | ✗ | ✗ |
| field_lens | ✓ | ✗ |
