extends Node


const WINNING_SCORE = 3
const PADDLE_SIZE = 64
const HEIGH = 320
const MIN_Y = 32
const MAX_Y = 288

var player_score: int = 0
var ai_score: int = 0
var game_over: bool:
	get:
		return player_score >= WINNING_SCORE or ai_score >= WINNING_SCORE


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func new_game() -> void:
	player_score = 0
	ai_score = 0
	Events.game_started.emit()


func score_player() -> void:
	player_score += 1
	if player_score >= WINNING_SCORE:
		Events.game_won.emit()
	else:
		Events.player_scored.emit()


func score_ai() -> void:
	ai_score += 1
	if ai_score >= WINNING_SCORE:
		Events.game_lost.emit()
	else:
		Events.ai_scored.emit()
