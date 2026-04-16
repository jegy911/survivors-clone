class_name ItemVampire
extends PassiveItem

var heal_per_kill = 0

func _ready():
	item_name = "Vampir"
	description = "Her öldürmede sabit can kazan"
	category = "vampire"
	max_level = 5
	super._ready()

func apply():
	heal_per_kill = 2 * level

func on_enemy_killed(_position: Vector2):
	if player:
		player.heal(heal_per_kill)

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.vampire") % [level, heal_per_kill]
