Codex card & detail art (PNG, optional)
========================================
Kodeks ızgarasında ve sağdaki detay panelinde emoji yerine görsel göstermek için PNG koyun.
Dosya yoksa sırayla diğer yollar denenir; en sonda (silah/eşya) `upgrade_icons` + emoji yedeği.

Öncelik sırası (`CodexIconCatalog.try_for_entry`):

1. `res://assets/ui/codex_icons/<tab>/<id>.png`
2. `res://assets/ui/codex_art/<tab>/<id>.png` — ikinci tasarım kökü (`codex_art/README.txt`)
3. Sekmeye özel yedekler:
   - **character:** `characters/<id>/codex.png`, `characters/<id>/<id>_codex.png`, `assets/ui/character_icons/<id>.png`
   - **map:** `MAP_PREVIEW_TEXTURES` (örn. `vs_map` → `assets/zemin/zemin.png`), `assets/ui/map_previews/<id>.png`, `assets/maps/<id>.png`
   - **enemy / boss:** repodaki sprite temsilcileri (`codex_icon_catalog.gd` içi sözlükler)
   - **glossary:** `assets/ui/glossary_icons/<id>.png`
4. **weapon** / **item:** `assets/ui/upgrade_icons/` (`upgrade_icon_catalog.gd`)

İlk klasör şablonu:

  res://assets/ui/codex_icons/<tab>/<id>.png

`<tab>` değerleri `CollectionData` ile aynıdır:

  enemy/     — bestiary id (örn. enemy.png, tank_enemy.png)
  boss/
  weapon/    — silah id (örn. arc_pulse.png, holy_bullet.png)
  item/      — eşya id (örn. field_lens.png)
  character/ — kahraman id (örn. arcanist.png, warrior.png)
  map/       — harita id (örn. vs_map.png)
  glossary/  — terim id (örn. area.png)

Kare PNG (64–128 px), mümkünse şeffaf arka plan. Ekledikten sonra Godot’ta projeyi yenileyin (import).
