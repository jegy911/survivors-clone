class_name ItemArmor
extends PassiveItem

var armor_value = 0

func _ready():
	item_name = "Zırh"
	description = "Alınan hasarı azaltır"
	category = "defense"
	max_level = 5
	super._ready()

func apply():
	armor_value = 2 * level

func get_description() -> String:
	return "Zırh Lv" + str(level) + " | -" + str(armor_value) + " hasar"
