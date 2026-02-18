class_name HealthGem
extends Control


const HEALTH_GAME_FLICKER_OFF_CURVE: Curve = preload("uid://bq5yg5eygja63")
const HEALTH_GEM_APPEAR_CURVE: Curve = preload("uid://bx6x463m6ksgf")
const DURATION: float = 0.5

var on := true:
	set(v):
		if on != v:
			on = v
			_lapsed_time = 0.0 
var _animation_ratio: float
var _lapsed_time: float

@onready var indicator: TextureRect = $Indicator


func _process(delta: float) -> void:
	if _lapsed_time >= DURATION: return  # No change currently requested
	# Update time by adding frame time, never go outside of 0 to Duration
	_lapsed_time = clampf(_lapsed_time + delta, 0.0, DURATION)
	# Map the duration of the animation to a value between 0.0 and 1.0
	_animation_ratio = inverse_lerp(0.0, DURATION, _lapsed_time)
	# Since we reuse the same curve that starts at 1 and ends at 0, 
	# we revert it when we want to toggle "on" the health
	if on:
		indicator.modulate.a = HEALTH_GEM_APPEAR_CURVE.sample(_animation_ratio)
		indicator.modulate.r = HEALTH_GEM_APPEAR_CURVE.sample(_animation_ratio)
	else:
		#indicator.modulate.a = HIDE_CURVE.curve.sample(_animation_ratio)
		indicator.modulate = Color(Color.WHITE, HEALTH_GAME_FLICKER_OFF_CURVE.sample(_animation_ratio))
