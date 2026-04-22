class_name EnemyBase
extends Area2D

# Temel istatistikler
var BASE_SPEED = 50.0
var DAMAGE = 10
var XP_VALUE = 5
var XP_DROP_CHANCE = 0.28
## Ölüm başına varsayılan en fazla 1 loot türü; çift düşme bu olasılıkla (~%1).
const DEATH_LOOT_DOUBLE_CHANCE: float = 0.01
## Özel eşya (kan antlaşması / dişli / buhar-zaman) toplam ağırlığı — eski bağımsız üst sınır ile uyumlu.
const DEATH_LOOT_SPECIAL_WEIGHT: float = 0.037
const DEATH_LOOT_NONE_WEIGHT_NORMAL: float = 0.40
const DEATH_LOOT_NONE_WEIGHT_ELITE: float = 0.06
var gold_value = 1
var elite_gold_value = 2
var death_scale = 1.4
var particle_color = Color("#E74C3C")
var damage_color = Color.WHITE

# Durum
var player: Node2D = null
var damage_cooldown = 0.0
var hp = 30
var max_hp = 30
var is_dead = false
var current_speed = BASE_SPEED
var slow_timer = 0.0
var rage_triggered = false
var is_swarm_enemy: bool = false
var swarm_direction: Vector2 = Vector2.ZERO
var swarm_speed_override: float = 180.0
var _poison_damage = 0
var _poison_timer = 0.0
var _poison_tick_interval = 1.0
var _contrast_outline_sprite: AnimatedSprite2D = null


@onready var body = $ColorRect

func _ready():
	add_to_group("enemies")
	EnemyRegistry.register_enemy(self)
	if not tree_exiting.is_connected(_on_tree_exiting_unregister):
		tree_exiting.connect(_on_tree_exiting_unregister)
	_setup_hp_bar()
	_setup_visuals()


func _on_tree_exiting_unregister() -> void:
	EnemyRegistry.unregister_enemy(self)

func _setup_hp_bar():
	var hp_setting = SaveManager.settings.get("hp_bars", "both_on")
	if hp_setting == "both_off" or hp_setting == "player_only":
		return
	var body_size = body.size if body else Vector2(32, 32)
	var bar_x = -body_size.x / 2
	var bar_y = -body_size.y / 2 - 8
	var bar_width = body_size.x
	var bar_bg = ColorRect.new()
	bar_bg.name = "HPBarBG"
	bar_bg.size = Vector2(bar_width, 4)
	bar_bg.position = Vector2(bar_x, bar_y)
	bar_bg.color = Color("#333333")
	add_child(bar_bg)
	var bar_fill = ColorRect.new()
	bar_fill.name = "HPBarFill"
	bar_fill.size = Vector2(bar_width, 4)
	bar_fill.position = Vector2(bar_x, bar_y)
	bar_fill.color = Color("#E74C3C")
	add_child(bar_fill)

func _update_hp_bar():
	var fill = get_node_or_null("HPBarFill")
	if fill:
		var full_width = body.size.x if body else 32.0
		fill.size.x = full_width * (float(hp) / float(max_hp))

func take_damage(amount: int, shooter: Node = null):
	if shooter != null:
		set_meta("killer", shooter)
	if is_dead:
		return
	# Bağışıklık kontrolü
	var immunity = get_meta("immunity", "")
	if immunity != "":
		amount = int(amount * 0.5)
		player = _get_nearest_player()
	hp -= amount
	# Öfke modu — HP %30'a düşünce
	var main = get_tree().get_first_node_in_group("main")
	var rage_after: float = SaveManager.get_immunity_phase_start_sec()
	if not rage_triggered and float(hp) / float(max_hp) <= 0.30 and main and main.game_timer >= rage_after:
		rage_triggered = true
		BASE_SPEED *= 1.5
		current_speed = BASE_SPEED
		damage_color = Color("#FF6600")
		if body:
			var rage_tween = body.create_tween()
			rage_tween.set_loops(3)
			rage_tween.tween_property(body, "modulate:a", 0.3, 0.1)
			rage_tween.tween_property(body, "modulate:a", 1.0, 0.1)
	_update_hp_bar()
	
	var dmg_setting = SaveManager.settings.get("damage_numbers", "both_on")
	if dmg_setting == "both_on" or dmg_setting == "enemy_only":
		var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
		popup.global_position = global_position + Vector2(0, -50)
		popup.show_damage(amount, damage_color)
	
	AudioManager.play_hit()
	flash()
	if hp <= 0:
		die()
	# Vuruş geri tepme efekti
	if player != null:
		var knockback_dir = (global_position - player.global_position).normalized()
		global_position += knockback_dir * 4.0

