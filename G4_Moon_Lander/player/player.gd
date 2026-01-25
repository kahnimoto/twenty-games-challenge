class_name Lander
extends CharacterBody2D


const TURN_SPEED = 1.4
const THRUST = 7000.0
const GRAVITY = 3000.0
const ROTATION_FORGIVNESS_WHEN_LANDING := 0.7
const FUEL_USED_PER_SECOND := 15.0
const FUEL_GAINED_PER_SECOND := 3.0

var _land_gears_out := true
var dead := false
var fuel := 100.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var land_gear_detector: Area2D = %LandGearDetector
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	land_gear_detector.body_shape_entered.connect(_on_land_detected.bind(true))
	land_gear_detector.body_shape_exited.connect(_on_land_detected.bind(false))


func _on_land_detected(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int, landing: bool) -> void:
	if landing:
		if not _land_gears_out:
			animated_sprite_2d.play_backwards("landgears")
			_land_gears_out = true
	else:
		if _land_gears_out:
			animated_sprite_2d.play("landgears")
			_land_gears_out = false
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_toggle_landgears()


func _toggle_landgears() -> void:
		if _land_gears_out:
			animated_sprite_2d.play_backwards("landgears")
		else:
			animated_sprite_2d.play("landgears")
		_land_gears_out = not _land_gears_out


func _physics_process(delta: float) -> void:
	if dead:
		return
	if fuel <= 0.0:
		explode()
	if not is_on_floor():
		velocity = Vector2.DOWN * GRAVITY * delta

	if Input.is_action_pressed("up"):
		velocity += Vector2.UP.rotated(rotation) * THRUST * delta
		gpu_particles_2d.emitting = true
		fuel = clampf(fuel - (delta * FUEL_USED_PER_SECOND), 0.0, 100.0)
	else:
		gpu_particles_2d.emitting = false
		fuel = clampf(fuel + (delta * FUEL_GAINED_PER_SECOND), 0.0, 100.0)

	var turn := Input.get_axis("left", "right")
	if turn:
		rotate(turn * delta * TURN_SPEED)
	
	var c: KinematicCollision2D = move_and_collide(velocity * delta)
	if c:
		var collided_with: Node2D = c.get_collider() as Node2D
		if collided_with.is_in_group("landingpad"):
			if (abs(rotation) > ROTATION_FORGIVNESS_WHEN_LANDING):
				explode()
			else:
				create_tween().tween_property(self, "rotation", 0.0, 0.15).set_ease(Tween.EASE_OUT)
		else:
			explode()


func explode() -> void:
	dead = true
	animation_player.play("explode")
	await animation_player.animation_finished
	get_tree().reload_current_scene()
