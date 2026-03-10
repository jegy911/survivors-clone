extends Area2D

var speed = 400.0
var direction = Vector2.ZERO
var damage = 10
var lifetime = 2.0
var armor_piercing = false
var player = null

func _ready():
	$ColorRect.color = Color("#FFD700")

func _physics_process(delta):
	if not visible:
		return
	position += direction * speed * delta
	lifetime -= delta
	
	if lifetime <= 0:
		ObjectPool.return_object(self)
		return
	
	var areas = get_overlapping_areas()
	for area in areas:
		if area.has_method("take_damage"):
			if not area.is_in_group("player"):
				area.take_damage(damage)
				if player:
					EventBus.on_damage_dealt.emit(player, area, damage)
				ObjectPool.return_object(self)
				return

func init(dir: Vector2, dmg: int = 10, is_armor_piercing: bool = false, shooter = null):
	direction = dir
	damage = dmg
	armor_piercing = is_armor_piercing
	player = shooter
	lifetime = 2.0
	show()

func reset():
	direction = Vector2.ZERO
	damage = 10
	lifetime = 2.0
	armor_piercing = false
	hide()
