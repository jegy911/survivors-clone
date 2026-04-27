extends Area2D

const BULLET_COLLISION_LAYER: int = 4
const BULLET_COLLISION_MASK: int = 2

var speed = 400.0
var direction = Vector2.ZERO
var damage = 10
var lifetime = 2.0
var armor_piercing = false
var player = null
var _hit = false
var pierce_count = 0
var _pierce_remaining = 0
var _default_bullet_texture: Texture2D
var _was_crit_roll: bool = false

func _ready():
	$ColorRect.color = Color("#FFD700")
	var spr0 := get_node_or_null("Sprite2D") as Sprite2D
	if spr0:
		$ColorRect.visible = false
		if spr0.texture != null:
			_default_bullet_texture = spr0.texture
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if _hit:
		return
	if not area.has_method("take_damage"):
		return
	if area.is_in_group("player"):
		return
	var hit_center: Vector2 = area.global_position if area is Node2D else global_position
	if _was_crit_roll:
		EventBus.hit_stop_requested.emit(2)
		var par_hit: Node = get_parent()
		if par_hit:
			CombatProjectileFx.spawn_crit_burst(par_hit, hit_center + Vector2(0, -28), player as Node2D)
		if is_instance_valid(player):
			player.show_floating_text(tr("ui.player.crit_floating"), hit_center + Vector2(0, -52), Color("#FFD700"), 24)
		_was_crit_roll = false
	area.take_damage(damage, player if is_instance_valid(player) else null)
	if armor_piercing:
		var par_hit: Node = get_parent()
		if par_hit:
			CombatProjectileFx.spawn_hit_sparks(par_hit, area.global_position, player, Color("#FFF2A0"), 10, 40.0, 0.2)
	if is_instance_valid(player):
		EventBus.on_damage_dealt.emit(player, area, damage)
	if _pierce_remaining > 0:
		_pierce_remaining -= 1
		return
	_hit = true
	# Aynı fizik karesinde bitişik iki düşman alanına çarpınca çift vuruş olmasın diye taramayı kapat
	_disable_hit_scan()
	if is_instance_valid(player) and player.get("bounce_timer") != null and player.bounce_timer > 0:
		var enemies = EnemyRegistry.get_enemies()
		var next = null
		var best_dist = 999999.0
		for e in enemies:
			if e == area:
				continue
			var d = global_position.distance_to(e.global_position)
			if d < best_dist:
				best_dist = d
				next = e
		if next and best_dist < 300:
			_hit = false
			_restore_hit_scan()
			direction = (next.global_position - global_position).normalized()
			lifetime = 0.8
			return
	ObjectPool.return_object(self)

func _physics_process(delta):
	if not visible:
		return
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		ObjectPool.return_object(self)

func _disable_hit_scan() -> void:
	collision_layer = 0
	collision_mask = 0

func _restore_hit_scan() -> void:
	collision_layer = BULLET_COLLISION_LAYER
	collision_mask = BULLET_COLLISION_MASK

func init(dir: Vector2, dmg: int = 10, is_armor_piercing: bool = false, shooter = null, projectile_texture: Texture2D = null, crit_roll: bool = false):
	_hit = false
	_was_crit_roll = crit_roll
	_pierce_remaining = pierce_count
	_restore_hit_scan()
	direction = dir
	damage = dmg
	armor_piercing = is_armor_piercing
	player = shooter
	lifetime = 2.0
	var vfx_a = 1.0
	if shooter and shooter.has_method("get_player_vfx_opacity"):
		vfx_a = shooter.get_player_vfx_opacity()
	var cr = get_node_or_null("ColorRect")
	if cr:
		cr.modulate.a = vfx_a
	var spr = get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		if projectile_texture != null:
			spr.texture = projectile_texture
			if cr:
				cr.visible = false
		else:
			if _default_bullet_texture != null:
				spr.texture = _default_bullet_texture
			if cr:
				cr.visible = spr.texture == null
		spr.modulate.a = vfx_a
	add_to_group("player_bullets")
	if spr:
		spr.rotation = direction.angle()
	show()

func reset():
	_hit = false
	_was_crit_roll = false
	pierce_count = 0
	direction = Vector2.ZERO
	damage = 10
	lifetime = 2.0
	armor_piercing = false
	var cr = get_node_or_null("ColorRect")
	if cr:
		cr.modulate.a = 1.0
	var spr = get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		if _default_bullet_texture != null:
			spr.texture = _default_bullet_texture
		spr.modulate.a = 1.0
	if cr and spr:
		cr.visible = spr.texture == null
	elif cr:
		cr.visible = true
	remove_from_group("player_bullets")
	hide()
	# Havuzda gizliyken çarpışma kapalı olmalı; aksi halde `area_entered` görünmez mermiyle hasar verir.
	_disable_hit_scan()
