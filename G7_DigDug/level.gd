extends Node

@export var tilemap: TileMapLayer

func _ready() -> void:
	Events.dig_started.connect(_on_player_digging)

func _on_player_digging(_position: Vector2) -> void:
	var location = tilemap.local_to_map(_position)
	var data: TileData = tilemap.get_cell_tile_data(location)
	if not data:
		#push_warning("NO TILEDATA for %d, %d" % [location.x, location.y])
		return
	var terrain := data.terrain
	var terrain_set := data.terrain_set
	var tile_type: StringName = data.get_custom_data("type") as StringName
	var diggable := data.get_custom_data("diggable") as bool
	if diggable:
		print("Digging: %s %d, %d ( %d / %d )" % [tile_type, location.x, location.y, terrain, terrain_set])
		tilemap.set_cells_terrain_connect([location], 0, -1)
	else:
		print("TOO HARD: %s %d, %d ( %d / %d )" % [tile_type, location.x, location.y, terrain, terrain_set])
		
#A simple workaround that I’ve found is to call .erase_cell() then .set_cell() on each filled cell returned by .get_surrounding_cells() in my EraseWall function. It feels hacky, but terrain connections now function as expected.
