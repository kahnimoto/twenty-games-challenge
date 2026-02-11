class_name Player
extends Node2D

const MAX_LIVES = 5
const SHIP_WIDTH := 30.0
const INVUL_FRAME_DUR := 0.8

@export var level: Level
#@export var modulation_curve: CurveTexture
var modulation_curve: CurveTexture = preload("res://02_player/modulation_curve.tres")

var aiming: bool = true:
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
	area.area_entered.connect(_on_area_entered)
	area.body_entered.connect(_on_shape_entered)
	area.body_exited.connect(_on_shape_exited)
	Events.level_loaded.connect(_on_new_level)

func _on_new_level() -> void:
	lives = MAX_LIVES


func _process(delta: float) -> void:
	
	aiming = Input.is_action_pressed("mouse_right")
	if invulnerable_time >= 0.0:
		invulnerable_time = clampf(invulnerable_time - delta, 0.0, INVUL_FRAME_DUR)
		var animation_ratio: float = inverse_lerp(INVUL_FRAME_DUR, 0.0, invulnerable_time)
		var sampled_value: float = modulation_curve.curve.sample(animation_ratio)
		ship_sprite.modulate = Color(Color.WHITE, sampled_value)


func _physics_process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	if aiming or not Game.started or Game.game_over:
		pass
	else:
		match Game.movement_type:
			Game.MovementTypes.DIRECT:
				global_position.x = mouse_position.x
				global_position.y = level.world_offset + mouse_position.y
			Game.MovementTypes.DELAYED:
				var target := Vector2(mouse_position.x, level.world_offset + mouse_position.y)
				var move: Vector2 = target - global_position
				global_position += move * delta * 2
			Game.MovementTypes.CONSTANT:
				var target := Vector2(mouse_position.x, level.world_offset + mouse_position.y)
				var move: Vector2 = target - global_position
				if move.length() < 10:
					global_position.x = mouse_position.x
					global_position.y = level.world_offset + mouse_position.y
				else:
					global_position += move.normalized() * delta  * Game.movement_speed
			Game.MovementTypes.INDEPENDANT:
				var target_y: float = level.world_offset + mouse_position.y
				global_position.x = move_toward(global_position.x, mouse_position.x, Game.movement_speed * delta)
				global_position.y = move_toward(global_position.y, target_y, Game.movement_speed * delta)
	
	if _is_over_land and invulnerable_time <= 0.0:
		take_damage(1)

	if global_position.y > level.world_offset + get_viewport_rect().size.y:
		take_damage(99)


func _on_area_entered(other: Area2D) -> void:
	if other.is_in_group("bullets") and invulnerable_time <= 0.0:
		other.get_parent().queue_free()
		take_damage()
	elif other.is_in_group("upgrades"):
		other.get_parent().queue_free()
		recover_health(2)


var _is_over_land := false
func _on_shape_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		take_damage(1)
		_is_over_land = true


func _on_shape_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		_is_over_land = false


func take_damage(amount: int = 1) -> void:
	var previous_lives := lives
	lives = clampi(lives - amount, 0, MAX_LIVES)
	if previous_lives != lives:
		Effects.camera_shake()
		Events.player_took_damage.emit()
		Events.lives_changed.emit(lives)
		invulnerable_time = INVUL_FRAME_DUR


func recover_health(amount: int = 1) -> void:
	var previous_lives := lives
	lives = clampi(lives + amount, 0, MAX_LIVES)
	if previous_lives != lives:
		Events.lives_changed.emit(lives)
