extends Node
## Canlı düşman listesini tutar; `get_nodes_in_group("enemies")` tekrarını ve maliyetini azaltır.
## `get_enemies()` işlem karesi başına bir kez anlık görüntü oluşturur.

var _live: Array = []
var _id_to_index: Dictionary = {}

var _snapshot: Array = []
var _live_version: int = 0
var _cached_version: int = -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func register_enemy(enemy: Node) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	var id: int = enemy.get_instance_id()
	if _id_to_index.has(id):
		return
	_id_to_index[id] = _live.size()
	_live.append(enemy)
	_live_version += 1


func unregister_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	var id: int = enemy.get_instance_id()
	if not _id_to_index.has(id):
		return
	var idx: int = _id_to_index[id]
	_id_to_index.erase(id)
	var last: int = _live.size() - 1
	if idx != last:
		var moved: Node = _live[last]
		_live[idx] = moved
		_id_to_index[moved.get_instance_id()] = idx
	_live.remove_at(last)
	_live_version += 1


func get_live_count() -> int:
	return _live.size()


func get_enemies() -> Array:
	if _cached_version != _live_version:
		_cached_version = _live_version
		_snapshot.clear()
		for e in _live:
			if is_instance_valid(e):
				_snapshot.append(e)
	return _snapshot
