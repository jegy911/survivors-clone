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
	crit_bonus = 0.05 + (level - 1) * 0.03
	gold_bonus = 1 + (level - 1)

func get_crit_bonus() -> float:
	return crit_bonus

func get_description() -> String:
	return "Şans Taşı Lv" + str(level) + "\n+%" + str(int(crit_bonus * 100)) + " kritik | +" + str(gold_bonus) + " altın/öldürme"
