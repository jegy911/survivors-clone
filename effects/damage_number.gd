extends Node2D

func show_damage(amount: int, color: Color = Color.WHITE):
	show_damage_text("-" + str(amount), color)

func show_damage_text(text: String, color: Color = Color.WHITE):
	$Label.text = text
	$Label.modulate = color
	$Label.add_theme_font_size_override("font_size", 16)
	show()
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(randf_range(-10, 10), -50), 0.7)
	tween.parallel().tween_property($Label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(_return_to_pool)

func _return_to_pool():
	ObjectPool.return_object(self)

func reset():
	$Label.modulate.a = 1.0
	hide()
