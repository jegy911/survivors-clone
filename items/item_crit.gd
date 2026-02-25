class_name ItemCrit
extends PassiveItem

var crit_chance = 0.0
var crit_multiplier = 2.0

func _ready():
	item_name = "Kritik Vuruş"
	description = "Şans ile 2x hasar"
	category = "attack"
	max_level = 5
	super._ready()

func apply():
	crit_chance = 0.1 * level

func get_description() -> String:
	return "Kritik Lv" + str(level) + " | %" + str(int(crit_chance * 100)) + " crit"
