class_name EnemyIdle
extends State


@export var enemy: Enemy
@export var wander_state: EnemyWander
@export var idle_duration: float = 3.0
@export var vision: Area2D

var time_in_state: float = 0.0
var flipflop: float = 0.5
var flipflop_timer: float = 0.0
var saw_player: bool = false


func tick(delta: float) -> Variant:
	if saw_player:
		return wander_state
	time_in_state += delta
	if time_in_state >= idle_duration:
		return wander_state
	flipflop_timer += delta
	if flipflop_timer >= flipflop:
		flipflop_timer = 0.0
		enemy.facing_right = not enemy.facing_right
	return null


func enter() -> void:
	#print("Entering Idle")
	assert(enemy is Enemy)
	saw_player = false
	time_in_state = 0.0
	flipflop_timer = 0.0
	flipflop = max(0.5, idle_duration / 6)
	vision.body_entered.connect(_on_player_vision)


func _on_player_vision(_b) -> void:
	saw_player = true


func exit() -> void:
	#print("Exiting Idle")
	if vision.body_entered.is_connected(_on_player_vision):
		vision.body_entered.disconnect(_on_player_vision)
	else:
		push_warning("Why is vision not connected??!")
