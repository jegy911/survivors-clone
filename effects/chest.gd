extends Area2D

const CHEST_TEX := preload("res://assets/effects/chest.png")
const CHEST_OPENING_TEX := preload("res://assets/effects/chest_opening_animation.png")
const UPGRADE_UI_SCENE := preload("res://ui/upgrade_ui.tscn")
const FRAME_SIZE := 512
const CHEST_OPENING_FRAME_COUNT := 47
const CHEST_UI_CENTER_Y_RATIO := 0.50

var player = null
var collected = false
var opening = false
var ui_layer: CanvasLayer = null
var pending_reward: Dictionary = {}
var center_panel: PanelContainer = null
var roll_icon: Sprite2D = null
var frozen_chest_sprite: Sprite2D = null
var opening_anim_sprite: AnimatedSprite2D = null
var open_button: Button = null
var chest_idle_tween: Tween = null
const ROULETTE_ICON_TARGET_SIZE := 192.0
const FINAL_REWARD_ICON_SIZE := 192.0

const _WEAPON_IDS: Array[String] = [
	"bullet", "dagger", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser", "fan_blade",
	"hex_sigil", "gravity_anchor", "bastion_flail", "shield_ram", "arc_pulse",
]
const _ITEM_IDS: Array[String] = [
	"lifesteal", "armor", "crit", "explosion", "magnet", "poison", "shield", "speed_charm", "blood_pool",
	"luck_stone", "turbine", "steam_armor", "energy_cell", "ember_heart", "glyph_charm", "resonance_stone",
	"rampart_plate", "iron_bulwark", "night_vial", "field_lens",
]

@onready var body: Sprite2D = $ChestSprite
@onready var interact_label: Label = $InteractionLabel


func _ready():
	body.texture = CHEST_TEX
	var dim: float = maxf(float(CHEST_TEX.get_width()), 1.0)
	body.scale = Vector2.ONE * (112.0 / dim)
	interact_label.text = "[E] OPEN"
	interact_label.visible = false
	z_index = 10


func _process(_delta):
	if collected or opening or not visible:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	var dist: float = global_position.distance_to(player.global_position)
	var can_open: bool = dist < 48.0
	interact_label.visible = can_open
	if not can_open:
		return
	if Input.is_key_pressed(KEY_E) or Input.is_action_just_pressed("ui_accept"):
		_open_chest_sequence()


func _open_chest_sequence() -> void:
	if collected or opening:
		return
	opening = true
	collected = true
	interact_label.visible = false
	set_process(false)
	_show_open_overlay()


func _show_open_overlay() -> void:
	_create_overlay_shell()
	var panel := center_panel
	_sync_center_panel_height()
	_clear_center_panel()
	await get_tree().process_frame
	var cx := panel.size.x * 0.5
	var cy := panel.size.y * CHEST_UI_CENTER_Y_RATIO
	_make_stage_container("CHEST")
	opening_anim_sprite = AnimatedSprite2D.new()
	opening_anim_sprite.sprite_frames = _build_opening_frames()
	opening_anim_sprite.animation = "open"
	opening_anim_sprite.speed_scale = 1.0
	opening_anim_sprite.position = Vector2(cx, cy)
	opening_anim_sprite.centered = true
	opening_anim_sprite.z_index = 70
	opening_anim_sprite.frame = 0
	panel.add_child(opening_anim_sprite)
	_start_closed_chest_idle()

	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(overlay)
	panel.move_child(overlay, panel.get_child_count() - 1)

	open_button = Button.new()
	open_button.text = "OPEN"
	open_button.custom_minimum_size = Vector2(140, 44)
	open_button.position = Vector2(cx - 70, cy + 220)
	open_button.pressed.connect(_play_opening_stage)
	overlay.add_child(open_button)


