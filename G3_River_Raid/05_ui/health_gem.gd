class_name HealthGem
extends Control


# A 2D curve from 0.0 to 1.0 in both axies
const HIDE_CURVE: CurveTexture = preload("uid://bbkcrbu1ugbe1")
const SHOW_CURVE: CurveTexture = preload("uid://dlltqhn0b1d83")

# How long the animation happens over
const DURATION: float = 0.5

## Toggle this health bar "on" or "off", if value changes resets animation
var on := true:
	set(v):
		if on != v:
			on = v
			_lapsed_time = 0.0 

# Value from 0.0 to 1.0 used to pick a value from the curve
var _animation_ratio: float
# Timer from 0.0 to DURATION
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
		indicator.modulate.a = SHOW_CURVE.curve.sample(_animation_ratio)
		indicator.modulate.r = SHOW_CURVE.curve.sample(_animation_ratio)
	else:
		#indicator.modulate.a = HIDE_CURVE.curve.sample(_animation_ratio)
		indicator.modulate = Color(Color.WHITE, HIDE_CURVE.curve.sample(_animation_ratio))
