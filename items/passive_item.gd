class_name PassiveItem
extends Node

var item_name = "Pasif Eşya"
var description = ""
var level = 1
var max_level = 5
var category = "attack"
var player = null

func _ready():
	player = get_parent()
	apply()
	if has_method("on_damage_dealt"):
		EventBus.on_damage_dealt.connect(Callable(self, "on_damage_dealt"))
	call_deferred("_deferred_init")

func _deferred_init():
	if player and player.has_method("recalculate_category_bonus"):
		player.recalculate_category_bonus()

func apply():
	pass

func upgrade():
	if level >= max_level:
		return false
	level += 1
	apply()
	if player and player.has_method("recalculate_category_bonus"):
		player.recalculate_category_bonus()
	return true

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.generic_level") % [item_name, level]
