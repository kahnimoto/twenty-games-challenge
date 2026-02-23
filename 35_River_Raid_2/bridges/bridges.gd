class_name Bridges
extends TileMapLayer


const BROKEN_END_PIECE_LEFT := Vector2i(6, 5)
const BROKEN_END_PIECE_RIGHT := Vector2i(7, 5)


func destroy_bridge_at(pos: Vector2) -> void:
	var location: Vector2i = local_to_map(pos)
	var data: TileData = get_cell_tile_data(location)
	if not data:
		location.y -= 1
		data = get_cell_tile_data(location)
	if not data:
		push_error("Cant find bridge")
		get_tree().quit(1)
		return
	assert(data.get_custom_data("is_bridge"))
	var current: Vector2i = location
	while true:
		var next_tile := get_cell_tile_data(current + Vector2i.LEFT)
		if not next_tile:
			push_error("NO TILE!")
			return
		if next_tile.get_custom_data("is_end"):
			break
		else:
			current += Vector2i.LEFT
	set_cell(current, 0, BROKEN_END_PIECE_LEFT)
	current += Vector2i.RIGHT
	while true:
		var next_tile := get_cell_tile_data(current + Vector2i.RIGHT)
		if next_tile.get_custom_data("is_end"):
			set_cell(current, 0, BROKEN_END_PIECE_RIGHT)
			break
		else:
			set_cell(current, -1, Vector2i.ZERO)
			current += Vector2i.RIGHT
