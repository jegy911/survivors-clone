extends CanvasLayer

var _tab: String = "cosmetics"


func _ready() -> void:
	if not LocalizationManager.locale_changed.is_connected(_on_locale_changed):
		LocalizationManager.locale_changed.connect(_on_locale_changed)
	$MainVBox/TabRow/CosmeticsTab.pressed.connect(func(): _set_tab("cosmetics"))
	$MainVBox/TabRow/PetsTab.pressed.connect(func(): _set_tab("pets"))
	$MainVBox/TabRow/TrailersTab.pressed.connect(func(): _set_tab("trailers"))
	$MainVBox/BackButton.pressed.connect(_on_back)
	_apply_texts()
	_set_tab(_tab)


func _on_locale_changed(_locale: String) -> void:
	_apply_texts()


func _apply_texts() -> void:
	var s: float = SaveManager.get_ui_scale()
	$MainVBox/TitleLabel.text = tr("ui.shop.title")
	$MainVBox/TitleLabel.add_theme_font_size_override("font_size", int(36 * s))
	$MainVBox/TitleLabel.add_theme_color_override("font_color", Color("#E67E22"))
	$MainVBox/TabRow/CosmeticsTab.text = tr("ui.shop.tab_cosmetics")
	$MainVBox/TabRow/PetsTab.text = tr("ui.shop.tab_pets")
	$MainVBox/TabRow/TrailersTab.text = tr("ui.shop.tab_trailers")
	$MainVBox/PlaceholderLabel.text = tr("ui.shop.placeholder")
	$MainVBox/BackButton.text = tr("ui.shop.back")
	for b in [
		$MainVBox/TabRow/CosmeticsTab,
		$MainVBox/TabRow/PetsTab,
		$MainVBox/TabRow/TrailersTab,
		$MainVBox/BackButton,
	]:
		b.add_theme_font_size_override("font_size", int(18 * s))
	$MainVBox/PlaceholderLabel.add_theme_font_size_override("font_size", int(17 * s))
	$MainVBox/PlaceholderLabel.add_theme_color_override("font_color", Color("#CCCCCC"))
	_style_tabs()


func _style_tabs() -> void:
	var tabs := {
		"cosmetics": $MainVBox/TabRow/CosmeticsTab,
		"pets": $MainVBox/TabRow/PetsTab,
		"trailers": $MainVBox/TabRow/TrailersTab,
	}
	for k in tabs:
		var btn: Button = tabs[k]
		var sel: bool = (k == _tab)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#D68910") if sel else Color("#2A2A3E")
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		btn.add_theme_stylebox_override("normal", style)
		var hover := style.duplicate()
		hover.bg_color = Color("#F4D03F") if sel else Color("#4A4A5E")
		btn.add_theme_stylebox_override("hover", hover)


func _set_tab(which: String) -> void:
	_tab = which
	_style_tabs()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		_on_back()
