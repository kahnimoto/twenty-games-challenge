extends Node


const TILE_WITH_PIT := Vector2i(9,6)
const TILE_WITH_BRIDGE := Vector2i(9,3)
const FLOOR_DELAY_DEFAULT := 2
const TILE_SIZE := 16.0

var _tilemap: TileMapLayer


## Convert an entity's global position to their Map Cordinates
func global_to_map(global: Vector2) -> Vector2i:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var grid_position := _tilemap.local_to_map(global)
	return grid_position


## Convert an entit's map grid coordinates to a equivalient global position
func map_to_global(grid_position: Vector2i) -> Vector2i:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var actual_position := _tilemap.map_to_local(grid_position)
	return actual_position - Vector2(8., 8.)


## Check if the specified map coordinate is a wall
func is_wall(location: Vector2i) -> bool:
	return _check_for_bool_custom_data(location, "wall")


## Returns the number of turns this tile will stay after walked on
func get_tile_floor_delay(location: Vector2i) -> int:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var data := _tilemap.get_cell_tile_data(location)
	if not data:
		push_warning("Looking up data on a tile without data")
		return FLOOR_DELAY_DEFAULT
	var decay: int = data.get_custom_data("decay")
	return decay

# Look up a custom data bool type
func _check_for_bool_custom_data(location: Vector2i, data_name: String) -> bool:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var data := _tilemap.get_cell_tile_data(location)
	if not data:
		push_warning("Why checking invalid location?")
		return false
	return data.get_custom_data(data_name)


# Ensure we have access to the current active tilmape in the level
func _grab_tilemap_from_active_scene() -> void:
	_tilemap = get_tree().get_first_node_in_group("tilemap")
	if _tilemap:
		assert(_tilemap is TileMapLayer)
