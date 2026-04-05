class_name ItemEmberHeart
extends PassiveItem

var heal_per_kill = 2

func _ready():
	item_name = "Kor Kalbi"
	description = "Düşman öldürünce küçük can yenilemesi"
	category = "vampire"
	max_level = 5
	super._ready()

func apply():
	heal_per_kill = 1 + level

func on_enemy_killed(_position: Vector2):
	if player:
		player.heal(heal_per_kill)

func get_description() -> String:
	return "Kor Kalbi Lv" + str(level) + "\nÖldürünce +" + str(heal_per_kill) + " can"
