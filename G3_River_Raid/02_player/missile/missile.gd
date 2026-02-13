class_name Missile
extends Node2D

const SPEED := 800.0
const LIFETIME := 2.0
#const FLICKER_TRACE_CURVE: Curve = preload("uid://bhqmkawxhhij1")

var alive_for := 0.0
var _direction := Vector2.UP
#@onready var trace: Sprite2D = $Trace

func _physics_process(delta: float) -> void:
	alive_for += delta
	if alive_for >= LIFETIME:
		queue_free()
	global_position += _direction * SPEED * delta
	#trace.modulate.a = FLICKER_TRACE_CURVE.sample(inverse_lerp(0.0, LIFETIME, alive_for))

func set_direction(direction: Vector2) -> void:
	_direction = direction
	rotation = direction.angle()
		
