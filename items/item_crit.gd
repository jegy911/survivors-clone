class_name ItemCrit
extends PassiveItem

var crit_chance = 0.0
var crit_multiplier = 1.5

func _ready():
	item_name = "Kritik Vuruş"
	description = "Şans ile 1.5× hasar"
	category = "attack"
	max_level = 5
	super._ready()

func apply():
	crit_chance = 0.04 * level

func get_description() -> String:
	return "Kritik Lv" + str(level) + " | %" + str(int(crit_chance * 100)) + " crit"
