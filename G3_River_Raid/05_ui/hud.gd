class_name HUD
extends CanvasLayer

const HEALTH_GEM = preload("uid://b5by8p2v1cyo7")

@export var show_debug := true

var _gems: Array[HealthGem] = []

@onready var health_bar: GridContainer = %HealthBar
@onready var debug: Control = %Debug
@onready var movement_type: Label = %ValueMovementType
@onready var click_to_start_message: Label = %ClickToStartMessage
@onready var speed: Label = %ValueSpeed
@onready var click_to_restart_message: Label = %ClickToRestartMessage


func _ready() -> void:
	_reset_gems()
	click_to_restart_message.hide()
	Events.level_loaded.connect(_on_level_loaded)
	Events.lives_changed.connect(_update_health)
	Events.player_started.connect(click_to_start_message.hide)
	Events.game_over.connect(click_to_restart_message.show)
	if show_debug:
		Events.movement_type_changed.connect(_on_movement_type_changed)
		Events.speed_changed.connect(func(v): speed.text = str(int(v)))
	else:
		debug.hide()


func _on_level_loaded() -> void:
	click_to_restart_message.hide()
	click_to_start_message.show()
	_update_health(Player.MAX_LIVES)

func _update_health(value: int) -> void:
	value = clampi(value, 0, Player.MAX_LIVES)
	for i in Player.MAX_LIVES:
		# This game is ON if we have at least this amount of health
		# +1 since for loop starts at 0
		_gems[i].on = value >= i+1


func _reset_gems() -> void:
	# Remove any existing gems 
	for child in health_bar.get_children():
		child.queue_free()
	# reset array of _gems
	_gems = []
	# using a grid container, give each gem a column
	health_bar.columns = Player.MAX_LIVES
	for i in Player.MAX_LIVES:
		var gem: HealthGem = HEALTH_GEM.instantiate()
		_gems.append(gem)
		health_bar.add_child(gem)


#region debug helpers
func _on_movement_type_changed(new_value: Game.MovementTypes) -> void:
	var v: String = Game.MovementTypes.keys()[new_value]
	movement_type.text = v
