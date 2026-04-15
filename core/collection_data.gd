class_name CollectionData
extends RefCounted
## Kodeks girişleri. Yeni içerik: ilgili *_ENTRIES satırı + `locales` `codex.<tab>.<id>` (düşman/boss: düz `codex.<id>`).

const TAB_ENEMY := "enemy"
const TAB_BOSS := "boss"
const TAB_WEAPON := "weapon"
const TAB_ITEM := "item"
const TAB_CHARACTER := "character"
const TAB_MAP := "map"

## Ana menü / kodeks sekmeleri sırası (UI ile aynı).
const TAB_ORDER: Array[String] = [
	TAB_ENEMY, TAB_BOSS, TAB_WEAPON, TAB_ITEM, TAB_CHARACTER, TAB_MAP,
]

const ENEMY_ENTRIES: Array = [
	{"id": "enemy", "tab": TAB_ENEMY, "emoji": "🟥", "accent": "#E74C3C"},
	{"id": "fast_enemy", "tab": TAB_ENEMY, "emoji": "⚡", "accent": "#F1C40F"},
	{"id": "tank_enemy", "tab": TAB_ENEMY, "emoji": "🛡", "accent": "#9B59B6"},
	{"id": "dasher", "tab": TAB_ENEMY, "emoji": "💗", "accent": "#FF1493"},
	{"id": "healer", "tab": TAB_ENEMY, "emoji": "✚", "accent": "#00FF7F"},
	{"id": "exploder", "tab": TAB_ENEMY, "emoji": "💥", "accent": "#FF6B00"},
	{"id": "shield_enemy", "tab": TAB_ENEMY, "emoji": "🔷", "accent": "#4169E1"},
	{"id": "giant", "tab": TAB_ENEMY, "emoji": "🗿", "accent": "#8B0000"},
	{"id": "ranged_enemy", "tab": TAB_ENEMY, "emoji": "🏹", "accent": "#E67E22"},
]

const BOSS_ENTRIES: Array = [
	{"id": "mini_boss", "tab": TAB_BOSS, "emoji": "👹", "accent": "#C0392B"},
	{"id": "reaper", "tab": TAB_BOSS, "emoji": "☠", "accent": "#1A0000"},
]

## Temel silahlar (`ui/upgrade_ui.gd` weapon_upgrades) + evrim silahları (`WeaponEvolution.EVOLUTIONS`).
const WEAPON_ENTRIES: Array = [
	{"id": "bullet", "tab": TAB_WEAPON, "emoji": "🎯", "accent": "#BDC3C7"},
	{"id": "dagger", "tab": TAB_WEAPON, "emoji": "🗡", "accent": "#5B2C6F"},
	{"id": "veil_daggers", "tab": TAB_WEAPON, "emoji": "🌑", "accent": "#5B2C6F"},
	{"id": "aura", "tab": TAB_WEAPON, "emoji": "⭕", "accent": "#9B59B6"},
	{"id": "chain", "tab": TAB_WEAPON, "emoji": "🔗", "accent": "#3498DB"},
	{"id": "boomerang", "tab": TAB_WEAPON, "emoji": "🪓", "accent": "#27AE60"},
	{"id": "lightning", "tab": TAB_WEAPON, "emoji": "⚡", "accent": "#F1C40F"},
	{"id": "ice_ball", "tab": TAB_WEAPON, "emoji": "❄", "accent": "#00BFFF"},
	{"id": "shadow", "tab": TAB_WEAPON, "emoji": "👤", "accent": "#8E44AD"},
	{"id": "laser", "tab": TAB_WEAPON, "emoji": "📡", "accent": "#E74C3C"},
	{"id": "fan_blade", "tab": TAB_WEAPON, "emoji": "🪭", "accent": "#D35400"},
	{"id": "holy_bullet", "tab": TAB_WEAPON, "emoji": "✨", "accent": "#ECF0F1"},
	{"id": "toxic_chain", "tab": TAB_WEAPON, "emoji": "☠", "accent": "#2ECC71"},
	{"id": "death_laser", "tab": TAB_WEAPON, "emoji": "💀", "accent": "#8B0000"},
	{"id": "blood_boomerang", "tab": TAB_WEAPON, "emoji": "🩸", "accent": "#C0392B"},
	{"id": "storm", "tab": TAB_WEAPON, "emoji": "🌩", "accent": "#F39C12"},
	{"id": "shadow_storm", "tab": TAB_WEAPON, "emoji": "🌑", "accent": "#5B2C6F"},
	{"id": "frost_nova", "tab": TAB_WEAPON, "emoji": "💠", "accent": "#AED6F1"},
	{"id": "ember_fan", "tab": TAB_WEAPON, "emoji": "🔥", "accent": "#E67E22"},
	{"id": "hex_sigil", "tab": TAB_WEAPON, "emoji": "⬡", "accent": "#48C9B0"},
	{"id": "binding_circle", "tab": TAB_WEAPON, "emoji": "⌘", "accent": "#1ABC9C"},
	{"id": "gravity_anchor", "tab": TAB_WEAPON, "emoji": "⚓", "accent": "#AF7AC5"},
	{"id": "void_lens", "tab": TAB_WEAPON, "emoji": "🕳", "accent": "#884EA0"},
	{"id": "bastion_flail", "tab": TAB_WEAPON, "emoji": "⛓", "accent": "#7F8C8D"},
	{"id": "citadel_flail", "tab": TAB_WEAPON, "emoji": "🏰", "accent": "#566573"},
	{"id": "shield_ram", "tab": TAB_WEAPON, "emoji": "🛡", "accent": "#B7950B"},
	{"id": "fortress_ram", "tab": TAB_WEAPON, "emoji": "⚔", "accent": "#9A7D0A"},
]

