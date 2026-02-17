class_name EnemyWander
extends State

const MOVEMENT_CURVE = preload("uid://duliu3pr2085g")

@export var enemy: Enemy
@export var idle_state: EnemyIdle
@export var falling_state: EnemyFalling
@export var speed: float = 16. # tiles per second
@export var right_ray: RayCast2D
@export var down_ray: RayCast2D

var target: Vector2
var beat: float = 0.0


func tick(delta: float) -> Variant:
	beat = clampf(beat + delta, 0.0, 1.0)
	if beat == 1.0:
		beat = 0.0
	var speed_modifier: float = MOVEMENT_CURVE.sample(beat)

	if not down_ray.is_colliding():
		return falling_state
	if right_ray.is_colliding():
		return idle_state
	if enemy.facing_right:
		enemy.global_position.x += speed * delta * speed_modifier
	else:
		enemy.global_position.x -= speed * delta * speed_modifier
	return null


func enter() -> void:
	print("Entering Wander")
	beat = 0.0
	right_ray.enabled = true
	down_ray.enabled = true
	down_ray.force_raycast_update()


func exit() -> void:
	print("Exiting Wander")
	right_ray.enabled = false
	down_ray.enabled = false
