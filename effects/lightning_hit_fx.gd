extends Sprite2D
class_name LightningHitFx

const TEX_LIGHTNING := preload("res://assets/projectiles/lightning/lightning.png")
const TEX_STORM := preload("res://assets/projectiles/storm/storm_projectile.png")
const TEX_TOXIC := preload("res://assets/projectiles/toxic_chain/toxic_chain_projectile.png")

func _ready() -> void:
	centered = true
	visible = false
	if texture == null:
		texture = TEX_LIGHTNING


## Sahne düğümündeki `texture` / `scale` editörden verildiyse korunur; yalnızca `texture` boşsa varsayılan doku yüklenir.
func run(player: Node2D, style: StringName = &"lightning", duration: float = 0.22) -> void:
	centered = true
	var tint := Color.WHITE
	match style:
		&"toxic":
			texture = TEX_TOXIC
			scale = Vector2(0.11, 0.11)
			tint = Color(0.55, 1.0, 0.75)
		&"storm":
			texture = TEX_STORM
			scale = Vector2(0.13, 0.13)
			tint = Color(0.65, 0.92, 1.0)
		&"lightning", _:
			texture = TEX_LIGHTNING
			scale = Vector2(0.1, 0.1)
			tint = Color(1.0, 0.95, 0.55)
	modulate = tint
	var vfx_a: float = 1.0
	if is_instance_valid(player) and player.has_method("get_player_vfx_opacity"):
		vfx_a = float(player.get_player_vfx_opacity())
	modulate.a *= vfx_a
	visible = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, duration)
	tw.tween_callback(queue_free)
