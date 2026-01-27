class_name Player
extends CharacterBody2D


const DEFAULT_SPEED := 300.0
const LEFT_MOVE := Game.HALF_AREA - Game.DEADZONE
const RIGHT_MOVE := Game.HALF_AREA + Game.DEADZONE
const REAL_PLAYER_SIZE := 58.0

static var current_size := REAL_PLAYER_SIZE

@export var hud: HUD

var _speed: float = DEFAULT_SPEED
var _mouse_mode := true
var _desired_mouse_position: float

@onready var upgrade_pickup: Area2D = $UpgradePickup
@onready var rect: NinePatchRect = $NinePatchRect
@onready var collision_shape: RectangleShape2D = $UpgradePickup/CollisionShape2D.shape
@onready var side_col_shape: RectangleShape2D = $PlayerSideDetector/CollisionShape2D.shape
@onready var sprite: Sprite2D = $Sprite2D
@onready var player_side_detector: Area2D = $PlayerSideDetector


func _ready() -> void:
	upgrade_pickup.area_entered.connect(_on_pickup)
	rect.custom_minimum_size.x = REAL_PLAYER_SIZE
	collision_shape.size.x = REAL_PLAYER_SIZE
	side_col_shape.size.x = REAL_PLAYER_SIZE + 16
	player_side_detector.body_entered.connect(_on_ball_entered_side)


func _process(delta: float) -> void:
	if _mouse_mode:
		_desired_mouse_position = get_viewport().get_mouse_position().x
		global_position.x = _desired_mouse_position
		hud.apply_indicator(_desired_mouse_position)
	else:
		var dir := Input.get_axis("left", "right")
		if dir == 0.0:
			hud.apply_indicator(Game.HALF_AREA)
		else:
			var desired_position: float = global_position.x + (dir * delta * _speed)
			global_position.x = clampf(desired_position, Game.MIN_X, Game.MAX_X)
			hud.apply_indicator(0.0 if dir < 0.0 else Game.MAX_X)


func increase_speed(multiplier: float, duration: float) -> void:
	assert(multiplier >= 0.5 and multiplier <= 10.0)
	assert(duration >= 0.5 and duration <= 60.0)
	_speed = DEFAULT_SPEED * multiplier
	await get_tree().create_timer(duration).timeout
	_speed = DEFAULT_SPEED
	# TODO maybe picking up another should extend the time of faster paddle instead


func change_size(multiplier: float, duration: float) -> void:
	assert(multiplier >= 0.5 and multiplier <= 3.0)
	assert(duration >= 0.5 and duration <= 60.0)
	rect.custom_minimum_size.x = REAL_PLAYER_SIZE * multiplier
	collision_shape.size.x = REAL_PLAYER_SIZE * multiplier
	side_col_shape.size.x = collision_shape.size.x + 16
	Player.current_size = rect.custom_minimum_size.x


func revert_size() -> void:
	rect.custom_minimum_size.x = REAL_PLAYER_SIZE
	collision_shape.size.x = REAL_PLAYER_SIZE
	side_col_shape.size.x = REAL_PLAYER_SIZE + 16
	Player.current_size = REAL_PLAYER_SIZE


func _on_pickup(other: Area2D) -> void:
	assert(other is Upgrade)
	Game.apply_upgrade((other as Upgrade).data)
	other.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_mode"):
		_mouse_mode = not _mouse_mode
		if _mouse_mode:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			#hud.show_mouse_indicator()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			#hud.hide_mouse_indicators()

func _on_ball_entered_side(body: PhysicsBody2D) -> void:
	assert(body is Ball)
	(body as Ball).set_ball_as_too_low_to_catch()
