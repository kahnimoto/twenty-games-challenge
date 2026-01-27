class_name Level
extends Node


var astar_grid: AStarGrid2D = AStarGrid2D.new()

var _target_positions: Array[Vector2] = []

@onready var map: TileMapLayer = %TileMapLayer
@onready var world: Node2D = %World


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	astar_grid.update()
	
	
	for marker:Marker2D in get_tree().get_nodes_in_group("path_target"):
		_target_positions.append(marker.global_position)
	
	#var from := Vector2i(13, 14)
	#var random_target: Vector2 = _target_positions.pick_random()
	#var to: Vector2i = Map.global_to_map(random_target)
	#var locations = astar_grid.get_point_path(from, to)
	Events.level_started.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for p in paths:
		if p:
			p.modulate.a -= 0.1 * delta
			if p.modulate.a <= 0.1:
				p.queue_free()


func get_wander_target() -> Vector2:
	return _target_positions.pick_random()


var paths: Array[Line2D] = []

func get_path_to_target_position(from_pos: Vector2, to_pos: Vector2) -> PackedVector2Array:
	var from: Vector2i = Map.global_to_map(from_pos)
	var to: Vector2i = Map.global_to_map(to_pos)
	var locations = astar_grid.get_point_path(from, to)
	
	var path := Line2D.new()
	path.width = 2
	path.default_color = Color(Color.RED, 0.5)
	for pos:Vector2 in locations:
		path.add_point(pos + Vector2(8, 8))
	world.add_child(path)
	paths.append(path)

	return locations
