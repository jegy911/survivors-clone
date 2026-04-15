class_name ItemNightVial
extends PassiveItem

## `player.get_magnet_bonus()` içinde toplanır — Mıknatıs / Rezonans’tan küçük; tek başına rahat, evrim yolunda `dagger` ile eşlenir.
var pickup_bonus := 6

func _ready() -> void:
	item_name = "Gece Şişesi"
	description = "Hafif çekim yarıçapı"
	category = "utility"
	max_level = 5
	super._ready()

func apply() -> void:
	pickup_bonus = 4 + level * 4

func get_pickup_bonus() -> float:
	return float(pickup_bonus)

func get_description() -> String:
	return "Gece Şişesi Lv" + str(level) + "\n+" + str(pickup_bonus) + " XP/altın çekim yarıçapı"
