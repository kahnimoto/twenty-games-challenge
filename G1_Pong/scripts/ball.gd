class_name Ball
extends CharacterBody2D


const SPEED = 200.0
const ACC = 5.0

var _speed: float

func _ready() -> void:
	_speed = SPEED

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity * _speed * delta)
	if collision:
		_speed += ACC
		velocity = -velocity.reflect(collision.get_normal())
