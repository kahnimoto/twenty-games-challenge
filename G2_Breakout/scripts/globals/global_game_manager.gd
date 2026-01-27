extends Node


const MIN_X := 0.0
const MAX_X := 640.0
const HALF_AREA := MAX_X / 2
const DEADZONE := 80.0
const STARTING_LIVES := 3
const BALL_DEFAULT_SPEED = 200.0

var over := false
var score: int = 0:
	set(v):
		score = v
		Events.score_updated.emit(v)
var lives: int = STARTING_LIVES

var ball_speed := BALL_DEFAULT_SPEED
var _ball_speed_upgrade_duration := 0.0
var _player_broader_upgrade_duration := 0.0
var _current_level: Level

func _ready() -> void:
	Events.level_complete.connect(_on_level_complete)
	Events.block_destroyed.connect(_on_block_destroyed)


func _process(delta: float) -> void:
	if _ball_speed_upgrade_duration > 0.0:
		_ball_speed_upgrade_duration -= delta
		if _ball_speed_upgrade_duration <= 0.0:
			ball_speed = BALL_DEFAULT_SPEED
		Events.upgrade_timer_changed.emit(UpgradeData.Types.FASTER_BALLS, _ball_speed_upgrade_duration)
	if _player_broader_upgrade_duration > 0.0:
		_player_broader_upgrade_duration -= delta
		if _player_broader_upgrade_duration <= 0.0:
			_current_level.player.revert_size()
		Events.upgrade_timer_changed.emit(UpgradeData.Types.BROADER_PADDLE, _player_broader_upgrade_duration)

func register_level(level: Level) -> void:
	_current_level = level


func new_game() -> void:
	score = 0
	lives = STARTING_LIVES
	ball_speed = BALL_DEFAULT_SPEED
	Events.game_started.emit()


func apply_upgrade(data: UpgradeData) -> void:
	match data.type:
		UpgradeData.Types.FASTER_BALLS:
			if _ball_speed_upgrade_duration < 0.0:
				_ball_speed_upgrade_duration = 0.0
			_ball_speed_upgrade_duration += data.duration
			ball_speed = BALL_DEFAULT_SPEED * data.strength
		UpgradeData.Types.EXTRA_BALL:
			assert(_current_level is Level)
			#var ball_spawn_position = _current_level.player.global_position - Vector2(0.0, 16)
			_current_level.new_ball()
			_current_level.let_ball_go()
		UpgradeData.Types.FASTER_PADDLE:
			pass
		UpgradeData.Types.BROADER_PADDLE:
			if _player_broader_upgrade_duration < 0.0:
				_player_broader_upgrade_duration = 0.0
			_player_broader_upgrade_duration += data.duration
			_current_level.player.change_size(data.strength, data.duration)
		UpgradeData.Types.SHOOTING_PADDLE:
			pass
		_:
			push_warning("Unknown upgrade")


func ball_exited() -> void:
	lives -= 1
	Events.life_lost.emit(lives)
	if lives <= 0:
		over = true
		Events.message.emit("Game Over!")
		Events.game_lost.emit()


func _on_level_complete() -> void:
	over = true
	Events.message.emit("You WON!")


func _on_block_destroyed(score_value: int, _u, _p) -> void:
	score += score_value
