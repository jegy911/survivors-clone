class_name ItemArmor
extends PassiveItem

var armor_value = 0.0

func _ready():
	item_name = "Zırh"
	description = "Alınan hasarı azaltır"
	category = "defense"
	max_level = 5
	super._ready()

func apply():
	armor_value = 1.5 * level

func get_description() -> String:
	return "Zırh Lv" + str(level) + " | -" + str(snappedf(armor_value, 0.1)) + " hasar"
