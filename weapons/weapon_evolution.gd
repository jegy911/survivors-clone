class_name WeaponEvolution
extends Node
## Evolution recipes and level-up eligibility. Design tables: `docs/SILAHLAR_ESYALAR_EVO.md` (§2 evolutions, tail matrix).
## `death_laser`: `laser` + `crit` (both MAX). `arc_surge`: `arc_pulse` + `field_lens` (both MAX). `frost_nova`: `ice_ball` + `armor` + `shield` (all MAX). Runtime: `is_evolution_ready`, `player.gd` `evolve_weapon`.

## Display strings: `locales/en.json` → `ui.evolution_defs.<id>.name` / `.desc` (`TranslationServer` = `Node.tr()` pipeline).
const EVOLUTIONS = {
	"holy_bullet": {
		"requires_weapons": ["bullet"],
		"requires_items": ["armor"],
	},
	"toxic_chain": {
		"requires_weapons": ["chain"],
		"requires_items": ["poison"],
	},
	"death_laser": {
		"requires_weapons": ["laser"],
		"requires_items": ["crit"],
	},
	"blood_boomerang": {
		"requires_weapons": ["boomerang"],
		"requires_items": ["lifesteal"],
	},
	"storm": {
		"requires_weapons": ["lightning"],
		"requires_items": ["speed_charm"],
	},
	"shadow_storm": {
		"requires_weapons": ["shadow", "lightning"],
		"requires_items": ["speed_charm"],
	},
	"frost_nova": {
		"requires_weapons": ["ice_ball"],
		"requires_items": ["armor", "shield"],
	},
	"ember_fan": {
		"requires_weapons": ["fan_blade"],
		"requires_items": ["ember_heart"],
	},
	"binding_circle": {
		"requires_weapons": ["hex_sigil"],
		"requires_items": ["glyph_charm"],
	},
	"void_lens": {
		"requires_weapons": ["gravity_anchor"],
		"requires_items": ["resonance_stone"],
	},
	"citadel_flail": {
		"requires_weapons": ["bastion_flail"],
		"requires_items": ["rampart_plate"],
	},
	"fortress_ram": {
		"requires_weapons": ["shield_ram"],
		"requires_items": ["iron_bulwark"],
	},
	"veil_daggers": {
		"requires_weapons": ["dagger"],
		"requires_items": ["night_vial"],
	},
	"arc_surge": {
		"requires_weapons": ["arc_pulse"],
		"requires_items": ["field_lens"],
	},
}

static func _meets_weapon_requirements(player, evo: Dictionary) -> bool:
	for w in evo["requires_weapons"]:
		if not player.active_weapons.has(w):
			return false
		var weapon = player.active_weapons[w]
		var required_level = weapon.max_level
		if player.get("blood_oath_active") and player.blood_oath_active:
			required_level = max(1, int(weapon.max_level / 2.0))
		if weapon.level < required_level:
			return false
	return true


static func _meets_item_requirements(player, evo: Dictionary) -> bool:
	for i in evo["requires_items"]:
		if not player.active_items.has(i):
			return false
		var item = player.active_items[i]
		if item.level < item.max_level:
			return false
	return true


## Gerekli silah/eşya MAX, evrim silahı henüz yok.
static func is_evolution_ready(player, evo_id: String) -> bool:
	if not EVOLUTIONS.has(evo_id):
		return false
	if player.active_weapons.has(evo_id):
		return false
	var evo = EVOLUTIONS[evo_id]
	return _meets_weapon_requirements(player, evo) and _meets_item_requirements(player, evo)


static func get_available_evolutions(player) -> Array:
	var available: Array = []
	for evo_id in EVOLUTIONS:
		if is_evolution_ready(player, evo_id):
			available.append(evo_id)
	available.shuffle()
	return available


static func get_evolution_weight(evo_id: String) -> float:
	if not EVOLUTIONS.has(evo_id):
		return 10.0
	return float(EVOLUTIONS[evo_id].get("weight", 10.0))


static func _evo_tr(key: String) -> String:
	return str(TranslationServer.translate(StringName(key)))


static func localized_name(evo_id: String) -> String:
	if not EVOLUTIONS.has(evo_id):
		return evo_id
	var key := "ui.evolution_defs.%s.name" % evo_id
	var t := _evo_tr(key)
	return t if t != key else evo_id


static func localized_description(evo_id: String) -> String:
	if not EVOLUTIONS.has(evo_id):
		return ""
	var key := "ui.evolution_defs.%s.desc" % evo_id
	var t := _evo_tr(key)
	return t if t != key else ""
