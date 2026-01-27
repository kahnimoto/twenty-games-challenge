class_name HUD
extends CanvasLayer


const STOP_HIDDEN := Color(Color.WHITE, 0.2)

@onready var left_indicator: ProgressBar = %LeftIndicator
@onready var right_indicator: ProgressBar = %RightIndicator
@onready var stop_indicator: TextureRect = %StopIndicator
@onready var score: Label = %ValueScore
@onready var indicators: Control = %Indicators
@onready var lives: Label = %ValueLives
@onready var top_message: Label = %TopMessage
@onready var faster_indicator: TextureProgressBar = %FasterIndicator
@onready var balls_indicator: TextureProgressBar = %BallsIndicator
@onready var broader_indicator: TextureProgressBar = %BroaderIndicator
@onready var shooter_indicator: TextureProgressBar = %ShooterIndicator



func _ready() -> void:
	right_indicator.max_value = Game.HALF_AREA
	left_indicator.max_value = Game.HALF_AREA
	Events.life_gained.connect(_on_lives_changed)
	Events.life_lost.connect(_on_lives_changed)
	Events.score_updated.connect(_on_score_updated)
	Events.message.connect(func(s:String): top_message.text = s)
	Events.upgrade_timer_changed.connect(_on_update_timer_changed)
	Events.ball_lost.connect(_on_ball_count_changed)
	Events.ball_spawned.connect(_on_ball_count_changed)
	balls_indicator.value = 0
	faster_indicator.value = 0.0
	shooter_indicator.value = 0.0
	broader_indicator.value = 0.0

func show_indicator() -> void:
	indicators.show()


func hide_indicators() -> void:
	indicators.hide()


func apply_indicator(value: float) -> void:
	if value < (Game.HALF_AREA - Game.DEADZONE):
		left_indicator.value = clampf(Game.HALF_AREA - value, 0, left_indicator.max_value)
		right_indicator.value = 0
		stop_indicator.self_modulate = STOP_HIDDEN
	elif value > Game.HALF_AREA + Game.DEADZONE:
		left_indicator.value = left_indicator.min_value
		right_indicator.value = clampf(value - Game.HALF_AREA, 0, right_indicator.max_value)
		stop_indicator.self_modulate = STOP_HIDDEN
	else:
		left_indicator.value = 0
		right_indicator.value = 0
		stop_indicator.self_modulate = Color.WHITE


func _on_update_timer_changed(type: UpgradeData.Types, time_left: float) -> void:
	match type:
		UpgradeData.Types.FASTER_BALLS:
			faster_indicator.value = clampf(time_left, 0.0, 60.0)
		UpgradeData.Types.SHOOTING_PADDLE:
			shooter_indicator.value = clampf(time_left, 0.0, 60.0)
		UpgradeData.Types.BROADER_PADDLE:
			broader_indicator.value = clampf(time_left, 0.0, 60.0)


func _on_ball_count_changed(new_total: int) -> void:
	balls_indicator.value = clampi(new_total, 0, 10)



func _on_score_updated(new_score: int) -> void:
	score.text = str(new_score)


func _on_lives_changed(new_value: int) -> void:
	lives.text = str(new_value)
