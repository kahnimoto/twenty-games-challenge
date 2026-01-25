class_name Bullet
extends Node2D

const BULLET_SPEED := 700.0
const DESTROY_AT_Y := 1000.0


func _physics_process(delta: float) -> void:
	global_position += Vector2.DOWN * BULLET_SPEED * delta
	if global_position.y >= DESTROY_AT_Y:
		queue_free()
