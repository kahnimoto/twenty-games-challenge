class_name Player
extends CharacterBody2D


@export var tilemap: TileMapLayer

#region movement config
const SPEED := 200.0
const JUMP_VELOCITY := -230.0
const DOUBLE_JUMP_VELOCITY := JUMP_VELOCITY
const COYOTE_DURATION := 0.25 # About 9 frames at 60fps
const COYOTE_DURATION_FROM_WALL_GRAB := 0.45
const JUMP_BUFFER_DURATION := 0.1
const GROUND_ACCELERATION := 1200.0
const GROUND_FRICTION := 1000.0
const AIR_ACCELERATION := 400.0
const AIR_FRICTION := 300.0
const WALL_SLIDE_SPEED := 0.25
const GO_DOWN_SPEED := 3.0
const GRAVITY_WHEN_HOLDING_JUMP := 0.4
const GRAVITY_WHEN_FALLING := 1.5
const WALL_JUMP_AWAY_ADJUSTMENT := 0.85
#endregion

#region state variables
var _jump_buffer_timer := 0.0
var _coyote_timer := 0.0
var _is_landing := false
var _double_jump_used := false
var _was_in_air := true
var _is_climbing_ledge := false
var _gravity_modifier := 1.0
var _platform: MovingPlatform
#endregion

#region nodes
@onready var sprite: AnimatedSprite2D = %CharacterSprite
@onready var jetpack_particles: GPUParticles2D = %JetpackParticles
@onready var orientation: Node2D = $Orientation
@onready var wall_check: RayCast2D = %WallCheck
@onready var ground_check: RayCast2D = %GroundCheck
@onready var ledge_check: RayCast2D = %LedgeCheck
@onready var jump_sounds: AudioStreamPlayer2D = %JumpSounds
@onready var landing_sound: AudioStreamPlayer2D = %LandingSound

#endregion

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	var just_landed: bool = _was_in_air and is_on_floor()
	var on_ground = is_on_floor()
	var direction := Input.get_axis("move_left", "move_right")
	var grabbing_wall := orientation.scale.x == direction and _check_wall_grab()
	var grabbing_platform := _check_platform_grab()
	var jumping := Input.is_action_just_pressed("jump")
	var on_wall := grabbing_wall and not _is_climbing_ledge
	var climbing := on_wall and jumping and not ledge_check.is_colliding()
	
	#if not grabbing_wall and not on_wall and not climbing and jumping and not ledge_check.is_colliding() and _check_wall_grab():
		#_just_missed_ledge = true
	
	_update_timers(delta, on_ground, on_wall, jumping, climbing)
	_vertical_movement(delta, on_ground, on_wall, jumping, climbing, grabbing_platform)
	_horizontal_movement(delta, on_ground, on_wall, jumping, climbing)
	move_and_slide()
	_adjust_animation(just_landed)
	_was_in_air = not on_ground


func _update_timers(delta: float, on_ground: bool, on_wall: bool, jumping: bool, climbing: bool) -> void:
	if on_wall:
		_coyote_timer = COYOTE_DURATION_FROM_WALL_GRAB
	elif on_ground:
		_coyote_timer = COYOTE_DURATION # Reset timer while on ground
	else:
		_coyote_timer -= delta # Count down while in air
	if jumping or climbing:
		_jump_buffer_timer = JUMP_BUFFER_DURATION
	else:
		_jump_buffer_timer -= delta


func _vertical_movement(delta: float, on_ground: bool, on_wall: bool, jumping: bool, climbing: bool, grabbing_platform: bool) -> void:
	if climbing:
		_is_climbing_ledge = true
		velocity.y = JUMP_VELOCITY
		sprite.play("jumping")
		jump_sounds.play()
	elif on_ground or (on_wall and jumping and not climbing):
		if _jump_buffer_timer > 0. and _coyote_timer >= 0.:
			velocity.y = JUMP_VELOCITY
			_jump_buffer_timer = 0.
			_is_landing = false
			_coyote_timer = 0.
	else:
		if grabbing_platform and not jumping:
			velocity.y = _platform.velocity.y
			
		elif not _double_jump_used and jumping:
			jetpack_particles.emitting = true
			velocity.y = DOUBLE_JUMP_VELOCITY
			_is_landing = false
			_double_jump_used = true
		elif Input.is_action_just_pressed("go_down") and on_wall:
			velocity.y = _get_modified_gravity() * delta * WALL_SLIDE_SPEED
		elif Input.is_action_pressed("go_down"):
			velocity.y += _get_modified_gravity() * delta * GO_DOWN_SPEED
		elif on_wall:
			_double_jump_used = false
			on_ground = true
			_coyote_timer = 0.
			velocity = Vector2.ZERO
		elif velocity.y < 0.:
			if Input.is_action_pressed("jump"):
				velocity.y += _get_modified_gravity() * delta * GRAVITY_WHEN_HOLDING_JUMP
			else:
				velocity.y += _get_modified_gravity() * delta
		else:
			velocity.y += _get_modified_gravity() * delta * GRAVITY_WHEN_FALLING


func _get_modified_gravity() -> float:
	var gravity_vector := get_gravity()
	return gravity_vector.y * _gravity_modifier


func _horizontal_movement(delta: float, on_ground: bool, on_wall: bool, jumping: bool, climbing: bool) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var acceleration := GROUND_ACCELERATION if on_ground else AIR_ACCELERATION
	if Input.is_action_pressed("go_down"):
		velocity.x = 0.0
	elif climbing:
		velocity.x = 0.0
	elif on_wall and not jumping:
		velocity.x = 0.0
	elif on_wall and jumping:
		velocity.x = -direction * SPEED * WALL_JUMP_AWAY_ADJUSTMENT
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
		else: 
			var friction := GROUND_FRICTION if on_ground else AIR_FRICTION
			velocity.x = move_toward(velocity.x, 0, friction * delta)


func _check_wall_grab() -> bool:
	return wall_check.is_colliding() and not ground_check.is_colliding()


func _check_platform_grab() -> bool:
	if not wall_check.is_colliding():
		return false
	var c = wall_check.get_collider()
	if c is MovingPlatform:
		_platform = c as MovingPlatform
		return true
	return false

func _adjust_animation(just_landed: bool) -> void:
	if velocity.x != 0.0:
		orientation.scale.x = -1. if velocity.x < 0. else 1.0

	# Figure out if we need to switch to landing
	if just_landed:
		_is_climbing_ledge = false
		_is_landing = true
		sprite.play("landing")
		landing_sound.play()
		sprite.scale.y = 1.0
		_double_jump_used = false

	if _is_landing:
		return
	
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			if sprite.animation != "walking":
				sprite.play("walking")
		else:
			sprite.play("default")
		sprite.scale.y = 1.0
	else:
		if velocity.y < 0:
			if sprite.animation != "jumping":
				sprite.play("jumping")
				jump_sounds.play()
		else:
			if sprite.animation != "falling":
				sprite.play("falling")
			if jetpack_particles.emitting == true:
				jetpack_particles.emitting = false
		var stretch: float = remap(abs(velocity.y), 0., 800, 1.0, 1.3)
		sprite.scale.y = stretch


func _on_animation_finished() -> void:
	if sprite.animation == "landing":
		_is_landing = false
		_adjust_animation(false)
