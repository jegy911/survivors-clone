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
	$MainVBox/PlaceholderLabel.add_theme_font_size_override("font_size", int(17 * s))
	$MainVBox/PlaceholderLabel.add_theme_color_override("font_color", Color("#CCCCCC"))
	_style_tabs()


func _style_tabs() -> void:
	var tabs := {
		"cosmetics": [$MainVBox/TabRow/CosmeticsTab, 0],
		"pets": [$MainVBox/TabRow/PetsTab, 1],
		"trailers": [$MainVBox/TabRow/TrailersTab, 2],
	}
	for k in tabs:
		var btn: Button = tabs[k][0]
		var cover_v: int = tabs[k][1]
		var sel: bool = (k == _tab)
		var s: float = SaveManager.get_ui_scale()
		var mod := Color(1.15, 1.08, 1.05, 1.0) if sel else Color(0.62, 0.62, 0.68, 1.0)
		ButtonCoverStyles.apply(btn, cover_v, int(18 * s), Vector4(10.0, 6.0, 10.0, 6.0) * s, mod)
	var back_b: Button = $MainVBox/BackButton
	ButtonCoverStyles.apply(back_b, 1, int(18 * SaveManager.get_ui_scale()), Vector4(16.0, 8.0, 16.0, 8.0) * SaveManager.get_ui_scale())


func _set_tab(which: String) -> void:
	_tab = which
	_style_tabs()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		_on_back()
