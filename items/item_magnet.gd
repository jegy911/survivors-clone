class_name ItemMagnet
extends PassiveItem

func _ready():
	item_name = "Mıknatıs"
	description = "XP orb çekim menzili artar"
	category = "utility"
	max_level = 5
	super._ready()

func apply():
	pass

func get_bonus_radius() -> float:
	return 80.0 * level

func get_description() -> String:
	return "Mıknatıs Lv" + str(level) + " | +" + str(int(get_bonus_radius())) + " çekim"
