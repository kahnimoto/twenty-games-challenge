class_name Ball
extends CharacterBody2D


@onready var audio_bounce: AudioStreamPlayer2D = $AudioBounce
@onready var sprite: Sprite2D = $Sprite2D

var _fell_too_low := false
var let_go := false


func _physics_process(delta: float) -> void:
	if not let_go:
		global_position.x = get_viewport().get_mouse_position().x
		return
	if  global_position.y >= 436.0:
		set_ball_as_too_low_to_catch()
	if _fell_too_low:
		move_and_collide(velocity * Game.ball_speed * delta)
	else:
		var collision: KinematicCollision2D = move_and_collide(velocity * Game.ball_speed * delta)
		if collision:
			audio_bounce.play()
			var collider: Node2D = collision.get_collider() as Node2D
			if collider is Block:
				(collider as Block).hit()
				velocity = -velocity.reflect(collision.get_normal()).normalized()
			elif collider.is_in_group("player"):
				var hit_global_position: Vector2 = collision.get_position()
				var hit_position = hit_global_position - collider.global_position
				var influence_angle := Vector2.ZERO
				var influence: float = 0.0
				if hit_position.x < 0:
					influence_angle = Vector2.LEFT 
					influence = abs(hit_position.x) / Player.current_size / 2
				elif hit_position.x > 0:
					influence_angle = Vector2.RIGHT
					influence = abs(hit_position.x) / Player.current_size / 2
				if influence > 0.7:
					influence += 0.5
					# @TODO add effect to hint about corner hit
				else:
					influence = 0.0
				var incoming_angle = velocity.normalized()
				var influenced_angle: Vector2 = incoming_angle + influence_angle * influence
				var out_angle: Vector2 = -influenced_angle.reflect(collision.get_normal())
				#var a := out_angle.angle()
				#var fixed_angle = _fix_angle(a)
				#if a != fixed_angle:
					#out_angle = out_angle.rotated(fixed_angle)
				velocity = out_angle.normalized()
			else: # Hit wall
				velocity = -velocity.reflect(collision.get_normal()).normalized()
				var a := velocity.angle()
				var fixed_angle = _fix_angle(a)
				if a != fixed_angle:
					velocity = velocity.rotated(fixed_angle).normalized()
					_flash_ball()


func set_ball_as_too_low_to_catch() -> void:
	_fell_too_low = true
	set_collision_mask_value(2, false)


func _fix_angle(a: float) -> float:
	var min_angle := 0.3
	var add_angle := 0.6
	if 0.0 < a and a < min_angle:
		return add_angle 
	elif -min_angle < a and a < 0.0:
		return -add_angle
	elif PI - min_angle < a:
		return -add_angle
	elif a < -PI + min_angle:
		return add_angle
	else:
		return a


func _flash_ball() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2).from(Color.INDIAN_RED)
