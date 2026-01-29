class_name Player
extends CharacterBody2D


@export var tilemap: TileMapLayer

const SPEED = 200.0
const JUMP_VELOCITY = -310.0
const DOUBLE_JUMP_VELOCITY = -330.0

@onready var sprite: AnimatedSprite2D = %CharacterSprite
@onready var jetpack_particles: GPUParticles2D = %JetpackParticles
@onready var visuals: Node2D = $Visuals


var _is_landing := false
var _double_jump_used := false


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	var was_in_air = not is_on_floor()

	if was_in_air:
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump"):
		if not was_in_air:
			velocity.y = JUMP_VELOCITY
			_is_landing = false
		elif not _double_jump_used:
			jetpack_particles.emitting = true
			velocity.y = DOUBLE_JUMP_VELOCITY
			_is_landing = false
			_double_jump_used = true
			

	move_and_slide()

	if was_in_air and is_on_floor():
		_is_landing = true
		sprite.play("landing")
		sprite.scale.y = 1.0
		_double_jump_used = false

	_adjust_animation()

func _adjust_animation() -> void:
	if velocity.x != 0.0:
		#sprite.flip_h = velocity.x < 0.
		visuals.scale.x = -1. if velocity.x < 0. else 1.0

	if _is_landing:
		if sprite.is_playing() and sprite.animation == "landing":
			return
		else:
			_is_landing = false

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
		_adjust_animation()
