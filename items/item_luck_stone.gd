class_name ItemLuckStone
extends PassiveItem

var crit_bonus = 0.05
var gold_bonus = 1

func _ready():
	item_name = "Şans Taşı"
	description = "Kritik şansı ve altın bonusu"
	category = "utility"
	max_level = 5
	super._ready()

func apply():
	crit_bonus = 0.02 + (level - 1) * 0.015
	gold_bonus = int(round(1.0 + 0.5 * (level - 1)))

func get_crit_bonus() -> float:
	return crit_bonus

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.luck_stone") % [
		level,
		int(crit_bonus * 100),
		gold_bonus,
	]
