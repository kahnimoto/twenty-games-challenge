class_name Player
extends Node2D

const MAX_LIVES = 5
const SHIP_WIDTH := 30.0
const INVUL_FRAME_DUR := 0.8
const MISSILE = preload("uid://bn112euyrf567")


@export_range(-1, 1, 0.05) var minimum_y_direction_to_shoot = -0.2
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
var muzzles: Array[Marker2D] = []

@onready var ship_sprite: Sprite2D = $ShipSprite
@onready var area: Area2D = $Area
@onready var muzzle_parent: Node2D = $Muzzles
@onready var world: Node2D = get_tree().get_first_node_in_group("world")
@onready var line_2d: Line2D = $Line2D


func _ready():
	assert(level is Level)
	assert(modulation_curve is CurveTexture)
	for c in muzzle_parent.get_children():
		muzzles.append(c as Marker2D)
	area.area_entered.connect(_on_area_entered)
	area.body_entered.connect(_on_shape_entered)
	area.body_exited.connect(_on_shape_exited)
	Events.level_loaded.connect(_on_new_level)

func _on_new_level() -> void:
	lives = MAX_LIVES


func _process(delta: float) -> void:
	shooting_cooldown -= delta
	aiming = Input.is_action_pressed("mouse_right")
	if invulnerable_time >= 0.0:
		invulnerable_time = clampf(invulnerable_time - delta, 0.0, INVUL_FRAME_DUR)
		var animation_ratio: float = inverse_lerp(INVUL_FRAME_DUR, 0.0, invulnerable_time)
		var sampled_value: float = modulation_curve.curve.sample(animation_ratio)
		ship_sprite.modulate = Color(Color.WHITE, sampled_value)
		if invulnerable_time <= 0.0:
			Effects.end_shake()

func _physics_process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	if Input.is_action_pressed("shooting"):
		shooting(mouse_position)

	if aiming or not Game.started or Game.game_over:
		pass
		
		if line_2d.visible:
			var player_position = global_position
			player_position.y -= Game.world_offset
			var direction = player_position.direction_to(mouse_position).normalized()
			line_2d.points[1] = direction * 50
	else:
		match Game.movement_type:
			Game.MovementTypes.DIRECT:
				global_position.x = mouse_position.x
				global_position.y = Game.world_offset + mouse_position.y
			Game.MovementTypes.DELAYED:
				var target := Vector2(mouse_position.x, Game.world_offset + mouse_position.y)
				var move: Vector2 = target - global_position
				global_position += move * delta * 2
			Game.MovementTypes.CONSTANT:
				var target := Vector2(mouse_position.x, Game.world_offset + mouse_position.y)
				var move: Vector2 = target - global_position
				if move.length() < 10:
					global_position.x = mouse_position.x
					global_position.y = Game.world_offset + mouse_position.y
				else:
					global_position += move.normalized() * delta  * Game.movement_speed
			Game.MovementTypes.INDEPENDANT:
				var target_y: float = Game.world_offset + mouse_position.y
				global_position.x = move_toward(global_position.x, mouse_position.x, Game.movement_speed * delta)
				global_position.y = move_toward(global_position.y, target_y, Game.movement_speed * delta)
	
	if _is_over_land and invulnerable_time <= 0.0:
		take_damage(1)

	if global_position.y > Game.world_offset + get_viewport_rect().size.y:
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

#region shooting
var shooting_reload_time := 0.5
var shooting_cooldown := 0.1
var shooting_muzzle_left := true
#endregion

func shooting(mouse_position: Vector2) -> void:
	if shooting_cooldown > 0.0:
		return
	
	var spawn_point = muzzles[0 if shooting_muzzle_left else 1].global_position
	
	var direction := Vector2.UP
	if aiming:
		var orientation: Vector2 = spawn_point - Vector2(0., Game.world_offset)
		direction = orientation.direction_to(mouse_position).normalized()
		if direction.y > minimum_y_direction_to_shoot:
			direction = Vector2.UP
			
	shooting_cooldown = shooting_reload_time
	shooting_muzzle_left = not shooting_muzzle_left

	var missile := MISSILE.instantiate() as Missile
	missile.set_direction(direction)
	world.add_child(missile)
	missile.global_position = spawn_point


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
