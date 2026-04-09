extends CanvasLayer

## Karanlıktan açılış (~5 sn); 4–6. sn arası prompt alttan yukarı kayar (ekranın alt bandında kalır).

const REVEAL_SEC: float = 5.0
const PROMPT_START_SEC: float = 4.0
const PROMPT_RISE_SEC: float = 2.0

# =============================================================================
# PROMPT KONUMU — Buradan oynayarak tam istediğin yere getir.
# Dikey referans: anchor 1.0 = ekranın ALT kenarı. Üst = 0.0, alt = 1.0.
# offset_top / offset_bottom (px): Her iki anchor aynı değerdeyken yükseklik =
#   offset_bottom - offset_top. Negatif değerler çoğunlukla metni yukarı iter.
# Yatay: intro_splash.tscn → PromptLabel → offset_left / offset_right (± = yarı genişlik).
# =============================================================================
## Animasyon bittiğinde dikey referans (1.0 = alt kenar; 0.92 gibi yaparsan biraz yukarı çıkar).
const PROMPT_ANCHOR_END: float = 1.0
## t=0 (hareket başı): altta / daha aşağıda — ör. bitişten daha “az negatif” offset_top.
const PROMPT_OFF_TOP_START: float = -28.0
const PROMPT_OFF_BOTTOM_START: float = 40.0
## t=1 (durduğu yer): alt bant — resmi az kapatsın diye varsayılan alçak; ince ayar burada.
const PROMPT_OFF_TOP_END: float = -100.0
const PROMPT_OFF_BOTTOM_END: float = -28.0

## Hareket başında anchor (genelde 1.0 = alttan başla); istersen bitişle aynı tut.
const PROMPT_ANCHOR_START: float = 1.0

var _awaiting_input: bool = false


func _ready() -> void:
	if not LocalizationManager.locale_changed.is_connected(_on_locale_changed):
		LocalizationManager.locale_changed.connect(_on_locale_changed)
	_setup_layers()
	_apply_locale_text()
	if not AudioManager.music_player.playing:
		AudioManager.play_music(1)
	_start_reveal()
	get_tree().create_timer(PROMPT_START_SEC).timeout.connect(_begin_prompt_rise, CONNECT_ONE_SHOT)


func _on_locale_changed(_code: String) -> void:
	_apply_locale_text()


func _setup_layers() -> void:
	var tex: Texture2D = MainMenuBackground.load_texture()
	if tex != null:
		$FullRect/BackgroundPhoto.texture = tex
		$FullRect/BackgroundPhoto.visible = true
	else:
		$FullRect/BackgroundPhoto.visible = false
	$FullRect/DarkenOverlay.color = Color.BLACK
	$FullRect/DarkenOverlay.modulate = Color(1, 1, 1, 1)
	$FullRect/DarkenOverlay.visible = true
	var label: Label = $FullRect/PromptLabel
	label.visible = false
	label.modulate.a = 0.0
	_apply_prompt_slide(0.0)


func _apply_locale_text() -> void:
	$FullRect/PromptLabel.text = tr("ui.intro_splash.press_to_start")


func _apply_prompt_slide(t: float) -> void:
	var label: Label = $FullRect/PromptLabel
	var a: float = lerpf(PROMPT_ANCHOR_START, PROMPT_ANCHOR_END, t)
	label.anchor_top = a
	label.anchor_bottom = a
	label.offset_top = lerpf(PROMPT_OFF_TOP_START, PROMPT_OFF_TOP_END, t)
	label.offset_bottom = lerpf(PROMPT_OFF_BOTTOM_START, PROMPT_OFF_BOTTOM_END, t)


func _start_reveal() -> void:
	var tw := create_tween()
	tw.tween_property($FullRect/DarkenOverlay, "modulate:a", 0.0, REVEAL_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_on_overlay_fade_done)


func _on_overlay_fade_done() -> void:
	$FullRect/DarkenOverlay.visible = false


func _begin_prompt_rise() -> void:
	var label: Label = $FullRect/PromptLabel
	label.visible = true
	label.modulate.a = 0.0
	var tw2 := create_tween()
	tw2.set_parallel(true)
	tw2.tween_method(_apply_prompt_slide, 0.0, 1.0, PROMPT_RISE_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw2.tween_property(label, "modulate:a", 1.0, PROMPT_RISE_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw2.finished.connect(_on_prompt_anim_done, CONNECT_ONE_SHOT)


func _on_prompt_anim_done() -> void:
	_awaiting_input = true


func _unhandled_input(event: InputEvent) -> void:
	if not _awaiting_input:
		return
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		_go_main_menu()
	elif event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		_go_main_menu()
	elif event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()
		_go_main_menu()
	elif event is InputEventJoypadButton and event.pressed:
		get_viewport().set_input_as_handled()
		_go_main_menu()


func _go_main_menu() -> void:
	_awaiting_input = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