func take_explosion_damage(amount: int):
	if is_dead:
		return
	hp -= amount
	if hp <= 0:
		call_deferred("die")

func apply_slow(factor: float, duration: float):
	current_speed = BASE_SPEED * factor
	slow_timer = duration
	if body:
		body.color = Color("#3498DB")

func apply_poison(damage_per_tick: int, duration: float):
	_poison_damage = damage_per_tick
	_poison_timer = duration
	_poison_tick_interval = 1.0

func flash():
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		var tween = sprite.create_tween()
		tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.04)
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.08)
	elif body:
		var tween = body.create_tween()
		tween.tween_property(body, "color", Color.WHITE, 0.04)
		tween.tween_property(body, "color", _get_original_color(), 0.08)

func _get_original_color() -> Color:
	return body.color if body else Color.WHITE


func _notify_enemy_kill_to_player(explicit_killer: Node = null) -> void:
	var killer_player: Node = explicit_killer
	if killer_player == null and has_meta("killer"):
		killer_player = get_meta("killer")
	if killer_player == null:
		killer_player = _get_nearest_player()
	if killer_player != null and killer_player.has_method("on_enemy_killed"):
		killer_player.on_enemy_killed(global_position)


func die(killer: Node = null):
	if is_dead:
		return
	is_dead = true
	# Kill sayısı hemen (tween / hit-stop beklenmez); HUD ve eşya tetikleri anında güncellenir.
	_notify_enemy_kill_to_player(killer)
	AudioManager.play_death()
# Ateş sinerjisi — evrimi olan silahlar varsa %10 patlama
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var evolved = ["holy_bullet", "toxic_chain", "death_laser", "blood_boomerang", "storm", "binding_circle", "void_lens", "citadel_flail", "fortress_ram", "veil_daggers"]
		var evolved_count = 0
		for e in evolved:
			if player_node.active_weapons.has(e):
				evolved_count += 1
		if evolved_count >= 2 and randf() < 0.10:
			var explosion_range = 100.0
			var enemies = EnemyRegistry.get_enemies()
			for enemy in enemies:
				if enemy == self:
					continue
				if enemy.global_position.distance_to(global_position) < explosion_range:
					enemy.take_damage(int(player_node.get_total_damage(20)))
			if SaveManager.is_heavy_vfx_enabled():
				var fire_flash = ColorRect.new()
				fire_flash.size = Vector2(200, 200)
				fire_flash.color = Color("#FF4500")
				fire_flash.modulate.a = 0.5
				fire_flash.position = global_position - Vector2(100, 100)
				get_parent().add_child(fire_flash)
				var fire_tween = fire_flash.create_tween()
				fire_tween.tween_property(fire_flash, "modulate:a", 0.0, 0.3)
				fire_tween.tween_callback(fire_flash.queue_free)
	if SaveManager.is_heavy_vfx_enabled():
		_spawn_particles()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(death_scale, death_scale), 0.08)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.12)
	tween.tween_callback(_on_death_complete)

func _any_player_can_pickup_cog() -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	for p in tree.get_nodes_in_group("player"):
		if p.has_method("can_collect_more_cog_shards") and p.can_collect_more_cog_shards():
			return true
	return false


