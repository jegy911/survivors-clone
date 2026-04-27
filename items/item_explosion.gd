class_name ItemExplosion
extends PassiveItem

var explosion_radius = 0.0
var explosion_damage = 0
var trigger_chance = 0.50
var exploded_positions = []
var damage_number_scene = preload("res://effects/damage_number.tscn")
const EXPLOSION_BURST_TEX := preload("res://assets/effects/explosion_burst.png")

func _ready():
	item_name = "Patlama"
	description = "Düşman ölünce alan hasarı"
	category = "attack"
	max_level = 5
	super._ready()

func apply():
	explosion_radius = 40.0 + (15.0 * level)
	explosion_damage = 8 * level
	trigger_chance = 0.10 + (level - 1) * 0.05

func on_enemy_killed(position: Vector2):
	if randf() >= trigger_chance:
		return
	for pos in exploded_positions:
		if pos.distance_to(position) < 10:
			return
	exploded_positions.append(position)
	call_deferred("_do_explosion", position)
	await get_tree().process_frame
	exploded_positions.erase(position)

func _do_explosion(position: Vector2):
	var effective_radius = explosion_radius * player.get_area_multiplier()
	var par: Node = player.get_parent() if player else null
	if par != null:
		var spr := Sprite2D.new()
		spr.texture = EXPLOSION_BURST_TEX
		spr.centered = true
		spr.global_position = position
		var bd: float = maxf(float(EXPLOSION_BURST_TEX.get_width()), 1.0)
		var sc: float = (effective_radius * 2.0) / bd
		spr.scale = Vector2(sc, sc)
		spr.modulate.a = 0.65
		par.add_child(spr)
		var ftw := spr.create_tween()
		ftw.parallel().tween_property(spr, "modulate:a", 0.0, 0.38)
		ftw.tween_callback(spr.queue_free)
	var enemies = EnemyRegistry.get_enemies()
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(position) <= effective_radius:
			if enemy.has_method("take_explosion_damage"):
				enemy.take_explosion_damage(explosion_damage)
	EventBus.hit_stop_requested.emit(2)

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.explosion") % [
		level,
		int(explosion_radius * player.get_area_multiplier()),
		explosion_damage,
	]
