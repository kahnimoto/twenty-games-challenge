class_name Monster
extends Area2D

signal wander_completed

enum States { WANDER, CHASE, RUN, RETURN }

const GROUP_NAME = &"monster"
static var colors: Array[Color] = [
	Color.CYAN.lightened(0.5),
	Color.BLUE_VIOLET.lightened(0.5),
	Color.DARK_RED.lightened(0.5),
	Color.YELLOW_GREEN.lightened(0.5),
]
static var afraid_color: Color = Color.DARK_BLUE.lightened(0.5)

@export var level: Level
@export_range(0, 3, 1) var monster_number: int = 1

var _start_position: Vector2
var _current_target: Vector2 = Vector2.ZERO
var _path: Array
var _next_step: Vector2
var _tween: Tween

var path_viz: Line2D
var state: States = States.WANDER

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _init() -> void:
	add_to_group(GROUP_NAME)

func _ready() -> void:
	sprite.modulate = Monster.colors[monster_number]
	assert(level is Level)
	Events.level_started.connect(_on_level_started)
	wander_completed.connect(wander)
	Events.monster_eaten.connect(_on_monster_eaten)
	Events.player_state_changed.connect(_on_player_changed_state)


func _on_level_started(_crumbs) -> void:
	_start_position = global_position
	wander()

#func _process(_delta: float) -> void:
	#match state:
		#States.WANDER:
			#wander()
		#_:
			#push_warning("Not implemented state")

func _on_monster_eaten(monster: Monster) -> void:
	if monster != self:
		return
	# @TODO animate?
	if path_viz and path_viz is Line2D:
		path_viz.queue_free()
	queue_free()


func _on_player_changed_state(new_state: Player.State) -> void:
	match new_state:
		Player.State.DEFAULT:
			sprite.modulate = Monster.colors[monster_number]
			wander()
		Player.State.BOOSTED:
			sprite.modulate = Monster.afraid_color
			return_to_base()
		Player.State.DEAD:
			return_to_base()
	

func wander() -> void:
	if _current_target == Vector2.ZERO:
		_current_target = level.get_wander_target()
		_path = Array(level.get_path_to_target_position(global_position, _current_target))
		_path.pop_front() # we dont need current position
		preview_path()
	if _current_target is Vector2 and _current_target != Vector2.ZERO:
		while _path.size() > 0:
			_next_step = _path.pop_front()
			if _tween:
				_tween.kill()
			_tween = create_tween()
			_tween.tween_property(self, "global_position", _next_step, Config.DEFAULT_MOVE_SPEED).set_ease(Tween.EASE_IN)
			await _tween.finished
		_current_target = Vector2.ZERO
	if path_viz and path_viz is Line2D:
		path_viz.queue_free()
	wander_completed.emit()

func return_to_base() -> void:
	_current_target = _start_position
	_path = Array(level.get_path_to_target_position(global_position, _current_target))
	_path.pop_front() # we dont need current position
	preview_path()
	while _path.size() > 0:
		_next_step = _path.pop_front()
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "global_position", _next_step, Config.MONSTER_SPEED_WHEN_PLAYER_BOOSTED).set_ease(Tween.EASE_IN)
		await _tween.finished
	if path_viz is Line2D:
		path_viz.queue_free()
	_current_target = Vector2.ZERO


func preview_path() -> void:
	if not Config.PREVIEW_MONSTER_PATH:
		return
	if path_viz and path_viz is Line2D:
		path_viz.queue_free()
	path_viz = Line2D.new()
	path_viz.width = 2
	path_viz.default_color = Color(Monster.colors[monster_number], 0.3)
	for pos:Vector2 in _path:
		path_viz.add_point(pos + Vector2(8, 8))
	add_sibling(path_viz)
