class_name Player
extends Node2D


const MAX_LIVES = 5
const SHIP_WIDTH := 30.0
const INVUL_FRAME_DUR := 0.8
const SPEED := 300.0

@export var level: Level

#@export var modulation_curve: CurveTexture
var modulation_curve: CurveTexture = preload("res://02_player/modulation_curve.tres")

var _viewport_rect: Vector2

var aiming := false:
	set(v):
		if aiming != v:
			aiming = v
			if aiming:
				Events.player_is_aiming.emit()
			else:
				Events.player_is_moving.emit()
var lives := MAX_LIVES
var invulnerable_time := 0.0

@onready var ship_sprite: Sprite2D = $ShipSprite
@onready var area: Area2D = $Area


func _ready():
	assert(level is Level)
	assert(modulation_curve is CurveTexture)
	_viewport_rect = get_viewport_rect().size
	area.area_entered.connect(_on_area_entered)
	area.body_entered.connect(_on_shape_entered)
	


func _process(delta: float) -> void:
	
	aiming = not Input.is_action_pressed("mouse_right")
	if invulnerable_time >= 0.0:
		invulnerable_time = clampf(invulnerable_time - delta, 0.0, INVUL_FRAME_DUR)
		var animation_ratio: float = inverse_lerp(INVUL_FRAME_DUR, 0.0, invulnerable_time)
		var sampled_value: float = modulation_curve.curve.sample(animation_ratio)
		ship_sprite.modulate = Color(Color.WHITE, sampled_value)


func _physics_process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	if aiming:
		pass
	else:
		var target_y = level.world_offset + mouse_position.y
		global_position.x = move_toward(global_position.x, mouse_position.x, SPEED * delta)
		global_position.y = move_toward(global_position.y, target_y, SPEED * delta)



func _on_area_entered(other: Area2D) -> void:
	if other.is_in_group("bullets") and invulnerable_time <= 0.0:
		other.get_parent().queue_free()
		take_damage()
	elif other.is_in_group("upgrades"):
		other.get_parent().queue_free()
		recover_health(2)

func _on_shape_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		take_damage(1)
	#print(body)

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
