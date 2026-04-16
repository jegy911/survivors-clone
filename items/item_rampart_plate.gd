class_name ItemRampartPlate
extends PassiveItem

var armor_value = 0.0

func _ready():
	item_name = "Rampa Plakası"
	description = "Ön hat için ekstra zırh levhaları"
	category = "defense"
	max_level = 5
	super._ready()

func apply():
	armor_value = 1.0 + (level - 1) * 1.5

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.rampart_plate") % [level, snappedf(armor_value, 0.1)]
