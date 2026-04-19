class_name UpgradeIconCatalog
extends RefCounted
## Level-up / envanter için PNG yolları. Dosya yoksa `upgrade_ui` emoji yedeğine düşer.
## Klasör yapısı: `assets/ui/upgrade_icons/README.txt`

const ICON_ROOT := "res://assets/ui/upgrade_icons"

static func weapon_texture_path(weapon_id: String) -> String:
	return "%s/weapons/%s.png" % [ICON_ROOT, weapon_id]


static func item_texture_path(item_id: String) -> String:
	return "%s/items/%s.png" % [ICON_ROOT, item_id]


static func evolution_texture_path(evo_id: String) -> String:
	return "%s/evolutions/%s.png" % [ICON_ROOT, evo_id]


static func stat_texture_path(stat_id: String) -> String:
	return "%s/stats/%s.png" % [ICON_ROOT, stat_id]


static func try_texture_at(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var res: Resource = load(path)
	return res as Texture2D


static func try_weapon(weapon_id: String) -> Texture2D:
	return try_texture_at(weapon_texture_path(weapon_id))


static func try_item(item_id: String) -> Texture2D:
	return try_texture_at(item_texture_path(item_id))


static func try_evolution(evo_id: String) -> Texture2D:
	var t: Texture2D = try_texture_at(evolution_texture_path(evo_id))
	if t != null:
		return t
	## Dosya adı evrim id’sinden farklı import edildiyse (ör. `shadow_storm` → `storm_shadow.png`).
	if evo_id == "shadow_storm":
		return try_texture_at("%s/evolutions/storm_shadow.png" % ICON_ROOT)
	return null


## Silah kartı / kodeks: bazı sonuç silahları yalnızca `evolutions/<id>.png` altında olabilir.
static func try_weapon_with_evolution_fallback(weapon_id: String) -> Texture2D:
	var w: Texture2D = try_weapon(weapon_id)
	if w != null:
		return w
	return try_evolution(weapon_id)


static func try_stat(stat_id: String) -> Texture2D:
	return try_texture_at(stat_texture_path(stat_id))
