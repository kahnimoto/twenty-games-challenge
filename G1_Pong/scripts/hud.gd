class_name HUD
extends CanvasLayer

@onready var left_score: Label = %LeftScore
@onready var message: Label = %Message
@onready var right_score: Label = %RightScore


func _ready() -> void:
	Events.game_started.connect(_on_game_started)
	Events.ai_scored.connect(_on_ai_scored)
	Events.player_scored.connect(_on_player_scored)
	Events.game_lost.connect(_on_player_lost)
	Events.game_won.connect(_on_player_won)


func _on_game_started() -> void:
	left_score.text = str(0)
	message.text = "Game Started"
	right_score.text = str(0)

func _on_player_lost() -> void:
	message.text = "You lost! Maybe skill issue?"
	right_score.text = str(Game.ai_score)

func _on_player_won() -> void:
	left_score.text = str(Game.player_score)
	message.text = "You won!"

func _on_ai_scored() -> void:
	right_score.text = str(Game.ai_score)
	message.text = "The A.I. scored on you?"


func _on_player_scored() -> void:
	left_score.text = str(Game.player_score)
	message.text = "You Scored!"
