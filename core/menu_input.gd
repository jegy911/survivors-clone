class_name MenuInput
extends RefCounted
## Menülerde ESC / ui_cancel / gamepad back ile geri için ortak kontrol.


static func is_menu_back_pressed(event: InputEvent) -> bool:
	if event.is_echo():
		return false
	if event.is_action_pressed("ui_cancel"):
		return true
	if event is InputEventKey and event.pressed:
		return event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE
	if event is InputEventJoypadButton and event.pressed:
		return event.button_index == JOY_BUTTON_B
	return false
