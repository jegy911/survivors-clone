class_name CharacterSelectHelpers
extends RefCounted
## Karakter kartı metinleri; P1/P2 seçim ekranları ortak kullanır.


static func _t(key: String) -> String:
	return TranslationServer.translate(StringName(key))


static func weapon_display_name(weapon_id: String) -> String:
	if weapon_id.is_empty():
		return ""
	var k := "codex.weapon.%s.name" % weapon_id
	var t := _t(k)
	return weapon_id if t == k else t


static func item_display_name(item_id: String) -> String:
	if item_id.is_empty():
		return ""
	var k := "codex.item.%s.name" % item_id
	var t := _t(k)
	return item_id if t == k else t


static func character_display_name(char_id: String) -> String:
	if char_id.is_empty():
		return ""
	var k := "codex.character.%s.name" % char_id
	var t := _t(k)
	return char_id if t == k else t


static func localized_unlock_hint(char_data: Dictionary) -> String:
	var cid: String = str(char_data.get("id", ""))
	var key: String = "ui.character_select.unlock." + cid
	var body: String = _t(key)
	if body == key or body.is_empty():
		if bool(char_data.get("secret", false)):
			return _t("ui.character_select.unlock_line") % _t("ui.character_select.unlock_secret_placeholder")
		return ""
	return _t("ui.character_select.unlock_line") % body


static func rich_description_unlocked(char_data: Dictionary) -> String:
	var parts: Array = []
	var cid: String = str(char_data.get("id", ""))
	var role_key := "codex.character.%s.role" % cid
	var role_t := _t(role_key)
	if role_t != role_key and not role_t.is_empty():
		var hc := str(char_data.get("hero_class", ""))
		var class_key := "ui.character_select.hero_class_label.%s" % hc
		var class_t := _t(class_key)
		var class_line := class_t if class_t != class_key else hc
		parts.append("%s — %s" % [class_line, role_t])
	if char_data["start_weapon"] != "":
		parts.append(_t("ui.character_select.line_start_weapon") % weapon_display_name(char_data["start_weapon"]))
	if char_data["start_item"] != "":
		parts.append(_t("ui.character_select.line_start_item") % item_display_name(char_data["start_item"]))
	if char_data["bonus_damage"] > 0:
		parts.append(_t("ui.character_select.line_bonus_damage") % int(char_data["bonus_damage"]))
	if char_data["bonus_hp"] > 0:
		parts.append(_t("ui.character_select.line_bonus_hp") % int(char_data["bonus_hp"]))
	if char_data["bonus_speed"] > 0:
		parts.append(_t("ui.character_select.line_bonus_speed") % int(char_data["bonus_speed"]))
	if char_data["bonus_armor"] > 0:
		parts.append(_t("ui.character_select.line_bonus_armor") % int(char_data["bonus_armor"]))
	var special: String = str(char_data.get("special", ""))
	if special != "":
		var sk := "ui.character_select.special.%s" % special
		var st := _t(sk)
		if st != sk:
			parts.append(st)
	if parts.is_empty():
		return str(char_data["description"])
	return "\n".join(parts)


static func rich_description_for_state(char_data: Dictionary, state: String) -> String:
	if state == "locked":
		return localized_unlock_hint(char_data)
	return rich_description_unlocked(char_data)
