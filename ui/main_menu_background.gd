class_name MainMenuBackground
extends RefCounted
## Ana menü ve giriş ekranı ortak: `assets/ui/README_MAIN_MENU_BG.txt`

const CANDIDATES: PackedStringArray = [
	"res://assets/ui/main_menu_bg.png",
	"res://assets/ui/main_menu_bg.jpg",
	"res://assets/ui/main_menu_bg.webp",
]


static func load_texture() -> Texture2D:
	for path in CANDIDATES:
		if not ResourceLoader.exists(path):
			continue
		var res: Resource = load(path)
		if res is Texture2D:
			return res as Texture2D
	return null
