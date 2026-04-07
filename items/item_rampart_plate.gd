class_name ItemRampartPlate
extends PassiveItem

var armor_value = 0

func _ready():
	item_name = "Rampa Plakası"
	description = "Ön hat için ekstra zırh levhaları"
	category = "defense"
	max_level = 5
	super._ready()

func apply():
	armor_value = 2 + (level - 1) * 2

func get_description() -> String:
	return "Rampa Plakası Lv" + str(level) + " | -" + str(armor_value) + " hasar"
