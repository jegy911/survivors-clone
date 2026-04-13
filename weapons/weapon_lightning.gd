class_name WeaponLightning
extends WeaponBase

var chain_count = 2
var chain_range = 200.0

func _ready():
	super._ready()
	weapon_name = "Yıldırım"
	tag = "patlayici"
	category = "attack"
	damage = 20
	cooldown = 2.2

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	
	var first = enemies[randi() % enemies.size()]
	var hit_enemies = []
	var current = first
	var effective_chain = chain_count + get_effective_multi_attack()
	var effective_range = chain_range * player.get_area_multiplier()
	
	for i in effective_chain:
		if not is_instance_valid(current):
			break
		
		var final_damage = player.get_total_damage(damage)
		current.take_damage(final_damage)
		EventBus.on_damage_dealt.emit(player, current, final_damage)
		hit_enemies.append(current)
		
		_spawn_lightning(current.global_position)
		
		
		var next = null
		var nearest_dist = effective_range
		for enemy in enemies:
			if enemy in hit_enemies:
				continue
			var dist = current.global_position.distance_to(enemy.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				next = enemy
		
		if next == null:
			break
		current = next

func _spawn_lightning(pos: Vector2):
	var flash = ColorRect.new()
	flash.size = Vector2(12, 12)
	flash.color = Color("#FFD700")
	flash.position = pos - Vector2(6, 6)
	flash.modulate.a = player.get_player_vfx_opacity() if player else 1.0
	player.get_parent().add_child(flash)
	
	var tween = flash.create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.2)
	tween.tween_callback(flash.queue_free)

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
