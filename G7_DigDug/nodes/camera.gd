extends Camera2D


const CAMERA_FOLLOW_CURVE = preload("uid://bfbaryhx7y404")

var world_top: float
var start_pos: Vector2
var target_pos: Vector2
var camera_follow_progress := 0.0

@onready var player: Player = %Player


func _ready() -> void:
	world_top = global_position.y
	start_pos = global_position
	Events.player_position_changed.connect(_on_player_moved)


func _on_player_moved(player_pos: Vector2) -> void:
	if target_pos != player_pos:
		start_pos = global_position
		target_pos = player_pos
		camera_follow_progress = 0.0


func _process(delta: float) -> void:
	if global_position.y == target_pos.y:
		return
	elif abs(global_position.y - target_pos.y) < 0.1:
		global_position.y = target_pos.y
	else:
		camera_follow_progress = move_toward(camera_follow_progress, 1.0, delta)
		var curve_value = CAMERA_FOLLOW_CURVE.sample(camera_follow_progress)
		global_position.y = lerp(start_pos.y, target_pos.y, curve_value)
		global_position.y = max(global_position.y, world_top)

	# old logic
	# global_position.y = move_toward(global_position.y, target_pos.y, delta * SPEED)