## `ui/upgrade_ui.gd` item_upgrades ile uyumlu.
const ITEM_ENTRIES: Array = [
	{"id": "lifesteal", "tab": TAB_ITEM, "emoji": "🩸", "accent": "#C0392B"},
	{"id": "armor", "tab": TAB_ITEM, "emoji": "🛡", "accent": "#7F8C8D"},
	{"id": "crit", "tab": TAB_ITEM, "emoji": "💥", "accent": "#E74C3C"},
	{"id": "explosion", "tab": TAB_ITEM, "emoji": "💣", "accent": "#FF6B00"},
	{"id": "magnet", "tab": TAB_ITEM, "emoji": "🧲", "accent": "#3498DB"},
	{"id": "poison", "tab": TAB_ITEM, "emoji": "☣", "accent": "#27AE60"},
	{"id": "shield", "tab": TAB_ITEM, "emoji": "🔰", "accent": "#1ABC9C"},
	{"id": "speed_charm", "tab": TAB_ITEM, "emoji": "💨", "accent": "#F1C40F"},
	{"id": "blood_pool", "tab": TAB_ITEM, "emoji": "🫧", "accent": "#922B21"},
	{"id": "luck_stone", "tab": TAB_ITEM, "emoji": "🍀", "accent": "#2ECC71"},
	{"id": "turbine", "tab": TAB_ITEM, "emoji": "⚙", "accent": "#95A5A6"},
	{"id": "steam_armor", "tab": TAB_ITEM, "emoji": "♨", "accent": "#BDC3C7"},
	{"id": "energy_cell", "tab": TAB_ITEM, "emoji": "🔋", "accent": "#F39C12"},
	{"id": "ember_heart", "tab": TAB_ITEM, "emoji": "🔥", "accent": "#E74C3C"},
	{"id": "glyph_charm", "tab": TAB_ITEM, "emoji": "📜", "accent": "#48C9B0"},
	{"id": "resonance_stone", "tab": TAB_ITEM, "emoji": "💎", "accent": "#AF7AC5"},
	{"id": "rampart_plate", "tab": TAB_ITEM, "emoji": "🧱", "accent": "#7F8C8D"},
	{"id": "iron_bulwark", "tab": TAB_ITEM, "emoji": "🔩", "accent": "#B7950B"},
	{"id": "night_vial", "tab": TAB_ITEM, "emoji": "🌙", "accent": "#5B2C6F"},
]

const MAP_ENTRIES: Array = [
	{"id": "vs_map", "tab": TAB_MAP, "emoji": "🏰", "accent": "#27AE60"},
	{"id": "map2", "tab": TAB_MAP, "emoji": "🗺", "accent": "#6C3483"},
	{"id": "map3", "tab": TAB_MAP, "emoji": "🗺", "accent": "#5D6D7E"},
]

static func _char_emoji(char_id: String) -> String:
	var m = {
		"warrior": "⚔",
		"mage": "🔮",
		"vampire": "🧛",
		"hunter": "🏹",
		"stormer": "🌩",
		"frost": "❄",
		"shadow_walker": "👤",
		"engineer": "🔧",
		"paladin": "🛡",
		"blood_prince": "👑",
		"nomad": "🐪",
		"death_knight": "💀",
		"chaos": "🌀",
		"omega": "∞",
		"sigil_warden": "⬡",
		"grav_binder": "🌀",
		"ironclad": "⛓",
		"linebreaker": "🛡",
		"dusk_striker": "🗡",
	}
	return str(m.get(char_id, "⭐"))


static func character_entries() -> Array:
	var out: Array = []
	for c in CharacterData.CHARACTERS:
		var cid: String = str(c.get("id", ""))
		if cid.is_empty():
			continue
		out.append({
			"id": cid,
			"tab": TAB_CHARACTER,
			"emoji": _char_emoji(cid),
			"accent": str(c.get("color", "#9B59B6")),
		})
	return out


static func all_entries() -> Array:
	var a: Array = []
	a.append_array(ENEMY_ENTRIES)
	a.append_array(BOSS_ENTRIES)
	a.append_array(WEAPON_ENTRIES)
	a.append_array(ITEM_ENTRIES)
	a.append_array(character_entries())
	a.append_array(MAP_ENTRIES)
	return a


static func entries_for_tab(tab: String) -> Array:
	var out: Array = []
	for e in all_entries():
		if str(e.get("tab", "")) == tab:
			out.append(e)
	return out


static func total_entry_count() -> int:
	return all_entries().size()


## Sadece düşman/boss ölümünde kayıt (`register_codex_discovered`).
static func has_bestiary_id(entry_id: String) -> bool:
	for e in ENEMY_ENTRIES:
		if e["id"] == entry_id:
			return true
	for e in BOSS_ENTRIES:
		if e["id"] == entry_id:
			return true
	return false


static func has_entry(entry_id: String) -> bool:
	for e in all_entries():
		if e["id"] == entry_id:
			return true
	return false


static func get_entry_by_tab_id(tab: String, entry_id: String) -> Dictionary:
	for e in all_entries():
		if str(e.get("tab", "")) == tab and str(e.get("id", "")) == entry_id:
			return e
	return {}


static func is_valid_weapon_codex_id(wid: String) -> bool:
	for e in WEAPON_ENTRIES:
		if e["id"] == wid:
			return true
	return false


static func is_valid_item_codex_id(iid: String) -> bool:
	for e in ITEM_ENTRIES:
		if e["id"] == iid:
			return true
	return false


static func is_valid_map_codex_id(mid: String) -> bool:
	for e in MAP_ENTRIES:
		if e["id"] == mid:
			return true
	return false
