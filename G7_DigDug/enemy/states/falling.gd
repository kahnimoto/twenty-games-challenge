class_name EnemyFalling
extends State

const FALLING_CURVE = preload("uid://okf7sh8a0e4b")
const FALL_TIME := 0.5

@export var enemy: Enemy
@export var idle_state: EnemyIdle


var timer: float
var progress: float
var start_pos: Vector2
var target_pos: Vector2

func tick(delta: float) -> Variant:
	timer += delta
	progress = remap(timer, 0.0, FALL_TIME, 0.0, 1.0)
	enemy.global_position.x = target_pos.x
	enemy.global_position.y = lerp(start_pos.y, target_pos.y, FALLING_CURVE.sample(progress))
	if progress >= 1.0:
		return idle_state
	return null


func enter() -> void:
	#print("Entering Falling")
	timer = 0.0
	progress = 0.0
	start_pos = enemy.global_position
	target_pos = enemy.find_floor()


func exit() -> void:
	#print("Exiting Falling")
	pass
