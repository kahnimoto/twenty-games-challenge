extends Node

const TILE_COLLECTION := 1
const TILE_SCAFFOLD := 1
const TILE_SCAFFOLD_LEGGS := 2

@export var tilemap: TileMapLayer

func _ready() -> void:
	Events.dig_started.connect(_on_player_digging)
	Events.scaffold_requested.connect(_on_player_requested_scaffold)

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


func _on_player_requested_scaffold(_position: Vector2) -> void:
	var location = tilemap.local_to_map(_position)
	var data: TileData = tilemap.get_cell_tile_data(location)
	if data:
		return
	print("Requesting scaffold")
	tilemap.set_cell(location, TILE_COLLECTION, Vector2i.ZERO, TILE_SCAFFOLD)
	while true:
		location += Vector2i.DOWN
		data = tilemap.get_cell_tile_data(location)
		var source_id := tilemap.get_cell_source_id(location)
		if source_id != -1 or data:
			break
		else:
			tilemap.set_cell(location, TILE_COLLECTION, Vector2i.ZERO, TILE_SCAFFOLD_LEGGS)
