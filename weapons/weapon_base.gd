class_name WeaponBase
extends Area2D

var damage = 10
var cooldown = 1.0
var timer = 0.0
var player = null
var level = 1
var max_level = 5
var weapon_name = "Silah"
var category = "attack"
var tag = "none"

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	player = get_parent()

func _process(delta):
	timer -= delta
	if timer <= 0:
		# Cooldown bonusunu uygula
		timer = get_effective_cooldown()
		attack()

func get_effective_cooldown() -> float:
	if player == null:
		return cooldown
	var multiplier = player.get_cooldown_multiplier()
	return max(0.15, cooldown * multiplier)

func get_effective_multi_attack() -> int:
	if player == null:
		return 0
	return player.get_multi_attack_bonus()

func attack():
	pass

func upgrade():
	if level >= max_level:
		return false
	level += 1
	on_upgrade()
	return true

func on_upgrade():
	pass

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.weapon_fallback_line") % [weapon_name, level]
