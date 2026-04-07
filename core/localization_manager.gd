extends Node
## JSON tabanlı çevirileri TranslationServer'a yükler; SaveManager.locale ile senkronlar.

signal locale_changed(locale: String)

const FALLBACK_LOCALE: String = "en"
## Tek kaynak: yeni dil = satır ekle + `locales/<code>.json` + `ui.settings.lang_<code>` anahtarları.
const LANGUAGE_CATALOG: Array = [
	{"code": "tr", "label_key": "ui.settings.lang_tr", "steam": "turkish"},
	{"code": "en", "label_key": "ui.settings.lang_en", "steam": "english"},
	{"code": "zh_CN", "label_key": "ui.settings.lang_zh_CN", "steam": "schinese"},
]

func _ready() -> void:
	TranslationServer.set_fallback_locale(FALLBACK_LOCALE)
	_load_all_translations()
	var code: String
	if not FileAccess.file_exists(SaveManager.SAVE_PATH):
		code = _locale_from_os()
		_apply_locale(code, true)
	else:
		var raw: String = str(SaveManager.settings.get("locale", FALLBACK_LOCALE))
		var resolved: String = raw if _catalog_has_code(raw) else FALLBACK_LOCALE
		_apply_locale(resolved, resolved != raw)

func _load_all_translations() -> void:
	for entry in LANGUAGE_CATALOG:
		var loc: String = str(entry["code"])
		var path: String = "res://locales/%s.json" % loc
		if not FileAccess.file_exists(path):
			push_error("LocalizationManager: eksik dosya %s" % path)
			continue
		var f: FileAccess = FileAccess.open(path, FileAccess.READ)
		var text: String = f.get_as_text()
		var data: Variant = JSON.parse_string(text)
		if data == null or not (data is Dictionary):
			push_error("LocalizationManager: JSON okunamadı: %s" % path)
			continue
		var tr_res: Translation = Translation.new()
		tr_res.locale = loc
		_flatten_to_translation(data, "", tr_res)
		TranslationServer.add_translation(tr_res)

func _flatten_to_translation(d: Variant, prefix: String, tr_res: Translation) -> void:
	if d is Dictionary:
		for k in d:
			var sub: String = prefix + ("" if prefix.is_empty() else ".") + str(k)
			_flatten_to_translation(d[k], sub, tr_res)
	else:
		tr_res.add_message(prefix, str(d))

func _catalog_has_code(code: String) -> bool:
	for entry in LANGUAGE_CATALOG:
		if str(entry["code"]) == code:
			return true
	return false

## İşletim sistemi dilini katalogdaki bir `code` ile eşler; yoksa `FALLBACK_LOCALE`.
func _locale_from_os() -> String:
	var raw: String = OS.get_locale().to_lower().replace("-", "_")
	if raw.is_empty():
		return FALLBACK_LOCALE
	for entry in LANGUAGE_CATALOG:
		var code_norm: String = str(entry["code"]).to_lower().replace("-", "_")
		if raw == code_norm or raw.begins_with(code_norm + "_"):
			return str(entry["code"])
	var primary: String = raw.get_slice("_", 0).get_slice("@", 0)
	for entry in LANGUAGE_CATALOG:
		var c: String = str(entry["code"]).to_lower().replace("-", "_")
		if "_" in c:
			continue
		var c_primary: String = c.get_slice("_", 0)
		if primary == c_primary or primary == c:
			return str(entry["code"])
	if primary == "zh" and _catalog_has_code("zh_CN"):
		if raw.contains("tw") or raw.contains("hant") or raw.contains("_hk") or raw.contains("_mo"):
			return FALLBACK_LOCALE
		return "zh_CN"
	return FALLBACK_LOCALE

func _apply_locale(code: String, save: bool) -> void:
	if not _catalog_has_code(code):
		code = FALLBACK_LOCALE
	TranslationServer.set_locale(code)
	SaveManager.settings["locale"] = code
	if save:
		SaveManager.save_game()
	locale_changed.emit(code)

## Ayarlardan veya Dil sekmesinden çağrılır.
func set_locale(code: String) -> void:
	if not _catalog_has_code(code):
		code = FALLBACK_LOCALE
	if TranslationServer.get_locale() == code and str(SaveManager.settings.get("locale", "")) == code:
		return
	_apply_locale(code, true)

func get_locale() -> String:
	return TranslationServer.get_locale()

## Steam `ISteamApps::GetCurrentGameLanguage()` ile gelen kısa adlar (yayın tarafı için referans).
func get_steam_language_code(locale_code: String) -> String:
	for entry in LANGUAGE_CATALOG:
		if str(entry["code"]) == locale_code:
			return str(entry.get("steam", ""))
	return ""
