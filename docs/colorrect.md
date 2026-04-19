# ColorRect — hızlı takip

**Kullanım:** Bu tabloda kalan satır için tasarım / ikon / oyun-içi görsel tamamlanınca **satırı sil**. Yeni boşluk açılırsa **ekle**. Detay için `docs/TASARIM.md`.

**Not:** Kahraman sahnelerinde kök `ColorRect` çoğunlukla `player.gd` gövde rengi; **eksik görsel** = `AnimatedSprite2D` yok veya frame boş. Şu an listede yok.

---

## Kahraman (AnimatedSprite eksik / placeholder)

| ID | Tasarım | Sahne / asset |
|----|---------|---------------|
| — | — | Şu an kayıt yok. |

---

## Silah sahneleri (`weapons/scenes/`)

**Kriter (silah satırı burada *kalır*):** Aşağıdakilerden **en az biri eksik** ise burada listelenir.

1. **Kart / kodeks ikonu:** `res://assets/ui/upgrade_icons/weapons/<silah_id>.png` **veya** `.../evolutions/<id>.png` (`UpgradeIconCatalog.try_weapon_with_evolution_fallback` mantığı; `shadow_storm` → `storm_shadow.png` özel yolu dahil — dosya yoksa sayılmaz).
2. **Oyun-içi görsel:** `assets/projectiles/...` dokusu, anlamlı `Sprite2D` + texture (ör. gölge küresi), veya `projectiles/*.tscn` + sprite; **yalnızca** sahadaki gizli `ColorRect` / radius-hasarı / runtime `ColorRect` sayılmaz.

**Son tarama:** İki koşul da sağlanan silahlar tablodan çıkarıldı (ör. `arc_pulse`, `arc_surge`, `aura`, mermi/zincir/lazer/hançer vb.).

| Sahne | Tasarım |
|-------|---------|
| `weapon_bastion_flail.tscn` | [ ] |
| `weapon_binding_circle.tscn` | [ ] |
| `weapon_citadel_flail.tscn` | [ ] |
| `weapon_ember_fan.tscn` | [ ] |
| `weapon_fortress_ram.tscn` | [ ] |
| `weapon_frost_nova.tscn` | [ ] |
| `weapon_gravity_anchor.tscn` | [ ] |
| `weapon_hex_sigil.tscn` | [ ] |
| `weapon_ice_ball.tscn` | [ ] |
| `weapon_shadow_storm.tscn` | [ ] |
| `weapon_shield_ram.tscn` | [ ] |
| `weapon_veil_daggers.tscn` | [ ] |
| `weapon_void_lens.tscn` | [ ] |

Runtime `ColorRect` (sahne envanteri değil): `weapon_frost_nova.gd`, `weapon_shadow.gd`, `weapon_shadow_storm.gd`.
