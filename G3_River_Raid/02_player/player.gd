class_name Player
extends Node2D


const MAX_LIVES = 5
const SHIP_WIDTH := 30.0
const INVUL_FRAME_DUR := 0.8

@export var modulation_curve: CurveTexture

var _viewport_rect: Vector2
var _minimal_x: float
var _maximum_x: float
var _minimal_y: float
var _maximum_y: float

var lives := MAX_LIVES
var invulnerable_time := 0.0

@onready var ship_sprite: Sprite2D = $ShipSprite
@onready var area: Area2D = $Area


func _ready():
	_viewport_rect = get_viewport_rect().size
	_minimal_x = 0.0 + SHIP_WIDTH
	_maximum_x = _viewport_rect.x - SHIP_WIDTH
	_minimal_y = _viewport_rect.y / 3.0
	_maximum_y = _viewport_rect.y - SHIP_WIDTH
	area.area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if invulnerable_time >= 0.0:
		invulnerable_time = clampf(invulnerable_time - delta, 0.0, INVUL_FRAME_DUR)
		var animation_ratio: float = inverse_lerp(INVUL_FRAME_DUR, 0.0, invulnerable_time)
		var sampled_value: float = modulation_curve.curve.sample(animation_ratio)
		ship_sprite.modulate = Color(Color.WHITE, sampled_value)


func _physics_process(_delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	global_position = Vector2(
		clampf(mouse_position.x, _minimal_x, _maximum_x),
		clampf(mouse_position.y, _minimal_y, _maximum_y)
	)


func _on_area_entered(other: Area2D) -> void:
	if other.is_in_group("bullets") and invulnerable_time <= 0.0:
		other.get_parent().queue_free()
		take_damage()
	elif other.is_in_group("upgrades"):
		other.get_parent().queue_free()
		recover_health(2)


func take_damage(amount: int = 1) -> void:
	var previous_lives := lives
	lives = clampi(lives - amount, 0, MAX_LIVES)
	if previous_lives != lives:
		Events.lives_changed.emit(lives)
		invulnerable_time = INVUL_FRAME_DUR


func recover_health(amount: int = 1) -> void:
	var previous_lives := lives
	lives = clampi(lives + amount, 0, MAX_LIVES)
	if previous_lives != lives:
		Events.lives_changed.emit(lives)
