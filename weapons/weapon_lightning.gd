class_name WeaponLightning
extends WeaponBase

const LIGHTNING_BOLT_SCENE := "res://projectiles/lightning_bolt.tscn"
## Oyuncu çevresinde görünür vuruş (main.MAX_PLAYER_DISTANCE ile aynı tavan).
const STRIKE_MAX_DIST_FROM_PLAYER := 600.0

var chain_count = 2
var chain_range = 200.0
var _striking: bool = false


func _ready() -> void:
	super._ready()
	weapon_name = "Yıldırım"
	tag = "patlayici"
	category = "attack"
	damage = 20
	cooldown = 2.2


func attack() -> void:
	if _striking:
		return
	if _enemies_in_strike_radius().is_empty():
		return
	_striking = true
	await _run_lightning_strikes()
	_striking = false


func _alive_enemies() -> Array:
	var out: Array = []
	for e in EnemyRegistry.get_enemies():
		if is_instance_valid(e):
			out.append(e)
	return out


func _in_strike_radius_from_player(enemy: Node2D) -> bool:
	return player.global_position.distance_to(enemy.global_position) <= STRIKE_MAX_DIST_FROM_PLAYER


func _enemies_in_strike_radius() -> Array:
	var out: Array = []
	for e in _alive_enemies():
		if e is Node2D and _in_strike_radius_from_player(e as Node2D):
			out.append(e)
	return out


func _run_lightning_strikes() -> void:
	var hit_enemies: Array = []
	var origin: Vector2 = player.global_position
	var pool0 := _enemies_in_strike_radius()
	if pool0.is_empty():
		return
	var current = pool0[randi() % pool0.size()]
	var effective_chain: int = chain_count + get_effective_multi_attack()
	var effective_range: float = chain_range * player.get_area_multiplier()

	for _i in effective_chain:
		if not is_instance_valid(current) or current in hit_enemies:
			break

		var strike_origin: Vector2 = origin
		var target_pos: Vector2 = current.global_position
		var final_damage: int = player.get_total_damage(damage)
		var bolt: Node = ObjectPool.get_object(LIGHTNING_BOLT_SCENE)
		if bolt.has_method("init"):
			bolt.call("init", strike_origin, current, final_damage, player, &"lightning")
		if bolt.has_signal("strike_finished"):
			await bolt.strike_finished

		hit_enemies.append(current)
		if is_instance_valid(current):
			origin = current.global_position
		else:
			origin = target_pos

		var next = null
		var nearest_dist: float = effective_range
		for enemy in _alive_enemies():
			if enemy in hit_enemies:
				continue
			if not enemy is Node2D or not _in_strike_radius_from_player(enemy as Node2D):
				continue
			var dist: float = origin.distance_to(enemy.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				next = enemy
		if next == null:
			break
		current = next


func on_upgrade():
	match level:
		2:
			chain_count = 3
			damage = 25
		3:
			damage = 30
			cooldown = 2.0
			chain_range = 250.0
		4:
			chain_count = 4
			damage = 35
		5:
			chain_count = 5
			damage = 45
			cooldown = 1.8
			chain_range = 300.0


func get_description() -> String:
	return "Yıldırım Lv" + str(level) + " | " + str(chain_count + get_effective_multi_attack()) + " zincir | " + str(damage) + " hasar"
