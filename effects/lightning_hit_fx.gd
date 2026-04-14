extends Sprite2D
class_name LightningHitFx

const TEX_LIGHTNING := preload("res://assets/projectiles/lightning/lightning.png")

func _ready() -> void:
	centered = true
	visible = false
	if texture == null:
		texture = TEX_LIGHTNING


## Sahne düğümündeki `texture` / `scale` editörden verildiyse korunur; yalnızca `texture` boşsa varsayılan doku yüklenir.
func run(player: Node2D, style: StringName = &"lightning", duration: float = 0.22) -> void:
	centered = true
	if texture == null:
		texture = TEX_LIGHTNING
	rotation = randf() * TAU
	var tint := Color.WHITE
	match style:
		&"toxic":
			tint = Color(0.55, 1.0, 0.75)
		&"storm":
			tint = Color(0.65, 0.92, 1.0)
		&"lightning", _:
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
