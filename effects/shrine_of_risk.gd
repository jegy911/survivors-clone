extends Node2D

const SHRINE_RISK_TEX := preload("res://assets/effects/shrine_risk.png")
const SHRINE_DEVIL_TEX := preload("res://assets/effects/shrine_devil.png")

var active = true
var body_visual: CanvasItem
var shrine_type = "risk"

func _ready():
	shrine_type = "devil" if randf() < 0.3 else "risk"
	var spr := Sprite2D.new()
	spr.texture = SHRINE_DEVIL_TEX if shrine_type == "devil" else SHRINE_RISK_TEX
	spr.centered = true
	var dim: float = maxf(float(spr.texture.get_width()), 1.0)
	var sc: float = 34.0 / dim
	spr.scale = Vector2(sc, sc)
	body_visual = spr
	add_child(spr)
	
	var label = Label.new()
	label.text = "☠" if shrine_type == "devil" else "⚠"
	label.position = Vector2(-8, -30)
	add_child(label)
	
	var pulse = body_visual.create_tween()
	pulse.set_loops()
	pulse.tween_property(body_visual, "modulate:a", 0.4, 0.4)
	pulse.tween_property(body_visual, "modulate:a", 1.0, 0.4)

func _process(_delta):
	if not active:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if global_position.distance_to(player.global_position) < 25:
		_activate(player)

func _activate(player: Node):
	active = false
	if shrine_type == "devil":
		_devil_bargain(player)
	else:
		_risk_shrine(player)
	var tween = body_visual.create_tween()
	tween.tween_property(body_visual, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _risk_shrine(player: Node):
	player.shrine_active = true
	player.shrine_timer = 60.0
	player.show_floating_text("🕯 RİSK SUNAGI! +%200 XP/Gold, düşman +%50", player.global_position + Vector2(0, -70), Color("#9B59B6"), 16)

func _devil_bargain(player: Node):
	# HP %35 kaybet, rastgele bir silah/eşya max level olsun
	var hp_loss = int(player.max_hp * 0.35)
	player.max_hp = max(1, player.max_hp - hp_loss)
	player.hp = min(player.hp, player.max_hp)
	player.update_hp_bar()
	
	# Rastgele bir silah veya eşyayı maxla
	var candidates = []
	for w_id in player.active_weapons:
		var w = player.active_weapons[w_id]
		if w.level < w.max_level:
			candidates.append({"type": "weapon", "id": w_id, "obj": w})
	for i_id in player.active_items:
		var i = player.active_items[i_id]
		if i.level < i.max_level:
			candidates.append({"type": "item", "id": i_id, "obj": i})
	
	if candidates.is_empty():
		player.show_floating_text("☠ ŞEYTAN PAZARLIĞI — Max level yok!", player.global_position + Vector2(0, -70), Color("#8B0000"), 16)
		return
	
	candidates.shuffle()
	var chosen = candidates[0]
	var obj = chosen["obj"]
	while obj.level < obj.max_level:
		obj.upgrade()
	
	player.show_floating_text("☠ ŞEYTAN PAZARLIĞI!\n-" + str(hp_loss) + " Max HP → " + obj.weapon_name if chosen["type"] == "weapon" else obj.item_name + " MAX!", player.global_position + Vector2(0, -80), Color("#8B0000"), 16)
