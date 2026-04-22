extends Node
## Sahne yolu başına havuz; serbest nesne seçimi yığın ile O(1) yaklaşık.

var _pools: Dictionary = {}


func _ensure_pool(scene_path: String) -> void:
	if _pools.has(scene_path):
		return
	var scene: PackedScene = load(scene_path)
	var pool_size: int = 40 if scene_path.contains("xp_orb") or scene_path.contains("gold_orb") else 20
	var objects: Array = []
	var free_indices: Array = []
	for i in pool_size:
		var obj: Node = scene.instantiate()
		obj.set_meta("pool_path", scene_path)
		obj.set_meta("pool_index", objects.size())
		obj.set_meta("in_pool", true)
		add_child(obj)
		obj.hide()
		if obj.has_method("reset"):
			obj.reset()
		objects.append(obj)
		free_indices.append(objects.size() - 1)
	_pools[scene_path] = {"objects": objects, "free": free_indices}


func get_object(scene_path: String) -> Node:
	_ensure_pool(scene_path)
	var p: Dictionary = _pools[scene_path]
	var objects: Array = p["objects"]
	var free: Array = p["free"]
	if free.is_empty():
		var scene: PackedScene = load(scene_path)
		var obj: Node = scene.instantiate()
		obj.set_meta("pool_path", scene_path)
		obj.set_meta("pool_index", objects.size())
		obj.set_meta("in_pool", false)
		add_child(obj)
		objects.append(obj)
		return obj
	var idx: int = free.pop_back()
	var reused: Node = objects[idx]
	reused.set_meta("in_pool", false)
	return reused


func return_object(obj: Node) -> void:
	obj.hide()
	obj.set_meta("in_pool", true)
	var path: String = str(obj.get_meta("pool_path", ""))
	if path.is_empty() or not _pools.has(path):
		return
	var p: Dictionary = _pools[path]
	var idx: int = int(obj.get_meta("pool_index", -1))
	if idx < 0:
		return
	p["free"].append(idx)
	if obj.has_method("reset"):
		obj.reset()


func reset_all() -> void:
	for scene_path in _pools:
		var objects: Array = _pools[scene_path]["objects"]
		for obj in objects:
			if is_instance_valid(obj):
				obj.queue_free()
	_pools.clear()
