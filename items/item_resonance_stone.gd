class_name ItemResonanceStone
extends PassiveItem

## `player.get_magnet_bonus()` toplar.
var pickup_bonus = 25

func _ready():
	item_name = "Rezonans Taşı"
	description = "XP ve altın çekim yarıçapını artırır"
	category = "utility"
	max_level = 5
	super._ready()

func apply():
	pickup_bonus = 22 + level * 10

func get_pickup_bonus() -> float:
	return float(pickup_bonus)

func get_description() -> String:
	return "Rezonans Taşı Lv" + str(level) + "\n+" + str(pickup_bonus) + " çekim yarıçapı"
