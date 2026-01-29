class_name Player
extends CharacterBody2D


@export var tilemap: TileMapLayer

const SPEED := 200.0
const JUMP_VELOCITY := -230.0
const DOUBLE_JUMP_VELOCITY := JUMP_VELOCITY
const COYOTE_DURATION := 0.25 # About 9 frames at 60fps
const COYOTE_DURATION_FROM_WALL_GRAB := 0.45
const JUMP_BUFFER_DURATION := 0.1
const GROUND_ACCELERATION := 1200.0
const GROUND_FRICTION := 1000.0
const AIR_ACCELERATION := 400.0
const AIR_FRICTION := 0.8

var _jump_buffer_timer := 0.0
var _coyote_timer := 0.0
var _is_landing := false
var _double_jump_used := false
var _was_in_air := true
var _is_climbing_ledge := false

@onready var sprite: AnimatedSprite2D = %CharacterSprite
@onready var jetpack_particles: GPUParticles2D = %JetpackParticles
@onready var orientation: Node2D = $Orientation
@onready var wall_check: RayCast2D = %WallCheck
@onready var ground_check: RayCast2D = %GroundCheck
@onready var ledge_check: RayCast2D = %LedgeCheck


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	var just_landed: bool = _was_in_air and is_on_floor()
	var on_ground = is_on_floor()

	var direction := Input.get_axis("move_left", "move_right")
	var wall_grab_possible := _check_wall_grab()
	var grabbing_wall :=  orientation.scale.x == direction and wall_grab_possible and not _is_climbing_ledge
	
	var climb_up := grabbing_wall and Input.is_action_just_pressed("jump")

	if grabbing_wall:
		_coyote_timer = COYOTE_DURATION_FROM_WALL_GRAB
	elif on_ground:
		_coyote_timer = COYOTE_DURATION # Reset timer while on ground
	else:
		_coyote_timer -= delta # Count down while in air
	
	# Calculating Y velocity
	if on_ground:
		if Input.is_action_just_pressed("jump"):
			_jump_buffer_timer = JUMP_BUFFER_DURATION
		else:
			_jump_buffer_timer -= delta
		if _jump_buffer_timer > 0. and _coyote_timer >= 0.:
			velocity.y = JUMP_VELOCITY
			_jump_buffer_timer = 0.
			_is_landing = false
			_coyote_timer = 0.
	elif climb_up:
		_is_climbing_ledge = true
		velocity.y = JUMP_VELOCITY
		sprite.play("jumping")
	else:
		if not _double_jump_used and Input.is_action_just_pressed("jump"):
			jetpack_particles.emitting = true
			velocity.y = DOUBLE_JUMP_VELOCITY
			_is_landing = false
			_double_jump_used = true
		elif Input.is_action_just_pressed("go_down") and grabbing_wall:
			velocity.y = get_gravity().y * delta * 0.25
		elif Input.is_action_pressed("go_down"):
			velocity += get_gravity() * delta * 3
		elif grabbing_wall:
			_double_jump_used = false
			on_ground = true
			_coyote_timer = 0.
			velocity = Vector2.ZERO
		elif velocity.y < 0.:
			if Input.is_action_pressed("jump"):
				velocity += get_gravity() * delta * 0.4
			else:
				velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 1.5

	# Calculating X velocity
	var acceleration := GROUND_ACCELERATION if on_ground else AIR_ACCELERATION
	if Input.is_action_pressed("go_down"):
		velocity.x = 0.
	elif grabbing_wall:
		if Input.is_action_just_pressed("jump"):
			if ledge_check.is_colliding():
				velocity.x = -direction * SPEED * 0.5
			else:
				velocity.x = 0.
		else:
			velocity.x = 0.
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
		else: 
			var friction := GROUND_FRICTION if on_ground else AIR_FRICTION
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	_adjust_animation(just_landed)
	_was_in_air = not on_ground


func _check_wall_grab() -> bool:
	return wall_check.is_colliding() and not ground_check.is_colliding()


func _adjust_animation(just_landed: bool) -> void:
	if velocity.x != 0.0:
		orientation.scale.x = -1. if velocity.x < 0. else 1.0

	# Figure out if we need to switch to landing
	if just_landed:
		_is_climbing_ledge = false
		_is_landing = true
		sprite.play("landing")
		sprite.scale.y = 1.0
		_double_jump_used = false
		return
	
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
