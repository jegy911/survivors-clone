extends Node

var pools = {}

func _ensure_pool(scene_path: String):
	if pools.has(scene_path):
		return
	pools[scene_path] = []
	var scene = load(scene_path)
	var pool_size = 40 if scene_path.contains("xp_orb") or scene_path.contains("gold_orb") else 20
	for i in pool_size:
		var obj = scene.instantiate()
		obj.set_meta("pool_path", scene_path)
		obj.set_meta("in_pool", true)
		add_child(obj)
		obj.hide()
		pools[scene_path].append(obj)

func get_object(scene_path: String) -> Node:
	_ensure_pool(scene_path)
	for obj in pools[scene_path]:
		if obj.get_meta("in_pool", false):
			obj.set_meta("in_pool", false)
			return obj
	# Havuz doluysa yeni oluştur
	var scene = load(scene_path)
	var obj = scene.instantiate()
	obj.set_meta("pool_path", scene_path)
	obj.set_meta("in_pool", false)
	add_child(obj)
	pools[scene_path].append(obj)
	return obj

func return_object(obj: Node):
	obj.hide()
	obj.set_meta("in_pool", true)
	if obj.has_method("reset"):
		obj.reset()

func reset_all():
	for scene_path in pools:
		for obj in pools[scene_path]:
			if is_instance_valid(obj):
				obj.queue_free()
	pools.clear()
