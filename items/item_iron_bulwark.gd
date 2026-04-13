class_name ItemIronBulwark
extends PassiveItem

var armor_value = 0

func _ready():
	item_name = "Demir Siper"
	description = "Kalın demir siper; düz hasarı keser"
	category = "defense"
	max_level = 5
	super._ready()

func apply():
	armor_value = 2 * level

func get_description() -> String:
	return "Demir Siper Lv" + str(level) + " | -" + str(armor_value) + " hasar"
