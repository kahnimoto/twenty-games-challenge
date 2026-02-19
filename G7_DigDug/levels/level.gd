class_name Level
extends Node


const TILE_COLLECTION := 1
const TILE_SCAFFOLD := 1
const TILE_SCAFFOLD_LEGGS := 2

@export var tilemap: TileMapLayer
@export var object_tilemap: TileMapLayer


func _ready() -> void:
	Events.dig_started.connect(_on_dig_started)
	Events.dig_complete.connect(_on_dig_complete)
	Events.scaffold_requested.connect(_on_player_requested_scaffold)


#region event handlers
func _on_dig_started(_position: Vector2) -> void:
	var location = tilemap.local_to_map(_position)
	var tile = get_tile_instance(object_tilemap, location)
	if tile:
		tile.dig()
		return
	var data: TileData = tilemap.get_cell_tile_data(location)
	if data:
		var strength: float = data.get_custom_data("strength")
		await get_tree().create_timer(0.2 * strength).timeout
		Events.dig_complete.emit(_position)
	else:
		push_warning("Dug empty air")
		await get_tree().create_timer(1.0).timeout
		Events.dig_complete.emit(Vector2.ZERO)


func _on_dig_complete(_position: Vector2) -> void:
	var location = tilemap.local_to_map(_position)
	var data: TileData = tilemap.get_cell_tile_data(location)
	if not data:
		return
	var terrain := data.terrain
	var terrain_set := data.terrain_set
	var tile_type: StringName = data.get_custom_data("type") as StringName
	var diggable := data.get_custom_data("diggable") as bool
	if diggable:
		#print("Digging: %s %d, %d ( %d / %d )" % [tile_type, location.x, location.y, terrain, terrain_set])
		tilemap.set_cells_terrain_connect([location], 0, -1)
	else:
		print("TOO HARD: %s %d, %d ( %d / %d )" % [tile_type, location.x, location.y, terrain, terrain_set])


func _on_player_requested_scaffold(_position: Vector2) -> void:
	var location: Vector2i = tilemap.local_to_map(_position)
	var has_supported_floor := false
	var check_location := location
	var support_levels := Game.scaffold_support_levels + 1
	while true:
		if support_levels <= 0:
			break
		check_location += Vector2i.DOWN
		support_levels -= 1
		if is_cell_open(check_location):
			continue
		var data: TileData = tilemap.get_cell_tile_data(check_location)
		if not data:
			continue
		var lava: bool = data.get_custom_data("lava")
		if lava:
			break # cant support
		var diggable: bool = data.get_custom_data("diggable")
		if diggable:
			has_supported_floor = true
			break
	if not has_supported_floor:
		# @TODO player feedback?
		return
	if not is_cell_open(location):
		return
	tilemap.set_cell(location, TILE_COLLECTION, Vector2i.ZERO, TILE_SCAFFOLD)
	await SFX.build()
	while true:
		location += Vector2i.DOWN
		if is_cell_open(location):
			tilemap.set_cell(location, TILE_COLLECTION, Vector2i.ZERO, TILE_SCAFFOLD_LEGGS)
			await SFX.build_extra()
		else:
			break
#endregion


func get_tile_instance(map: TileMapLayer, location: Vector2i) -> Variant:
	var source_id = map.get_cell_source_id(location)
	if source_id > -1:
		var scene_source = map.tile_set.get_source(source_id)
		if scene_source is TileSetScenesCollectionSource:
			for child in map.get_children():
				if child is Node2D and map.local_to_map(child.global_position) == location:
					return child
	return null


func is_cell_open(location: Vector2i) -> bool:
	var source_id := tilemap.get_cell_source_id(location)
	if source_id == -1:
		return true
	var cell = tilemap.get_cell_alternative_tile(location)
	if source_id == TILE_COLLECTION and cell == TILE_SCAFFOLD_LEGGS:
		return true
	return false


func is_cell_diggable(location: Vector2i) -> bool:
	if is_cell_open(location):
		return false
	var data: TileData = tilemap.get_cell_tile_data(location)
	return data and data.get_custom_data("diggable") as bool


func dig(position: Vector2) -> bool:
	var location: Vector2i = tilemap.local_to_map(position)
	if not is_cell_diggable(location):
		await get_tree().create_timer(0.15).timeout
		return true
	var data: TileData = tilemap.get_cell_tile_data(location)
	var strength: int = data.get_custom_data("strength")
	assert(strength is int and strength >= 0 and strength <= 3, "Improper configured tile")
	if strength == 0:
		push_warning("Dug at undiggable")
		await get_tree().create_timer(0.15).timeout
		return true
	if strength > Game.pickaxe_level:
		SFX.hardness()
		Events.tried_to_digg_too_hard.emit()
		await get_tree().create_timer(0.15).timeout
		return true
	else:
		SFX.dig()
	Events.dig_started.emit(position)
	await Events.dig_complete
	return true
