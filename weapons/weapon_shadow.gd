class_name WeaponShadow
extends WeaponBase
var orb_count = 1
var orbit_radius = 80.0
var orbit_speed = 2.0
var orbs = []
var hit_cooldowns = {}
const HIT_INTERVAL = 0.5

## Sahnedeki `OrbSpriteTemplate` — görünmez şablon; her yörünge küresi için duplicate edilir (karakter üstünde değil, etrafta döner).
@onready var _orb_sprite_template: Sprite2D = $OrbSpriteTemplate

func _ready():
	super._ready()
	weapon_name = "Gölge"
	tag = "kesici"
	category = "attack"
	damage = 12
	cooldown = 0.8
	if _orb_sprite_template:
		_orb_sprite_template.visible = false
	call_deferred("_spawn_orbs")

func _spawn_orbs():
	for orb in orbs:
		if is_instance_valid(orb):
			orb.queue_free()
	orbs.clear()
	
	var effective_count = orb_count + get_effective_multi_attack()
	var vfx_a: float = player.get_player_vfx_opacity() if player else 1.0
	for i in effective_count:
		var orb = Node2D.new()
		var visual: CanvasItem
		if _orb_sprite_template:
			visual = _orb_sprite_template.duplicate() as CanvasItem
			visual.visible = true
			visual.modulate.a = vfx_a
		else:
			var cr := ColorRect.new()
			cr.size = Vector2(14, 14)
			cr.color = Color("#9B59B6")
			cr.position = Vector2(-7, -7)
			cr.modulate.a = vfx_a
			visual = cr
		orb.add_child(visual)
		player.get_parent().call_deferred("add_child", orb)
		orbs.append(orb)

func _process(delta):
	super._process(delta)  # attack() buradan çağrılıyor
	if player == null:
		return
	var time = Time.get_ticks_msec() / 1000.0
	# Hit cooldown'ları güncelle
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= delta
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	
	# Her frame düşman kontrolü
	var enemies = EnemyRegistry.get_enemies()
	for orb in orbs:
		if not is_instance_valid(orb):
			continue
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			var enemy_id = enemy.get_instance_id()
			if hit_cooldowns.has(enemy_id):
				continue
			if orb.global_position.distance_to(enemy.global_position) < 35:
				var final_damage = player.get_total_damage(damage)
				enemy.take_damage(final_damage, player)
				EventBus.on_damage_dealt.emit(player, enemy, final_damage)
				hit_cooldowns[enemy_id] = HIT_INTERVAL
	for i in orbs.size():
		if not is_instance_valid(orbs[i]):
			continue
		var angle = time * orbit_speed + (TAU / orbs.size()) * i
		var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
		orbs[i].global_position = player.global_position + offset

				

func on_upgrade():
	match level:
		2:
			damage = 16
			orb_count = 2
			_spawn_orbs()
		3:
			orbit_speed = 2.2
			damage = 20
			cooldown = 0.7
		4:
			orb_count = 3
			damage = 25
			_spawn_orbs()
		5:
			orb_count = 4
			damage = 32
			orbit_speed = 2.5
			orbit_radius = 90.0
			cooldown = 0.6
			_spawn_orbs()

func get_description() -> String:
	return "Gölge Lv" + str(level) + " | " + str(orb_count + get_effective_multi_attack()) + " orb | " + str(damage) + " hasar"

func _exit_tree():
	for orb in orbs:
		if is_instance_valid(orb):
			orb.queue_free()
	orbs.clear()
