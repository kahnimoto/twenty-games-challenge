extends Node

const BALL = preload("uid://de78u6sepvyir")

var _active_ball: Ball 

@onready var player_goal: Area2D = %PlayerGoal
@onready var ai_goal: Area2D = %AIGoal
@onready var world: Node2D = %World


func _ready() -> void:
	player_goal.body_entered.connect(_on_ball_entered_player_goal)
	ai_goal.body_entered.connect(_on_ball_entered_ai_goal)
	Events.game_started.connect(new_ball)
	await get_tree().process_frame
	Game.new_game()


func new_ball() -> void:
	if _active_ball is Ball:
		_active_ball.queue_free()
	_active_ball = BALL.instantiate()
	world.call_deferred("add_child", _active_ball)
	_active_ball.global_position = Vector2(50, 160)
	_active_ball.velocity = Vector2.from_angle(randf_range(-2.0, 2.0))


func _on_ball_entered_player_goal(body: Node2D) -> void:
	assert(body is Ball)
	Game.score_ai()
	if not Game.game_over:
		new_ball()


func _on_ball_entered_ai_goal(body: Node2D) -> void:
	assert(body is Ball)
	Game.score_player()
	if not Game.game_over:
		new_ball()
