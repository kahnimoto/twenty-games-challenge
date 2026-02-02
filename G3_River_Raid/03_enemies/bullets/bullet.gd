class_name Bullet
extends Node2D

const BULLET_SPEED := 400.0
const LIFETIME := 2.0
const FLICKER_TRACE_CURVE: Curve = preload("uid://bhqmkawxhhij1")

var alive_for := 0.0

@onready var trace: Sprite2D = $Trace

func _physics_process(delta: float) -> void:
	alive_for += delta
	if alive_for >= LIFETIME:
		queue_free()
	global_position += Vector2.DOWN * BULLET_SPEED * delta
	
	trace.modulate.a = FLICKER_TRACE_CURVE.sample(inverse_lerp(0.0, LIFETIME, alive_for))
