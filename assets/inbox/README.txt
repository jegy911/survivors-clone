Geçici ham PNG / sprite düşümü
================================
Dosyaları buraya bırakın; entegrasyon sonrası ilgili kalıcı yollar:
`assets/ui/upgrade_icons/{weapons,items,evolutions}/`,
`assets/effects/`, `assets/projectiles/<silah>/` vb.

İsimlendirme: mümkünse hedef ID ile uyumlu (`<item_id>.png`, `<evo_id>_icon.png`).
Godot ilk açılışta `.import` üretir.

Not: Entegrasyon sırasında dosyalar standart `assets/` alt yollarına taşınır; Türkçe veya `_icon` sonekli ham adlar kodda kullanılan İngilizce dosya adlarıyla eşlenir (ör. dondurma fıçısı görseli → `assets/effects/freeze_barrel_icon.png`).
