# ColorRect — hızlı takip

**Kullanım:** Bir satır tamamlanınca **satırı sil**; yeni gap açılırsa **ekle**. Detay için `docs/TASARIM.md`.

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

**Kart / kodeks ikon:** yukarıdaki PNG gerçekten var mı (evrim silahlarında `evolutions/`).

**Oyun-içi görsel:** `assets/projectiles/...`, anlamlı `Sprite2D` + doku (sahne veya kod), veya `projectiles/*.tscn` içi sprite; yalnızca gizli `ColorRect` / saf yarıçap hasarı / runtime `ColorRect` ✗ sayılır.

| Sahne | Silah ID | Kart / kodeks ikon | Oyun-içi görsel |
|-------|----------|-------------------|-----------------|
| `weapon_bastion_flail.tscn` | bastion_flail | ✓ | ✗ |
| `weapon_binding_circle.tscn` | binding_circle | ✗ | ✗ |
| `weapon_citadel_flail.tscn` | citadel_flail | ✗ | ✗ |
| `weapon_ember_fan.tscn` | ember_fan | ✗ | ✓ |
| `weapon_fortress_ram.tscn` | fortress_ram | ✗ | ✗ |
| `weapon_frost_nova.tscn` | frost_nova | ✗ | ✗ |
| `weapon_gravity_anchor.tscn` | gravity_anchor | ✓ | ✗ |
| `weapon_hex_sigil.tscn` | hex_sigil | ✓ | ✗ |
| `weapon_ice_ball.tscn` | ice_ball | ✗ | ✓ |
| `weapon_shadow_storm.tscn` | shadow_storm | ✗ | ✗ |
| `weapon_shield_ram.tscn` | shield_ram | ✓ | ✗ |
| `weapon_veil_daggers.tscn` | veil_daggers | ✗ | ✓ |
| `weapon_void_lens.tscn` | void_lens | ✗ | ✗ |

Runtime `ColorRect` (sahne envanteri değil): `weapon_frost_nova.gd`, `weapon_shadow.gd`, `weapon_shadow_storm.gd`.

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
