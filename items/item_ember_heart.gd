class_name ItemEmberHeart
extends PassiveItem

var heal_per_kill = 1

func _ready():
	item_name = "Kor Kalbi"
	description = "Düşman öldürünce küçük can yenilemesi"
	category = "vampire"
	max_level = 5
	super._ready()

func apply():
	var raw: float = 0.2 + 0.2 * float(level)
	heal_per_kill = maxi(1, int(ceil(raw)))

func on_enemy_killed(_position: Vector2):
	if player:
		player.heal(heal_per_kill)

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.ember_heart") % [level, heal_per_kill]
