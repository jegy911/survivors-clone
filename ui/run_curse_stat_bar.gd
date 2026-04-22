extends Control
## Tier 0 → tier max arası göreli değer; dolgu seçilen kademeye kadar.

@export var bar_height: int = 8

var _v_min: float = 100.0
var _v_max: float = 150.0
var _v_cur: float = 100.0


func set_scale_values(v_min: float, v_max: float, v_cur: float) -> void:
	_v_min = v_min
	_v_max = maxf(v_max, v_min + 0.001)
	_v_cur = clampf(v_cur, _v_min, _v_max)
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = float(bar_height)
	if w <= 1.0 or h <= 1.0:
		return
	var denom: float = _v_max - _v_min
	var t: float = clampf((_v_cur - _v_min) / denom, 0.0, 1.0)
	draw_rect(Rect2(0, 0, w, h), Color(0.11, 0.11, 0.17, 1.0))
	draw_rect(Rect2(0, 0, w * t, h), Color(0.58, 0.4, 0.86, 0.92))
	var edge_x: float = w * t
	draw_line(Vector2(edge_x, 0), Vector2(edge_x, h), Color(1.0, 1.0, 1.0, 0.28), 1.0)


func _get_minimum_size() -> Vector2:
	return Vector2(64, float(bar_height))
