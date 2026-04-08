extends Node
## Klavye tuşlarını `InputMap` üzerinden yeniden eşler; oyun kolu olayları projede kaldığı sürece korunur.
## Kayıt: `SaveManager.settings["input_keyboard_overrides"]` — eylem adı → fiziksel tuş kodu (`Key`).

const REMAPPABLE_ACTIONS: Array[String] = [
	"ui_up", "ui_down", "ui_left", "ui_right",
	"p2_up", "p2_down", "p2_left", "p2_right",
	"ui_cancel",
	"toggle_fullscreen",
]

var _project_defaults: Dictionary = {}


func _ready() -> void:
	_snapshot_project_defaults()
	apply_saved_overrides()


func _snapshot_project_defaults() -> void:
	_project_defaults.clear()
	for action in REMAPPABLE_ACTIONS:
		var events: Array[InputEvent] = []
		for ev in InputMap.action_get_events(action):
			events.append(ev.duplicate(true) as InputEvent)
		_project_defaults[action] = events


func apply_saved_overrides() -> void:
	restore_project_defaults()
	var raw: Variant = SaveManager.settings.get("input_keyboard_overrides", {})
	if raw is Dictionary:
		for action in raw.keys():
			var a := str(action)
			if not REMAPPABLE_ACTIONS.has(a):
				continue
			var code := int(raw[action])
			if code > 0:
				_apply_keyboard_only(a, code as Key)


func restore_project_defaults() -> void:
	for action in REMAPPABLE_ACTIONS:
		var existing: Array = InputMap.action_get_events(action).duplicate()
		for ev in existing:
			InputMap.action_erase_event(action, ev)
		for ev in _project_defaults.get(action, []):
			InputMap.action_add_event(action, (ev as InputEvent).duplicate(true))


func reset_to_defaults_and_save() -> void:
	restore_project_defaults()
	SaveManager.settings["input_keyboard_overrides"] = {}
	SaveManager.save_game()


func set_keyboard_binding(action: String, physical_keycode: Key) -> void:
	if not REMAPPABLE_ACTIONS.has(action):
		return
	_apply_keyboard_only(action, physical_keycode)
	var o: Dictionary = {}
	var cur: Variant = SaveManager.settings.get("input_keyboard_overrides", {})
	if cur is Dictionary:
		o = (cur as Dictionary).duplicate()
	o[action] = int(physical_keycode)
	SaveManager.settings["input_keyboard_overrides"] = o
	SaveManager.save_game()


func _apply_keyboard_only(action: String, physical_keycode: Key) -> void:
	var to_erase: Array[InputEvent] = []
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			to_erase.append(ev)
	for ev in to_erase:
		InputMap.action_erase_event(action, ev)
	var nk := InputEventKey.new()
	nk.physical_keycode = physical_keycode
	nk.keycode = KEY_NONE
	InputMap.action_add_event(action, nk)


func get_keyboard_binding_display(action: String) -> String:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return (ev as InputEventKey).as_text()
	return "—"
