extends Node
## JSON tabanlı çevirileri TranslationServer'a yükler; SaveManager.locale ile senkronlar.

signal locale_changed(locale: String)

const SUPPORTED: Array[String] = ["tr", "en"]
const FALLBACK_LOCALE: String = "en"

func _ready() -> void:
	_load_all_translations()
	var code: String = str(SaveManager.settings.get("locale", "tr"))
	_apply_locale(code, false)

func _load_all_translations() -> void:
	for loc in SUPPORTED:
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

func _apply_locale(code: String, save: bool) -> void:
	if not SUPPORTED.has(code):
		code = FALLBACK_LOCALE
	TranslationServer.set_locale(code)
	SaveManager.settings["locale"] = code
	if save:
		SaveManager.save_game()
	locale_changed.emit(code)

## Ayarlardan veya Dil sekmesinden çağrılır.
func set_locale(code: String) -> void:
	if not SUPPORTED.has(code):
		code = FALLBACK_LOCALE
	if TranslationServer.get_locale() == code and str(SaveManager.settings.get("locale", "")) == code:
		return
	_apply_locale(code, true)

func get_locale() -> String:
	return TranslationServer.get_locale()
