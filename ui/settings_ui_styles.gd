class_name SettingsUiStyles
extends RefCounted
## Ayarlar üst sekme satırı + geri düğmesi; kapak PNG’leri `ButtonCoverStyles` ile.


static func refresh_settings_main_tabs(tab_row: Node, current_tab_id: String) -> void:
	var rows: Array = [
		["SesTab", "ses", "ui.settings.tab_audio"],
		["DilTab", "dil", "ui.settings.tab_language"],
		["GoruntuTab", "goruntu", "ui.settings.tab_video"],
		["OynanisTab", "oynanis", "ui.settings.tab_gameplay"],
		["KontrolTab", "kontrol", "ui.settings.tab_controls"],
		["ProfilTab", "profil", "ui.settings.tab_profile"],
		["DevToolsTab", "devtools", "ui.settings.tab_dev"],
	]
	var cover_variants: Array[int] = [0, 1, 2, 0, 1, 2, 0]
	var i := 0
	for r in rows:
		var node_name: String = r[0]
		var tid: String = r[1]
		var btn := tab_row.get_node_or_null(node_name) as Button
		if btn == null:
			continue
		btn.text = TranslationServer.translate(StringName(r[2]))
		btn.custom_minimum_size = Vector2(160, 50)
		var sel: bool = (tid == current_tab_id)
		var mod := Color(1.1, 1.04, 1.2, 1.0) if sel else Color(0.66, 0.66, 0.72, 1.0)
		ButtonCoverStyles.apply(btn, cover_variants[i], 15, Vector4(10.0, 6.0, 10.0, 6.0), mod)
		i += 1


static func style_settings_back_button(btn: Button, back_text: String) -> void:
	btn.text = back_text
	btn.custom_minimum_size = Vector2(220, 52)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ButtonCoverStyles.apply(btn, 1, 17, Vector4(18.0, 8.0, 18.0, 8.0), Color.WHITE, Color.WHITE)
