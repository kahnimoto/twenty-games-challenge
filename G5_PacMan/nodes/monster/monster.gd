extends Area2D

signal wander_completed

enum States { WANDER, CHASE, RUN, RETURN }

const MONSTER_COLORS: Array[Color] = [
	Color.DARK_BLUE,
	Color.BLUE_VIOLET,
	Color.DARK_RED,
	Color.YELLOW_GREEN
]

@export var level: Level
@export_range(0, 3, 1) var monster_number: int = 1

var _current_target: Vector2 = Vector2.ZERO
var _path: Array
var _next_step: Vector2
var _tween: Tween

var state: States = States.WANDER

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.modulate = MONSTER_COLORS[monster_number]
	assert(level is Level)
	Events.level_started.connect(wander)
	wander_completed.connect(wander)

#func _process(_delta: float) -> void:
	#match state:
		#States.WANDER:
			#wander()
		#_:
			#push_warning("Not implemented state")


func wander() -> void:
	if _current_target == Vector2.ZERO:
		_current_target = level.get_wander_target()
		_path = Array(level.get_path_to_target_position(global_position, _current_target))
		_path.pop_front() # we dont need current position
	if _current_target is Vector2 and _current_target != Vector2.ZERO:
		var move_duration: float = Config.TURN_TIME
		while _path.size() > 0:
			_next_step = _path.pop_front()
			if _tween:
				_tween.kill()
			_tween = create_tween()
			_tween.tween_property(self, "global_position", _next_step, move_duration).set_ease(Tween.EASE_IN)
			await _tween.finished
		_current_target = Vector2.ZERO
	wander_completed.emit()
