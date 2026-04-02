extends Area2D

var speed = 400.0
var direction = Vector2.ZERO
var damage = 10
var lifetime = 2.0
var armor_piercing = false
var player = null
var _hit = false
var pierce_count = 0
var _pierce_remaining = 0

func _on_area_entered(area: Area2D):
	if _hit:
		return
	if not area.has_method("take_damage"):
		return
	if area.is_in_group("player"):
		return
	area.take_damage(damage, player if is_instance_valid(player) else null)
	if is_instance_valid(player):
		EventBus.on_damage_dealt.emit(player, area, damage)
	if _pierce_remaining > 0:
		_pierce_remaining -= 1
		return
	_hit = true
	if is_instance_valid(player) and player.get("bounce_timer") != null and player.bounce_timer > 0:
		var enemies = get_tree().get_nodes_in_group("enemies")
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

func init(dir: Vector2, dmg: int = 10, is_armor_piercing: bool = false, shooter = null):
	_hit = false
	_pierce_remaining = pierce_count
	direction = dir
	damage = dmg
	armor_piercing = is_armor_piercing
	player = shooter
	lifetime = 2.0
	add_to_group("player_bullets")
	if get_node_or_null("Sprite2D"):
		$Sprite2D.rotation = direction.angle()
	show()

func reset():
	_hit = false
	direction = Vector2.ZERO
	damage = 10
	lifetime = 2.0
	armor_piercing = false
	remove_from_group("player_bullets")
	hide()
