class_name WeaponStorm
extends WeaponBase

var chain_count = 3
var chain_range = 200.0
var kill_lightning_count = 0

func _ready():
	super._ready()
	weapon_name = "Storm"
	tag = "patlayici"
	category = "attack"
	damage = 40
	cooldown = 1.2
	max_level = 5

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	
	var first = enemies[0]
	var final_damage = player.get_total_damage(damage)
	first.take_damage(final_damage)
	EventBus.on_damage_dealt.emit(player, first, final_damage)
	_spawn_flash(first.global_position)
	
	var hit = [first]
	var current = first
	
	for i in chain_count - 1:
		var next = _find_next(current, hit)
		if next == null:
			break
		next.take_damage(final_damage)
		EventBus.on_damage_dealt.emit(player, next, final_damage)
		_spawn_flash(next.global_position)
		hit.append(next)
		current = next


func _find_next(current: Node, hit: Array):
	var enemies = EnemyRegistry.get_enemies()
	var nearest = null
	var nearest_dist = chain_range
	for enemy in enemies:
		if enemy in hit:
			continue
		var dist = current.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func _spawn_flash(pos: Vector2):
	var flash = ColorRect.new()
	flash.size = Vector2(14, 14)
	flash.color = Color("#00BFFF")
	flash.position = pos - Vector2(7, 7)
	flash.modulate.a = player.get_player_vfx_opacity() if player else 1.0
	player.get_parent().add_child(flash)
	
	var tween = flash.create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.2)
	tween.tween_callback(flash.queue_free)

func on_upgrade():
	match level:
		2: damage = 48; chain_count = 4
		3: damage = 58; chain_range = 250.0
		4: damage = 70; chain_count = 5
		5: damage = 85; chain_count = 6; chain_range = 300.0

func get_description() -> String:
	return "Storm Lv" + str(level) + " | x" + str(chain_count) + " zincir | " + str(damage) + " hasar"