func _play_opening_stage() -> void:
	if opening_anim_sprite == null or center_panel == null:
		return
	var panel := center_panel
	var cx := panel.size.x * 0.5
	var cy := panel.size.y * CHEST_UI_CENTER_Y_RATIO
	if chest_idle_tween != null:
		chest_idle_tween.kill()
		chest_idle_tween = null
	opening_anim_sprite.position = Vector2(cx, cy)
	opening_anim_sprite.rotation = 0.0

	roll_icon = Sprite2D.new()
	roll_icon.centered = true
	roll_icon.position = Vector2(cx, cy - 82)
	roll_icon.visible = false
	panel.add_child(roll_icon)
	panel.move_child(roll_icon, panel.get_child_count() - 1)

	if open_button != null:
		open_button.disabled = true
		open_button.visible = false
	opening_anim_sprite.play("open")
	await opening_anim_sprite.animation_finished
	opening_anim_sprite.stop()
	opening_anim_sprite.frame = max(opening_anim_sprite.sprite_frames.get_frame_count("open") - 1, 0)
	frozen_chest_sprite = Sprite2D.new()
	frozen_chest_sprite.texture = _opening_last_frame_texture()
	frozen_chest_sprite.centered = true
	frozen_chest_sprite.position = Vector2(cx, cy)
	panel.add_child(frozen_chest_sprite)
	panel.move_child(frozen_chest_sprite, panel.get_child_count() - 1)
	panel.move_child(roll_icon, panel.get_child_count() - 1)
	opening_anim_sprite.visible = false
	roll_icon.visible = true
	await _run_reward_roulette(5.0)

	_show_reward_stage()


func _show_reward_stage() -> void:
	var panel := center_panel
	_sync_center_panel_height()
	if roll_icon != null:
		roll_icon.visible = false
	pending_reward = _roll_reward()
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(overlay)
	panel.move_child(overlay, panel.get_child_count() - 1)
	var cx := panel.size.x * 0.5
	var cy := panel.size.y * CHEST_UI_CENTER_Y_RATIO

	var title := Label.new()
	title.text = _reward_title(pending_reward)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.custom_minimum_size = Vector2(520, 44)
	title.position = Vector2(cx - 260, cy - 248)
	overlay.add_child(title)

	var reward_icon := _reward_icon(pending_reward)
	if reward_icon != null:
		var icon_sprite := TextureRect.new()
		icon_sprite.texture = reward_icon
		icon_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_sprite.custom_minimum_size = Vector2(FINAL_REWARD_ICON_SIZE, FINAL_REWARD_ICON_SIZE)
		icon_sprite.position = Vector2(cx - FINAL_REWARD_ICON_SIZE * 0.5, cy - FINAL_REWARD_ICON_SIZE * 0.5 - 28.0)
		overlay.add_child(icon_sprite)
		var pop := icon_sprite.create_tween()
		pop.tween_property(icon_sprite, "scale", icon_sprite.scale * 1.18, 0.12)
		pop.tween_property(icon_sprite, "scale", icon_sprite.scale, 0.14)

	var bottom := VBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 20)
	bottom.custom_minimum_size = Vector2(620, 130)
	bottom.position = Vector2(cx - 310, cy + 214)
	overlay.add_child(bottom)

	var desc_label := Label.new()
	desc_label.text = _reward_desc(pending_reward)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(620, 64)
	bottom.add_child(desc_label)

	var bottom_gap := Control.new()
	bottom_gap.custom_minimum_size = Vector2(620, 10)
	bottom.add_child(bottom_gap)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	bottom.add_child(btn_row)

	var take_btn := Button.new()
	take_btn.text = "TAKE"
	take_btn.size = Vector2(120, 44)
	take_btn.pressed.connect(_accept_reward)
	btn_row.add_child(take_btn)

	var deny_btn := Button.new()
	deny_btn.text = "DISCARD"
	deny_btn.size = Vector2(120, 44)
	deny_btn.pressed.connect(_close_chest_overlay)
	btn_row.add_child(deny_btn)


func _accept_reward() -> void:
	_apply_reward(pending_reward)
	_close_chest_overlay()


func _close_chest_overlay() -> void:
	if player:
		player.chests_opened += 1
	if chest_idle_tween != null:
		chest_idle_tween.kill()
		chest_idle_tween = null
	get_tree().paused = false
	if is_instance_valid(ui_layer):
		ui_layer.queue_free()
	queue_free()


func _roll_reward() -> Dictionary:
	var roll := randf()
	if roll < 0.42:
		var all_items = _ITEM_IDS
		return {"type": "item", "id": all_items[randi() % all_items.size()]}
	if roll < 0.72:
		var all_weapons = _WEAPON_IDS
		return {"type": "weapon", "id": all_weapons[randi() % all_weapons.size()]}
	if roll < 0.9:
		return {"type": "gold", "amount": 8 + randi() % 8}
	return {"type": "heal", "amount": 0.20}


