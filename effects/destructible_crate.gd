extends Node2D

const CRATE_TEX_LOW := preload("res://assets/effects/destructible_crate_low.png")
const CRATE_TEX_HIGH := preload("res://assets/effects/destructible_crate_high.png")

var hp = 3
var body_visual: CanvasItem
var powerups = ["bounce", "speed", "damage", "heal"]
var reward_tier := "low"

func _ready():
	add_to_group("env_objects")
	_setup_visual()

func _process(_delta):
	if hp <= 0:
		return
	var bullets = get_tree().get_nodes_in_group("player_bullets")
	for b in bullets:
		if global_position.distance_to(b.global_position) < 20:
			_hit()
			return

func _hit():
	hp -= 1
	if body_visual != null:
		var tween = body_visual.create_tween()
		tween.tween_property(body_visual, "modulate:a", 0.3, 0.05)
		tween.tween_property(body_visual, "modulate:a", 1.0, 0.05)
	if hp <= 0:
		_break()

func _break():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		powerups.shuffle()
		# High crate: daha güçlü ödül havuzu ve daha yüksek heal.
		var chosen = powerups[0] if reward_tier != "high" else powerups[randi() % powerups.size()]
		match chosen:
			"bounce":
				player.bounce_timer = 8.0 if reward_tier == "high" else 5.0
				player.show_floating_text("⚡ BOUNCE BULLET! 5sn", global_position + Vector2(0, -40), Color("#FFD700"), 16)
			"speed":
				var speed_bonus := 45 if reward_tier == "high" else 30
				var speed_sec := 8.0 if reward_tier == "high" else 5.0
				player.SPEED += speed_bonus
				await get_tree().create_timer(speed_sec).timeout
				if is_instance_valid(player):
					player.SPEED -= speed_bonus
				player.show_floating_text("💨 HIZ! 5sn", global_position + Vector2(0, -40), Color("#00FF00"), 16)
			"damage":
				var dmg_bonus := 25 if reward_tier == "high" else 15
				var dmg_sec := 8.0 if reward_tier == "high" else 5.0
				player.bullet_damage += dmg_bonus
				await get_tree().create_timer(dmg_sec).timeout
				if is_instance_valid(player):
					player.bullet_damage -= dmg_bonus
				player.show_floating_text("⚔ GÜÇ! 5sn", global_position + Vector2(0, -40), Color("#E74C3C"), 16)
			"heal":
				player.heal(int(player.max_hp * (0.35 if reward_tier == "high" else 0.20)))
	
	var burst = create_tween()
	burst.tween_property(self, "scale", Vector2(1.5, 1.5), 0.08)
	burst.tween_property(self, "modulate:a", 0.0, 0.15)
	burst.tween_callback(queue_free)


func init_variant(tier: String) -> void:
	reward_tier = "high" if tier == "high" else "low"
	if is_inside_tree():
		_setup_visual()


func _setup_visual() -> void:
	if body_visual != null and is_instance_valid(body_visual):
		body_visual.queue_free()
	var spr := Sprite2D.new()
	spr.texture = CRATE_TEX_HIGH if reward_tier == "high" else CRATE_TEX_LOW
	spr.centered = true
	var dim: float = maxf(float(spr.texture.get_width()), 1.0)
	var sc: float = 34.0 / dim
	spr.scale = Vector2(sc, sc)
	body_visual = spr
	add_child(spr)
