class_name ButtonCoverStyles
extends RefCounted
## Ana menü ile aynı PNG kapakları (`button1`–`3`); `StyleBoxTexture` + nine-patch margin.

const _BTN1: Texture2D = preload("res://assets/button covers/button1.png")
const _BTN2: Texture2D = preload("res://assets/button covers/button2.png")
const _BTN3: Texture2D = preload("res://assets/button covers/button3.png")

static var _covers: Array[Texture2D] = [_BTN1, _BTN2, _BTN3]

## Varsayılan metin içi boşluk (ana menü ile uyumlu).
const DEFAULT_TEXT_INSET := Vector4(26.0, 8.0, 26.0, 8.0)


static func cover_texture(cover_variant: int) -> Texture2D:
	return _covers[posmod(cover_variant, _covers.size())]


## 512² atlas: opak çerçeve bölgesi (üç PNG aynı düzen varsayımı).
static func atlas_region_for(_tex: Texture2D) -> Rect2:
	return Rect2(2, 188, 507, 134)


static func stylebox_from_cover(tex: Texture2D, modulate_color: Color, text_inset: Vector4) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.region_rect = atlas_region_for(tex)
	sb.modulate_color = modulate_color
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.texture_margin_left = 104
	sb.texture_margin_top = 0.0
	sb.texture_margin_right = 104
	sb.texture_margin_bottom = 0.0
	sb.draw_center = true
	sb.content_margin_left = text_inset.x
	sb.content_margin_top = text_inset.y
	sb.content_margin_right = text_inset.z
	sb.content_margin_bottom = text_inset.w
	return sb


static func apply(
	btn: Button,
	cover_variant: int,
	font_size: int = 18,
	text_inset: Vector4 = DEFAULT_TEXT_INSET,
	normal_modulate: Color = Color.WHITE,
	font_color: Color = Color.WHITE,
	with_disabled: bool = false,
	disabled_modulate: Color = Color(0.52, 0.52, 0.55, 0.78),
) -> void:
	if btn == null or not is_instance_valid(btn):
		return
	var tex := cover_texture(cover_variant)
	var normal := stylebox_from_cover(tex, normal_modulate, text_inset)
	var hover := normal.duplicate() as StyleBoxTexture
	hover.modulate_color = normal_modulate * Color(1.08, 1.06, 1.04, 1.0)
	var pressed := normal.duplicate() as StyleBoxTexture
	pressed.modulate_color = normal_modulate * Color(0.94, 0.94, 0.96, 1.0)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	if with_disabled:
		var dis := normal.duplicate() as StyleBoxTexture
		dis.modulate_color = normal_modulate * disabled_modulate
		btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", font_color)
	btn.add_theme_constant_override("h_separation", 8)