## Ölüm sonunda tek yerden çağrılır: aynı anda birden çok bağımsız düşürme yok (en fazla 1 + ~%1 ile 2).
func resolve_death_loot() -> void:
	var max_picks: int = 2 if randf() < DEATH_LOOT_DOUBLE_CHANCE else 1
	var used: Dictionary = {}
	for _i in max_picks:
		var kind: String = _pick_death_loot_kind(used)
		if kind.is_empty() or kind == "none":
			continue
		used[kind] = true
		match kind:
			"xp":
				_spawn_xp_orb_drop()
			"gold":
				_spawn_gold_orb_drop()
			"chest":
				_spawn_chest_drop()
			"special":
				_spawn_special_pickup_drop()


func _pick_death_loot_kind(used: Dictionary) -> String:
	var w_xp: float = 0.0
	if not used.has("xp"):
		w_xp = XP_DROP_CHANCE
	var w_gold: float = 0.0
	if not used.has("gold"):
		w_gold = 1.0 if get_meta("is_elite", false) else 0.12
	var w_chest: float = 0.0
	if not used.has("chest"):
		w_chest = 0.20 if get_meta("is_elite", false) else 0.01
	var w_special: float = 0.0
	if not used.has("special"):
		w_special = DEATH_LOOT_SPECIAL_WEIGHT
	var w_none: float = DEATH_LOOT_NONE_WEIGHT_ELITE if get_meta("is_elite", false) else DEATH_LOOT_NONE_WEIGHT_NORMAL
	var sum: float = w_xp + w_gold + w_chest + w_special + w_none
	if sum <= 0.0:
		return "none"
	var r: float = randf() * sum
	if r < w_none:
		return "none"
	r -= w_none
	if r < w_xp:
		return "xp"
	r -= w_xp
	if r < w_gold:
		return "gold"
	r -= w_gold
	if r < w_chest:
		return "chest"
	r -= w_chest
	if r < w_special:
		return "special"
	return "none"


func _spawn_special_pickup_drop() -> void:
	var roll = randf()
	if roll < 0.005:
		var oath = load("res://effects/blood_oath.tscn").instantiate()
		get_parent().add_child(oath)
		oath.init(global_position)
	elif roll < 0.025:
		if _any_player_can_pickup_cog():
			var shard = load("res://effects/cog_shard.tscn").instantiate()
			get_parent().add_child(shard)
			shard.init(global_position)
	elif roll < 0.037:
		var pickup
		if randf() < 0.5:
			pickup = load("res://effects/steam_bomb.tscn").instantiate()
		else:
			pickup = load("res://effects/time_gear.tscn").instantiate()
		get_parent().add_child(pickup)
		pickup.init(global_position)


func _spawn_chest_drop() -> void:
	var chest = load("res://effects/chest.tscn").instantiate()
	get_parent().add_child(chest)
	chest.init(global_position)


func _spawn_gold_orb_drop() -> void:
	var orb = ObjectPool.get_object("res://effects/gold_orb.tscn")
	var v = gold_value
	if get_meta("is_elite", false):
		v = elite_gold_value
	var player_node = _get_nearest_player()
	if player_node:
		if player_node.active_items.has("luck_stone"):
			v += player_node.active_items["luck_stone"].gold_bonus
		var gold_meta_bonus = SaveManager.meta_upgrades.get("gold_bonus", 0)
		v += gold_meta_bonus
	orb.init(v, global_position)


func _spawn_xp_orb_drop() -> void:
	var roll = randf()
	var xp_val = XP_VALUE
	var orb_color = Color("#4A90E2")
	if roll < 0.02:
		xp_val = XP_VALUE * 8
		orb_color = Color("#E74C3C")
	elif roll < 0.10:
		xp_val = XP_VALUE * 3
		orb_color = Color("#2ECC71")
	orb_color = SaveManager.filter_accessibility_orb_color(orb_color)
	var orb = ObjectPool.get_object("res://effects/xp_orb.tscn")
	orb.init(xp_val, global_position)
	if orb.get_node_or_null("ColorRect"):
		orb.get_node("ColorRect").color = orb_color

func _spawn_particles():
	var n: int = SaveManager.get_particle_burst_count(6)
	for i in n:
		var particle = ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = particle_color
		particle.position = global_position
		get_parent().add_child(particle)
		var angle = (float(i) / float(n)) * TAU
		var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(30, 60)
		var tween = particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)

