class_name ItemTurbine
extends PassiveItem

var damage_bonus = 0
var last_position = Vector2.ZERO
var move_timer = 0.0

func _ready():
	item_name = "Türbin"
	description = "Hareket hızın yükseldikçe hasar artar"
	category = "utility"
	max_level = 5
	super._ready()

func apply():
	pass

func _process(delta):
	if player == null:
		return
	var moved = player.global_position.distance_to(last_position)
	last_position = player.global_position
	if moved > 3.0:
		move_timer = min(move_timer + delta, 3.0)
	else:
		move_timer = max(move_timer - delta * 2.0, 0.0)
	var max_bonus = 3 + (level - 1) * 3
	var new_bonus = int((move_timer / 3.0) * max_bonus)
	if new_bonus != damage_bonus:
		damage_bonus = new_bonus

func get_damage_bonus() -> int:
	return damage_bonus

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.turbine") % [
		level,
		damage_bonus,
		3 + (level - 1) * 3,
	]
