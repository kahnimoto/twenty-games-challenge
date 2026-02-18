class_name HealthGem
extends Control


const BOUNCY_FADE_IN = preload("uid://bycni4q00xvf0")
const BOUNCY_FALLOFF = preload("uid://durhne8m3ahdr")
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
	if _lapsed_time >= DURATION: return
	_lapsed_time = clampf(_lapsed_time + delta, 0.0, DURATION)
	_animation_ratio = inverse_lerp(0.0, DURATION, _lapsed_time)
	if on:
		indicator.modulate.a = BOUNCY_FADE_IN.sample(_animation_ratio)
		indicator.modulate.r = BOUNCY_FALLOFF.sample(_animation_ratio)
	else:
		indicator.modulate = Color(Color.WHITE, BOUNCY_FALLOFF.sample(_animation_ratio))
