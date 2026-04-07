class_name PlayerLoadoutRegistry
extends RefCounted
## Silah ve pasif eşya `type` → script eşlemesi; `player.gd` içindeki uzun match bloklarının tek kaynağı.

const WEAPON_SCRIPT_BY_ID: Dictionary = {
	"bullet": preload("res://weapons/weapon_bullet.gd"),
	"aura": preload("res://weapons/weapon_aura.gd"),
	"chain": preload("res://weapons/weapon_chain.gd"),
	"boomerang": preload("res://weapons/weapon_boomerang.gd"),
	"lightning": preload("res://weapons/weapon_lightning.gd"),
	"ice_ball": preload("res://weapons/weapon_ice_ball.gd"),
	"shadow": preload("res://weapons/weapon_shadow.gd"),
	"laser": preload("res://weapons/weapon_laser.gd"),
	"holy_bullet": preload("res://weapons/weapon_holy_bullet.gd"),
	"toxic_chain": preload("res://weapons/weapon_toxic_chain.gd"),
	"death_laser": preload("res://weapons/weapon_death_laser.gd"),
	"blood_boomerang": preload("res://weapons/weapon_blood_boomerang.gd"),
	"storm": preload("res://weapons/weapon_storm.gd"),
	"shadow_storm": preload("res://weapons/weapon_shadow_storm.gd"),
	"frost_nova": preload("res://weapons/weapon_frost_nova.gd"),
	"fan_blade": preload("res://weapons/weapon_fan_blade.gd"),
	"ember_fan": preload("res://weapons/weapon_ember_fan.gd"),
	"hex_sigil": preload("res://weapons/weapon_hex_sigil.gd"),
	"binding_circle": preload("res://weapons/weapon_binding_circle.gd"),
	"gravity_anchor": preload("res://weapons/weapon_gravity_anchor.gd"),
	"void_lens": preload("res://weapons/weapon_void_lens.gd"),
	"bastion_flail": preload("res://weapons/weapon_bastion_flail.gd"),
	"citadel_flail": preload("res://weapons/weapon_citadel_flail.gd"),
	"shield_ram": preload("res://weapons/weapon_shield_ram.gd"),
	"fortress_ram": preload("res://weapons/weapon_fortress_ram.gd"),
}

const ITEM_SCRIPT_BY_ID: Dictionary = {
	"lifesteal": preload("res://items/item_lifesteal.gd"),
	"armor": preload("res://items/item_armor.gd"),
	"crit": preload("res://items/item_crit.gd"),
	"explosion": preload("res://items/item_explosion.gd"),
	"magnet": preload("res://items/item_magnet.gd"),
	"poison": preload("res://items/item_poison.gd"),
	"shield": preload("res://items/item_shield.gd"),
	"speed_charm": preload("res://items/item_speed_charm.gd"),
	"blood_pool": preload("res://items/item_blood_pool.gd"),
	"luck_stone": preload("res://items/item_luck_stone.gd"),
	"turbine": preload("res://items/item_turbine.gd"),
	"steam_armor": preload("res://items/item_steam_armor.gd"),
	"energy_cell": preload("res://items/item_energy_cell.gd"),
	"ember_heart": preload("res://items/item_ember_heart.gd"),
	"glyph_charm": preload("res://items/item_glyph_charm.gd"),
	"resonance_stone": preload("res://items/item_resonance_stone.gd"),
	"rampart_plate": preload("res://items/item_rampart_plate.gd"),
	"iron_bulwark": preload("res://items/item_iron_bulwark.gd"),
}


static func create_weapon(type_id: String) -> Node:
	var scr: Variant = WEAPON_SCRIPT_BY_ID.get(type_id)
	if scr == null:
		return null
	return scr.new() as Node


static func create_item(type_id: String) -> Node:
	var scr: Variant = ITEM_SCRIPT_BY_ID.get(type_id)
	if scr == null:
		return null
	return scr.new() as Node
