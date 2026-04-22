class_name WeaponBase
extends Area2D

## Düşman yokken `attack()` atlanır; tam cooldown yerine kısa aralıkla yeniden kontrol.
const NO_TARGET_RECHECK_SEC: float = 0.12
## Genel ateş sıklığı — bekleme süresi çarpılır (~%38; hedef bant %25–50 yavaşlama).
const GLOBAL_COOLDOWN_SCALE: float = 1.38

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
		if has_targets_for_attack():
			timer = get_effective_cooldown()
			attack()
		else:
			timer = NO_TARGET_RECHECK_SEC

func get_effective_cooldown() -> float:
	if player == null:
		return max(0.15, cooldown * GLOBAL_COOLDOWN_SCALE)
	var multiplier = player.get_cooldown_multiplier()
	return max(0.15, cooldown * multiplier * GLOBAL_COOLDOWN_SCALE)

func has_targets_for_attack() -> bool:
	return true

func _any_enemy_within_distance(max_dist: float) -> bool:
	if player == null or max_dist <= 0.0:
		return false
	var lim2: float = max_dist * max_dist
	var ppos: Vector2 = player.global_position
	for e in EnemyRegistry.get_enemies():
		if is_instance_valid(e) and e is Node2D:
			if ppos.distance_squared_to((e as Node2D).global_position) <= lim2:
				return true
	return false

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
