extends TileMap

signal click_tile(name, pos)

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const HALF_TILE_SIZE = 32

func get_tile_name(pos: Vector2):
	var mpos = world_to_map(pos)
	var tid = get_cellv(mpos)
	var lpos = map_to_world(mpos) + Vector2(HALF_TILE_SIZE, HALF_TILE_SIZE)
	return [tile_set.tile_get_name(tid) if tid != -1 else "", lpos]

func _input(event: InputEvent) -> void:
	var mpos = get_local_mouse_position()
	if event.is_action_pressed('left_click'):
		var tile = get_tile_name(mpos)
		print("left_click:", tile)
		if tile[0] != "":
			emit_signal("click_tile", tile[0], tile[1])

func set_tile(name: String, pos: Vector2) -> void:
	var tid = tile_set.find_tile_by_name(name)
	var mpos = world_to_map(pos)
	set_cellv(mpos, tid)
	
func _physics_process(delta: float) -> void:
	pass

func _on_LevelMap_click_tile(name, pos) -> void:
	pass # Replace with function body.
