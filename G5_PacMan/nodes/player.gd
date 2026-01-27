class_name Player
extends Node2D

#region signals
signal moved_ended_at(location: Vector2i)
#endregion

#region constants
const DIRECTIONS: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
#endregion

#region class variables
var movement_direction := Vector2i.RIGHT
var grid_position := Vector2i.ZERO
#endregion

#region private variables
var _is_moving := false
var _player_force_moved := false
var _player_force_move_direction := Vector2.ZERO
var _player_force_move_target := Vector2i.ZERO
var _tween: Tween
var _desired_direction: Vector2i = Vector2i.ZERO
var _desired_direction_is_relative := false
#endregion

#region onready variables
@onready var visuals: Node2D = %Visuals
@onready var character_sprite: AnimatedSprite2D = %AnimatedCharacterSprite
@onready var area: Area2D = %Area2D

@onready var dungeon_tile_map: TileMapLayer

#endregion


#region virtual methods
func _ready() -> void:
	grid_position = Map.global_to_map(global_position)
	area.area_entered.connect(_on_area_entered)


func _process(_delta: float) -> void:
	set_desired_direction_from_inputs()
	move_character()


func set_desired_direction_from_inputs() -> void:
	if Input.is_action_pressed("move_down"):
		_desired_direction_is_relative = false
		_desired_direction = Vector2i.DOWN
	elif Input.is_action_pressed("move_up"):
		_desired_direction_is_relative = false
		_desired_direction = Vector2i.UP
	elif Input.is_action_pressed("move_right"):
		_desired_direction_is_relative = false
		_desired_direction = Vector2i.RIGHT
	elif Input.is_action_pressed("move_left"):
		_desired_direction_is_relative = false
		_desired_direction = Vector2i.LEFT
	#elif Input.is_action_pressed("turn_right"):
		#_desired_direction_is_relative = true
		#_desired_direction = Vector2i.RIGHT
	#elif Input.is_action_pressed("turn_left"):
		#_desired_direction_is_relative = true
		#_desired_direction = Vector2i.LEFT


func relative_direction(input: Vector2i) -> Vector2i:
	match movement_direction:
		Vector2i.RIGHT:
			return (input as Vector2).rotated(PI/2) as Vector2i
		Vector2i.DOWN:
			return (input as Vector2).rotated(PI) as Vector2i
		Vector2i.LEFT:
			return (input as Vector2).rotated(3*PI/2) as Vector2i
	return input as Vector2i


## Check for User input and move the character
## Triggers animation as well as starts the turn for the world
func move_character() -> void:
	if _is_moving:
		return
	
	# how many possible ways could it go? 
	var possible_directions: Array[Vector2i]
	for dir in DIRECTIONS:
		if not Map.is_wall(grid_position + dir):
			possible_directions.append(dir)
	
	possible_directions.erase(-movement_direction)
	if possible_directions.size() == 1:
		movement_direction = possible_directions[0]
	elif _desired_direction == Vector2i.ZERO:
		if not movement_direction in possible_directions:
			movement_direction = possible_directions.pick_random()
	else:
		#var requested_direction: Vector2i = relative_direction(_desired_direction) if _desired_direction_is_relative else 
		if _desired_direction in possible_directions:
			movement_direction = _desired_direction
		else:
			if not movement_direction in possible_directions:
				movement_direction = possible_directions.pick_random()
		_desired_direction = Vector2i.ZERO  # Use up the input

	var desired_location: Vector2i = grid_position + movement_direction
	
	# Initiate turn only once we know the player will actually move
	#Events.player_initiated_turn.emit()
	_is_moving = true
	if movement_direction.x:
		character_sprite.rotation_degrees = 0.
		character_sprite.flip_h = movement_direction.x < 0
	elif movement_direction.y:
		character_sprite.flip_h = false
		character_sprite.rotation_degrees = 90. if movement_direction.y > 0 else -90.
	grid_position = desired_location
	var desired_global_pos: Vector2 = Map.map_to_global(grid_position)
	var move_duration: float = Config.TURN_TIME
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "global_position", desired_global_pos, move_duration).set_ease(Tween.EASE_IN)
	_tween.tween_callback(moved_ended_at.emit.bind(desired_location))
	_tween.tween_property(self, "_is_moving", false, 0.0)

#endregion


#region class handlers

func _on_area_entered(_other_area: Area2D) -> void:
	#print("Encountered other area: %s" % other_area)
	pass

#endregion


#region class methods
func force_move_player(direction: Vector2, amount: int = 1) -> void:
	_player_force_moved = true
	_player_force_move_target = grid_position + ((direction * amount) as Vector2i)
	_player_force_move_direction = direction


func teleport_player(new_global_position: Vector2) -> void:
	if _tween:
		_tween.kill()
	_player_force_moved = true
	_is_moving = false
	grid_position = Map.global_to_map(new_global_position)
	global_position = new_global_position

#endregion
