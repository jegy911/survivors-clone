class_name ItemLifesteal
extends "res://items/passive_item.gd"

var steal_percent = 0.05

func _ready():
	item_name = "Can Çalma"
	description = "Verilen hasarın bir kısmı kadar can kazan (her vuruşta)"
	category = "vampire"
	max_level = 5
	super._ready()

func apply():
	steal_percent = 0.01 * level

func on_damage_dealt(_player: Node, _enemy: Node, damage: int):
	var heal_amount = int(damage * steal_percent)
	if heal_amount > 0 and player:
		player.heal(heal_amount)

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.lifesteal") % [level, int(steal_percent * 100)]
