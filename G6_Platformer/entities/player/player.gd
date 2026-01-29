extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _is_landing: bool = false


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	var was_in_air = not is_on_floor()

	if was_in_air:
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump") and not was_in_air:
		velocity.y = JUMP_VELOCITY
		_is_landing = false

	move_and_slide()

	if was_in_air and is_on_floor():
		_is_landing = true
		sprite.play("landing")

	_adjust_animation()

func _adjust_animation() -> void:
	if velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.

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
	else:
		if velocity.y < 0:
			if sprite.animation != "jumping":
				sprite.play("jumping")
		else:
			if sprite.animation != "falling":
				sprite.play("falling") # Good to have a falling state!



func _on_animation_finished() -> void:
	if sprite.animation == "landing":
		_is_landing = false
		_adjust_animation()
