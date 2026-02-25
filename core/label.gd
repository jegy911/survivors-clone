extends Node2D

func show_damage(amount: int):
	$Label.text = "-" + str(amount)
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -40), 0.6)
	tween.parallel().tween_property($Label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