func _apply_reward(reward: Dictionary) -> void:
	if player == null:
		return
	var reward_type := str(reward.get("type", ""))
	match reward_type:
		"item":
			player.add_item(str(reward.get("id", "armor")))
		"weapon":
			player.add_weapon(str(reward.get("id", "bullet")))
		"gold":
			player.collect_gold(int(reward.get("amount", 10)))
		"heal":
			player.heal(int(player.max_hp * float(reward.get("amount", 0.2))))
		_:
			pass


func init(pos: Vector2):
	global_position = pos
	collected = false
	opening = false
	if interact_label != null:
		interact_label.visible = false


func _create_overlay_shell() -> void:
	get_tree().paused = true
	ui_layer = UPGRADE_UI_SCENE.instantiate() as CanvasLayer
	ui_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_tree().root.add_child(ui_layer)
	if ui_layer.has_method("show_upgrades"):
		ui_layer.call("show_upgrades", player)

	var title := ui_layer.get_node_or_null("EditorRoot/OuterMargin/OuterVBox/TitleLabel") as Label
	if title != null:
		title.text = "CHEST"

	var header := ui_layer.get_node_or_null("EditorRoot/OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/UpgradesHeaderLabel") as Label
	if header != null:
		header.text = "Chest"
		header.visible = false

	var action_row := ui_layer.get_node_or_null("EditorRoot/OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/ActionRow") as Control
	if action_row != null:
		action_row.visible = false

	var options_vbox := ui_layer.get_node_or_null("EditorRoot/OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/OptionsScroll/OptionsVBox") as VBoxContainer
	if options_vbox != null:
		for c in options_vbox.get_children():
			c.queue_free()
		var center := PanelContainer.new()
		center.custom_minimum_size = Vector2(0, 0)
		center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center.size_flags_vertical = Control.SIZE_EXPAND_FILL
		center.z_index = 50
		var st := StyleBoxFlat.new()
		st.bg_color = Color(0.05, 0.06, 0.08, 0.78)
		st.corner_radius_top_left = 6
		st.corner_radius_top_right = 6
		st.corner_radius_bottom_left = 6
		st.corner_radius_bottom_right = 6
		center.add_theme_stylebox_override("panel", st)
		center_panel = center
		options_vbox.add_child(center)
		_sync_center_panel_height.call_deferred()


func _opening_frame_count() -> int:
	var cols := maxi(1, CHEST_OPENING_TEX.get_width() / FRAME_SIZE)
	var rows := maxi(1, CHEST_OPENING_TEX.get_height() / FRAME_SIZE)
	return mini(cols * rows, CHEST_OPENING_FRAME_COUNT)


func _start_closed_chest_idle() -> void:
	if opening_anim_sprite == null:
		return
	if chest_idle_tween != null:
		chest_idle_tween.kill()
	chest_idle_tween = opening_anim_sprite.create_tween()
	chest_idle_tween.set_loops()
	chest_idle_tween.tween_interval(0.35)
	chest_idle_tween.tween_property(opening_anim_sprite, "rotation", deg_to_rad(-3.0), 0.09)
	chest_idle_tween.tween_property(opening_anim_sprite, "rotation", deg_to_rad(3.0), 0.10)
	chest_idle_tween.tween_property(opening_anim_sprite, "rotation", 0.0, 0.08)
	chest_idle_tween.tween_interval(0.30)


func _opening_last_frame_texture() -> Texture2D:
	var cols := maxi(1, CHEST_OPENING_TEX.get_width() / FRAME_SIZE)
	var total := _opening_frame_count()
	var last_idx := maxi(total - 1, 0)
	var x := last_idx % cols
	var y := last_idx / cols
	var at := AtlasTexture.new()
	at.atlas = CHEST_OPENING_TEX
	at.region = Rect2(x * FRAME_SIZE, y * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)
	return at


