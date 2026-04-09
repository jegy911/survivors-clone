Ana menü arka plan görseli
=======================

Bu klasöre aşağıdaki dosya adlarından BİRİNİ koy (Godot import eder):

  • main_menu_bg.png
  • main_menu_bg.jpg
  • main_menu_bg.webp

Öneri: 1920×1080 veya daha büyük; yatay kompozisyon.
Görüntü ekranı kaplar (kenar kırpma olabilir), üzerine hafif koyu film + yıldızlar gelir.

Dosya yoksa menü eski düz koyu arka plan gibi davranır (yıldızlar kalır).

Aynı dosya adayları oyun başında `ui/intro_splash` açılış ekranında da kullanılır (üzerine yalnızca ~5 sn siyah fade; intro’da ana menüdeki koyu tint yok; sonra ana menü).

“Devam etmek için…” metninin dikey/yatay yeri: `ui/intro_splash.gd` dosyasındaki `PROMPT_*` sabitleri + `ui/intro_splash.tscn` içinde `PromptLabel` → `offset_left` / `offset_right`.
