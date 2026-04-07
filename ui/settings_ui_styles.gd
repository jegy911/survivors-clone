class_name SettingsUiStyles
extends RefCounted
## Ayarlar ekranı sekme ve düğüm stilleri (settings.gd ile paylaşılır).


static func style_tab_button(btn: Button, text: String) -> void:
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 50)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1A1A2E")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 15)


static func style_back_button(btn: Button, back_text: String) -> void:
	btn.text = back_text
	btn.custom_minimum_size = Vector2(200, 50)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1A1A2E")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 16)

