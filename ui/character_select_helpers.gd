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


static func rich_description_unlocked(char_data: Dictionary) -> String:
	var parts: Array = []
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
		if char_data["secret"]:
			return "🔒 " + str(char_data.get("unlock_hint", "???"))
		return "🔒 " + str(char_data.get("unlock_hint", ""))
	return rich_description_unlocked(char_data)
