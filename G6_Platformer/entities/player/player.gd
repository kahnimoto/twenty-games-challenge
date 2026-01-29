extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _previous_in_air := false
var _previous_velocity: Vector2
var _jumping := false

func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	
	if not on_floor:
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump") and on_floor:
		velocity.y = JUMP_VELOCITY
		_jumping = true

	move_and_slide()
	_adjust_animation()
	_previous_in_air = not is_on_floor()
	_previous_velocity = velocity


func _adjust_animation() -> void:
	var floored := is_on_floor()
	if velocity.abs().x < 0.05 and velocity.abs().y < 0.05:
		sprite.play("default")
	elif velocity.y < 0:
		if sprite.animation != "jumping":
			sprite.play("jumping")
	elif floored and velocity.abs().x > 0.05:
		if sprite.animation != "walking":
			sprite.play("walking")
	elif floored and _previous_in_air:
		sprite.play("landing")
		print(velocity)
		
	elif not floored and velocity.y > 0.05:
		pass # falling
	else:
		var v = velocity
		var pv = _previous_velocity
		var j = _jumping
		var sa = sprite.animation
		print(v)
	
	if velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.
