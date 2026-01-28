class_name Level
extends Node


var astar_grid: AStarGrid2D = AStarGrid2D.new()

var _target_positions: Array[Vector2] = []
var _crumbs_total: int
var _crumbs_left: int

@onready var map: TileMapLayer = %TileMapLayer
@onready var world: Node2D = %World
@onready var player: Player = %Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_astar()
	assert(astar_grid is AStarGrid2D)
	assert(player is Player)
	player.entered_square.connect(_on_player_entered_square)
	Events.level_started.emit(_crumbs_total)


func _on_player_entered_square(location: Vector2i) -> void:
	#if Map.is_crumb(location):
	if Map.switch_tile_to_normal_ground(location):
		_crumbs_left -= 1
		Events.crumb_eaten.emit(_crumbs_left)
	if _crumbs_left <= 0:
		Events.level_completed.emit()

func setup_astar() -> void:
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = map.tile_set.tile_size
	astar_grid.region = Rect2i(0, 0, 32, 32)  # TODO grab used from Map or harcode?
	
	astar_grid.update()
	
	for coord:Vector2i in map.get_used_cells():
		if coord.x < 0 or coord.x >= 32 or coord.y < 0 or coord.y >= 32:
			continue
		var data = map.get_cell_tile_data(coord)
		if data and data.get_custom_data("obstacle"):
			astar_grid.set_point_solid(coord)
		elif data and data.get_custom_data("crumb"):
			_crumbs_total += 1
			_crumbs_left += 1
	
	astar_grid.update()
		
	for marker:Marker2D in get_tree().get_nodes_in_group("path_target"):
		_target_positions.append(marker.global_position)


func get_wander_target() -> Vector2:
	return _target_positions.pick_random()



func get_path_to_target_position(from_pos: Vector2, to_pos: Vector2) -> PackedVector2Array:
	var from: Vector2i = Map.global_to_map(from_pos)
	var to: Vector2i = Map.global_to_map(to_pos)
	var locations = astar_grid.get_point_path(from, to)
	return locations
