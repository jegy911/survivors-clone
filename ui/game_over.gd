extends CanvasLayer

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	$Panel.size = Vector2(600, 580)
	$Panel.position = screen_size / 2 - $Panel.size / 2
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0D0D1A")
	style.border_color = Color("#9B59B6")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	$Panel.add_theme_stylebox_override("panel", style)
	
	$Panel/VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Panel/VBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$Panel/VBoxContainer.add_theme_constant_override("separation", 10)

func show_stats(time: float, level: int, kills: int, gold_earned_run: int, won: bool = false, run_total_xp: int = 0) -> void:
	SaveManager.grant_account_xp_from_run_raw(run_total_xp)
	var screen_size = get_viewport().get_visible_rect().size
	$Panel.size = Vector2(600, 580)
	$Panel.position = screen_size / 2 - $Panel.size / 2
	
	var minutes: int = int(time / 60.0)
	var seconds: int = int(time) % 60
	var kpm = 0.0
	if time > 0:
		kpm = kills / (time / 60.0)
	
	var vbox = $Panel/VBoxContainer
	for child in vbox.get_children():
		child.queue_free()
	
	if won:
		_add_label(vbox, tr("ui.game_over.won"), 36, Color("#FFD700"), true)
	else:
		_add_label(vbox, tr("ui.game_over.lost"), 36, Color("#E74C3C"), true)
	_add_separator(vbox)

	_add_label(vbox, tr("ui.game_over.time") % [minutes, seconds], 20, Color.WHITE)

	_add_label(vbox, tr("ui.game_over.level") % level, 20, Color("#F1C40F"))

	_add_label(vbox, tr("ui.game_over.kills") % kills, 20, Color("#E74C3C"))

	_add_label(vbox, tr("ui.game_over.kpm") % ("%.1f" % kpm), 18, Color("#AAA"))

	_add_separator(vbox)

	_add_label(vbox, tr("ui.game_over.gold_earned") % gold_earned_run, 22, Color("#F5E642"))
	if run_total_xp > 0:
		var granted: int = int(floor(float(run_total_xp) * 0.20))
		if granted > 0:
			_add_label(
				vbox,
				tr("ui.game_over.account_xp_banked") % granted,
				24,
				Color("#FFF9C4"),
				false,
				3,
				Color("#1A0A33")
			)

	_add_separator(vbox)
	
	# Butonlar
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)
	
	var restart_btn = _make_button(tr("ui.game_over.restart"), 0)
	var menu_btn = _make_button(tr("ui.game_over.menu"), 1)
	
	restart_btn.pressed.connect(_on_restart)
	menu_btn.pressed.connect(_on_menu)
	
	btn_row.add_child(restart_btn)
	btn_row.add_child(menu_btn)
	
	visible = true

func _add_label(parent: Node, text: String, size: int, color: Color, _bold: bool = false, outline_size: int = 0, outline_color: Color = Color.BLACK):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if outline_size > 0:
		label.add_theme_constant_override("outline_size", outline_size)
		label.add_theme_color_override("font_outline_color", outline_color)
	parent.add_child(label)

func _add_separator(parent: Node):
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color("#333355"))
	parent.add_child(sep)

func _make_button(text: String, cover_variant: int) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(220, 55)
	ButtonCoverStyles.apply(btn, cover_variant, 18, Vector4(20.0, 8.0, 20.0, 8.0))
	return btn

func _on_restart():
	get_tree().paused = false
	ObjectPool.reset_all()
	queue_free()
	get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _on_menu():
	get_tree().paused = false
	ObjectPool.reset_all()
	queue_free()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		_on_menu()
