class_name Lander
extends RigidBody2D


const TURN_SPEED = 150.0
const UP_THRUST = 50.0
const SIDE_THRUST = 30.0
const GRAVITY = 20.0
const ROTATION_FORGIVNESS_WHEN_LANDING := 0.2
const FUEL_USED_PER_SECOND := 15.0
const FUEL_GAINED_PER_SECOND := 3.0 
const ACCEPTABLE_LANDING_SPEED := 20

var _land_gears_out := true
var on_ground := false
var dead := false

var fuel := 100.0
var fuel_capacity := 100.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var land_gear_detector: Area2D = %LandGearDetector
@onready var thrust_particles: GPUParticles2D = $ThrustParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var left_thrust_particles: GPUParticles2D = $LeftThrustParticles
@onready var right_thrust_particles: GPUParticles2D = $RightThrustParticles
@onready var rotate_left_thrust_particles: GPUParticles2D = $RotateLeftThrustParticles
@onready var rotate_right_thrust_particles: GPUParticles2D = $RotateRightThrustParticles


func _ready() -> void:
	land_gear_detector.body_entered.connect(_on_land_detected.bind(true))
	land_gear_detector.body_exited.connect(_on_land_detected.bind(false))
	body_entered.connect(_on_body_entered)
	Hud.lander = self


func _on_land_detected(_body, landing: bool) -> void:
	if landing and  not _land_gears_out:
		animated_sprite_2d.play_backwards("landgears")
		_land_gears_out = true
	elif _land_gears_out:
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

var new_location := Vector2.ZERO
var previous_location := Vector2.ZERO
var actual_velocity := Vector2.ZERO
var copy_linear_velocity := Vector2.ZERO
var previous_linear_velocity := Vector2.ZERO

func _physics_process(delta: float) -> void:
	previous_location = new_location
	new_location = global_position
	var actual_difference = new_location - previous_location
	actual_velocity = actual_difference * 60
	previous_linear_velocity = copy_linear_velocity
	copy_linear_velocity = linear_velocity
   
	if dead:
		return
	if fuel <= 0.0:
		explode()
	if not on_ground:
		apply_force(Vector2.DOWN * GRAVITY)

	if Input.is_action_pressed("thrust"):
		apply_force(Vector2.UP.rotated(rotation) * UP_THRUST)
		thrust_particles.emitting = true
		fuel = clampf(fuel - (delta * FUEL_USED_PER_SECOND), 0.0, fuel_capacity)
	else:
		thrust_particles.emitting = false
		fuel = clampf(fuel + (delta * FUEL_GAINED_PER_SECOND), 0.0, fuel_capacity)

	left_thrust_particles.emitting = false
	right_thrust_particles.emitting = false
	var sideways := Input.get_axis("move_left", "move_right")
	if not on_ground and sideways:
		left_thrust_particles.emitting = sideways < 0.
		right_thrust_particles.emitting = sideways > 0.
		var dir: Vector2 = Vector2.LEFT if sideways < 0 else Vector2.RIGHT
		apply_force(dir.rotated(rotation) * SIDE_THRUST, Vector2(0., -2.))
		fuel = clampf(fuel - (delta * FUEL_USED_PER_SECOND), 0.0, fuel_capacity)

	rotate_left_thrust_particles.emitting = false
	rotate_right_thrust_particles.emitting = false
	if on_ground:
		if rotation < -0.05:
			apply_torque(TURN_SPEED)
		elif rotation > 0.05:
			apply_torque(-TURN_SPEED)
	else:
		var turn := Input.get_axis("rotate_left", "rotate_right")
		if turn:
			rotate_left_thrust_particles.emitting = turn < 0.
			rotate_right_thrust_particles.emitting = turn > 0.
			apply_torque(turn * TURN_SPEED)
			fuel = clampf(fuel - (delta * FUEL_USED_PER_SECOND), 0.0, fuel_capacity)
	
	if get_contact_count() == 0:
		on_ground = false


func _on_body_entered(body: Node2D) -> void:
	if body is LandingPad:
		var incoming_speed: float = previous_linear_velocity.abs().length()
		if incoming_speed < ACCEPTABLE_LANDING_SPEED:
			on_ground = true
			linear_velocity = Vector2.ZERO
			return
	if not dead:
		explode()


func explode() -> void:
	dead = true
	animation_player.play("explode")
	await animation_player.animation_finished
	get_tree().reload_current_scene()