func _build_opening_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation("open")
	sf.set_animation_speed("open", 40.0)
	sf.set_animation_loop("open", false)
	var cols := maxi(1, CHEST_OPENING_TEX.get_width() / FRAME_SIZE)
	var rows := maxi(1, CHEST_OPENING_TEX.get_height() / FRAME_SIZE)
	var max_frames := _opening_frame_count()
	var idx := 0
	for y in rows:
		for x in cols:
			if idx >= max_frames:
				break
			var at := AtlasTexture.new()
			at.atlas = CHEST_OPENING_TEX
			at.region = Rect2(x * FRAME_SIZE, y * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)
			sf.add_frame("open", at)
			idx += 1
	return sf


func _reward_icon(reward: Dictionary) -> Texture2D:
	var reward_type := str(reward.get("type", ""))
	match reward_type:
		"item":
			return UpgradeIconCatalog.try_item(str(reward.get("id", "")))
		"weapon":
			return UpgradeIconCatalog.try_weapon_with_evolution_fallback(str(reward.get("id", "")))
		"gold":
			return load("res://assets/effects/gold.png") as Texture2D
		"heal":
			return load("res://assets/effects/blood_oath.png") as Texture2D
		_:
			return null


func _reward_title(reward: Dictionary) -> String:
	var reward_type := str(reward.get("type", ""))
	match reward_type:
		"item":
			var iid := str(reward.get("id", ""))
			return tr("codex.item.%s.name" % iid)
		"weapon":
			var wid := str(reward.get("id", ""))
			return tr("codex.weapon.%s.name" % wid)
		"gold":
			return "GOLD +%d" % int(reward.get("amount", 0))
		"heal":
			return "HEAL"
		_:
			return "REWARD"


func _reward_desc(reward: Dictionary) -> String:
	var reward_type := str(reward.get("type", ""))
	match reward_type:
		"item":
			var iid := str(reward.get("id", ""))
			return tr("codex.item.%s.desc" % iid)
		"weapon":
			var wid := str(reward.get("id", ""))
			return tr("codex.weapon.%s.desc" % wid)
		"gold":
			return "Instant gold reward from chest."
		"heal":
			return "Restore %d%% max HP." % int(float(reward.get("amount", 0.2)) * 100.0)
		_:
			return ""


func _run_reward_roulette(seconds: float) -> void:
	var pool: Array[Texture2D] = []
	for id in _ITEM_IDS:
		var t := UpgradeIconCatalog.try_item(id)
		if t != null:
			pool.append(t)
	for id in _WEAPON_IDS:
		var w := UpgradeIconCatalog.try_weapon_with_evolution_fallback(id)
		if w != null:
			pool.append(w)
	if pool.is_empty() or roll_icon == null:
		await get_tree().create_timer(seconds, true, false, true).timeout
		return
	var elapsed := 0.0
	while elapsed < seconds:
		var tex: Texture2D = pool[randi() % pool.size()]
		roll_icon.texture = tex
		var max_side: int = maxi(tex.get_width(), tex.get_height())
		var icon_scale: float = ROULETTE_ICON_TARGET_SIZE / maxf(float(max_side), 1.0)
		roll_icon.scale = Vector2.ONE * icon_scale
		var step := 0.03
		if elapsed >= 3.0:
			var t: float = clampf((elapsed - 3.0) / 2.0, 0.0, 1.0)
			step = lerpf(0.03, 0.24, t)
		await get_tree().create_timer(step, true, false, true).timeout
		elapsed += step


func _clear_center_panel() -> void:
	if center_panel == null:
		return
	for c in center_panel.get_children():
		c.queue_free()


func _make_stage_container(title_text: String) -> VBoxContainer:
	var wrap := CenterContainer.new()
	wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_panel.add_child(wrap)
	var stage := VBoxContainer.new()
	stage.alignment = BoxContainer.ALIGNMENT_CENTER
	stage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stage.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stage.add_theme_constant_override("separation", 14)
	wrap.add_child(stage)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	stage.add_child(title)
	return stage


func _sync_center_panel_height() -> void:
	if ui_layer == null or center_panel == null:
		return
	var options_scroll := ui_layer.get_node_or_null("EditorRoot/OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/OptionsScroll") as ScrollContainer
	if options_scroll == null:
		return
	var h: float = options_scroll.size.y
	if h <= 1.0:
		return
	center_panel.custom_minimum_size.y = h