func get_codex_id() -> String:
	if has_meta("codex_id"):
		return str(get_meta("codex_id"))
	var p = scene_file_path
	if p.is_empty():
		return ""
	var base = p.get_file().get_basename()
	if base == "boss":
		return "mini_boss"
	return base


func _on_death_complete():
	SaveManager.register_codex_discovered(get_codex_id())
	resolve_death_loot()
	queue_free()


func _physics_process(delta):
	if _contrast_outline_sprite != null:
		var sp = get_node_or_null("AnimatedSprite2D")
		if sp == null or not is_instance_valid(_contrast_outline_sprite):
			_contrast_outline_sprite = null
		else:
			if _contrast_outline_sprite.animation != sp.animation:
				_contrast_outline_sprite.play(sp.animation)
			_contrast_outline_sprite.frame = sp.frame
			_contrast_outline_sprite.frame_progress = sp.frame_progress
			_contrast_outline_sprite.speed_scale = sp.speed_scale
			_contrast_outline_sprite.flip_h = sp.flip_h
	if _poison_timer > 0:
		_poison_timer -= delta
		_poison_tick_interval -= delta
		if _poison_tick_interval <= 0:
			_poison_tick_interval = 1.0
			if not is_dead:
				take_damage(_poison_damage)

	if is_swarm_enemy and not is_dead:
		global_position += swarm_direction * swarm_speed_override * delta
		_update_swarm_facing()
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			var center = Vector2.ZERO
			for p in players:
				center += p.global_position
			center /= players.size()
			if global_position.distance_to(center) > 1400:
				is_dead = true
				queue_free()

func _setup_visuals():
	if body:
		body.name = "Body"
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.play("walk_left")
	if SaveManager.settings.get("enemy_high_contrast_outline", false):
		_try_add_high_contrast_outline(sprite)


func _try_add_high_contrast_outline(vis_sprite: Node) -> void:
	if get_node_or_null("HighContrastOutline") != null:
		return
	var sprite = vis_sprite as AnimatedSprite2D
	if sprite != null and sprite.visible:
		var ol = sprite.duplicate() as AnimatedSprite2D
		ol.name = "HighContrastOutline"
		ol.modulate = Color(1.0, 0.92, 0.0, 0.95)
		ol.z_index = sprite.z_index - 1
		ol.scale = sprite.scale * 1.08
		add_child(ol)
		move_child(ol, sprite.get_index())
		_contrast_outline_sprite = ol
	elif body != null and body.visible:
		var sz = body.size
		var pos = body.position
		var off = 3.0
		var dirs: Array[Vector2] = [
			Vector2(off, 0), Vector2(-off, 0), Vector2(0, off), Vector2(0, -off),
		]
		for i in dirs.size():
			var r = ColorRect.new()
			r.name = "HighContrastOutlineRect_%d" % i
			r.size = sz
			r.position = pos + dirs[i]
			r.color = Color(1.0, 1.0, 0.0, 1.0)
			r.z_index = body.z_index - 1
			add_child(r)
			move_child(r, body.get_index())

func _update_animation(is_moving: bool):
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		return
	if is_moving:
		if sprite.sprite_frames.has_animation("walk_left"):
			sprite.play("walk_left")
	else:
		if sprite.sprite_frames.has_animation("idle_left"):
			sprite.play("idle_left")
		elif sprite.sprite_frames.has_animation("walk_left"):
			sprite.play("walk_left")

func _update_enemy_direction():
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null or player == null:
		return
	if player.global_position.x > global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


## Sürü olayı: oyuncuya değil **yürüyüş vektörüne** göre bakış (walk_left + flip_h = sağa).
func _update_swarm_facing() -> void:
	var sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		return
	if absf(swarm_direction.x) > 0.05:
		sprite.flip_h = swarm_direction.x > 0.0

func _get_nearest_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var nearest = players[0]
	var nearest_dist = global_position.distance_to(nearest.global_position)
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	return nearest

func make_swarm_enemy(direction: Vector2, speed: float = 180.0):
	is_swarm_enemy = true
	swarm_direction = direction.normalized()
	swarm_speed_override = speed
	set_process(false)
