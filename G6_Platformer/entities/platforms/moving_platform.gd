class_name MovingPlatform
extends AnimatableBody2D

@export var speed := 50.0

var path: Array[Vector2] = []
var nodes: int = 0
var target: int = 0
var current_direction: Vector2
var velocity: Vector2

func _ready() -> void:
	for child:Node2D in get_children():
		if child is Marker2D:
			path.append(child.global_position)
	nodes = path.size()


func _physics_process(delta: float) -> void:
	if nodes < 2:
		return
	var left_to_target: float = global_position.distance_to(path[target])
	if left_to_target < speed * delta:
		global_position = path[target]
		target = (target + 1) % nodes
		current_direction = global_position.direction_to(path[target])
		velocity = current_direction * left_to_target
	else:
		velocity = current_direction * speed * delta
		global_position += velocity
 
