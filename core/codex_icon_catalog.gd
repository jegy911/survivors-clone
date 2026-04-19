class_name CodexIconCatalog
extends RefCounted
## Kodeks kartı / detay önizlemesi: sırayla dene — `codex_icons`, `codex_art`, sekmeye özel oyun içi yollar, silah/eşya için `upgrade_icons`.
## Tab değerleri `CollectionData.TAB_*` ile aynı (`enemy`, `weapon`, `character`, …).

const CODEX_ROOT := "res://assets/ui/codex_icons"
## İkinci standart kök (tasarım PNG’lerini buraya da koyabilirsiniz; `codex_icons` ile aynı alt klasör yapısı).
const CODEX_ART_ROOT := "res://assets/ui/codex_art"

## Harita seçimi + kodeks: harita id → önizleme PNG (tek kaynak).
const MAP_PREVIEW_TEXTURES: Dictionary = {
	"vs_map": "res://assets/zemin/zemin.png",
}


static func map_preview_path(map_id: String) -> String:
	var d: Dictionary = MAP_PREVIEW_TEXTURES
	if d.has(map_id):
		return str(d[map_id])
	if d.has("vs_map"):
		return str(d["vs_map"])
	return ""

## Kodeks `enemy` id → repoda var olan temsilci sprite (yoksa emoji).
const ENEMY_FALLBACK_TEXTURES: Dictionary = {
	"enemy": "res://assets/enemy assets/enemy1 assets/enemy1.png",
	"fast_enemy": "res://assets/enemy assets/enemy1 assets/enemy1.png",
	"tank_enemy": "res://assets/enemy assets/tank assets/tankidleleft.png",
	"dasher": "res://assets/enemy assets/dasher assets/dasherwalkleft.png",
	"healer": "res://assets/enemy assets/healer assets/healeridleleft.png",
	"exploder": "res://assets/enemy assets/exploder assets/exploderidleleft.png",
	"shield_enemy": "res://assets/enemy assets/shield assets/shieldenemywalkleft.png",
	"giant": "res://assets/enemy assets/giant assets/giantwalkleft.png",
	"ranged_enemy": "res://assets/enemy assets/ranged assets/archeridleleft.png",
}

## Kodeks `boss` id → mevcut boss sprite (ayrı reaper sanatı yoksa aynı dosya).
const BOSS_FALLBACK_TEXTURES: Dictionary = {
	"mini_boss": "res://assets/enemy assets/boss assets/bosswalkleft.png",
	"reaper": "res://assets/enemy assets/boss assets/bosswalkleft.png",
}


static func _path_codex(tab: String, id: String) -> String:
	return "%s/%s/%s.png" % [CODEX_ROOT, tab, id]


static func _path_codex_art(tab: String, id: String) -> String:
	return "%s/%s/%s.png" % [CODEX_ART_ROOT, tab, id]


static func _texture_at(path: String) -> Texture2D:
	return UpgradeIconCatalog.try_texture_at(path)


## Kodeks grid + detay için tek giriş noktası.
static func try_for_entry(entry: Dictionary) -> Texture2D:
	var tab: String = str(entry.get("tab", ""))
	var id: String = str(entry.get("id", ""))
	if tab.is_empty() or id.is_empty():
		return null
	for p in _candidate_paths(tab, id):
		var t: Texture2D = _texture_at(p)
		if t != null:
			return t
	if tab == CollectionData.TAB_WEAPON:
		return UpgradeIconCatalog.try_weapon_with_evolution_fallback(id)
	if tab == CollectionData.TAB_ITEM:
		return UpgradeIconCatalog.try_item(id)
	return null


static func _candidate_paths(tab: String, id: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	out.append(_path_codex(tab, id))
	out.append(_path_codex_art(tab, id))
	match tab:
		CollectionData.TAB_CHARACTER:
			out.append("res://characters/%s/codex.png" % id)
			out.append("res://characters/%s/%s_codex.png" % [id, id])
			out.append("res://assets/ui/character_icons/%s.png" % id)
		CollectionData.TAB_MAP:
			if MAP_PREVIEW_TEXTURES.has(id):
				out.append(str(MAP_PREVIEW_TEXTURES[id]))
			out.append("res://assets/ui/map_previews/%s.png" % id)
			out.append("res://assets/maps/%s.png" % id)
		CollectionData.TAB_ENEMY:
			if ENEMY_FALLBACK_TEXTURES.has(id):
				out.append(str(ENEMY_FALLBACK_TEXTURES[id]))
		CollectionData.TAB_BOSS:
			if BOSS_FALLBACK_TEXTURES.has(id):
				out.append(str(BOSS_FALLBACK_TEXTURES[id]))
		CollectionData.TAB_GLOSSARY:
			out.append("res://assets/ui/glossary_icons/%s.png" % id)
		_:
			pass
	return out
