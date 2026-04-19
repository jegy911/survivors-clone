Fan Blade — dünya içi shard (mermi) görseli
============================================
PNG’yi buraya koy:

  res://assets/projectiles/fan_blade/shard.png

Koordinat: **uç sağa** bakacak şekilde çiz (silah + shard kodu `rotation = direction.angle()` ile Area2D’yi döndürür; kama ucu +X yönünde olmalı).

`projectiles/fan_blade_shard.gd`: sahne / `Sprite2D` üzerinde doku varsa onu kullanır; yoksa bu PNG; o da yoksa `Polygon2D` yedeği.

Ölçek: `fan_blade_shard.tscn` içindeki `Sprite2D` → `scale` ve `CollisionShape2D` — ikisini tasarıma göre editörden hizala.

Oyun mantığı: `weapon_fan_blade.gd` / `weapon_ember_fan.gd` shard ömrünü **menzil ÷ hız** ile hesaplar; hasar yalnız bu mesafe boyunca. Çıkış noktası `player.get_directional_attack_spawn` (özellikle ölçeklenmiş karakter sprite’ları için).
