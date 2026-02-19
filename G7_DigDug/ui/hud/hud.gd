class_name HUD
extends CanvasLayer


const HEALTH_GEM = preload("uid://c2hfyn6l2g63l")

@export var show_debug := true

var _gems: Array[HealthGem] = []

@onready var wallgrab_toggle: CheckButton = %WallgrabToggle
@onready var jetpack_toggle: CheckButton = %JetpackToggle
@onready var health_bar: GridContainer = %HealthBar
#@onready var click_to_restart_message: Label = %ClickToRestartMessage
#@onready var click_to_start_message: Label = %ClickToStartMessage


func _ready() -> void:
	wallgrab_toggle.toggled.connect(_on_feature_toggled.bind(Game.Ability.WALLGRAB))
	wallgrab_toggle.button_pressed = Game.abilities[Game.Ability.WALLGRAB]
	jetpack_toggle.toggled.connect(_on_feature_toggled.bind(Game.Ability.JETPACK))
	jetpack_toggle.button_pressed = Game.abilities[Game.Ability.JETPACK]
	
	_reset_gems()
	#click_to_restart_message.hide()
	Events.level_loaded.connect(_on_level_loaded)
	Events.lives_changed.connect(_update_health)
	#Events.player_started.connect(click_to_start_message.hide)
	#Events.game_over.connect(click_to_restart_message.show)
	show()


func _on_feature_toggled(on: bool, ability: Game.Ability) -> void:
	Game.abilities[ability] = on
	Events.abilities_changed.emit()
	wallgrab_toggle.release_focus()
	jetpack_toggle.release_focus()


func _on_level_loaded() -> void:
	#click_to_restart_message.hide()
	#click_to_start_message.show()
	_update_health(Game.MAX_LIVES)


func _update_health(value: int) -> void:
	value = clampi(value, 0, Game.MAX_LIVES)
	for i in Game.MAX_LIVES:
		_gems[i].on = value >= i+1


func _reset_gems() -> void:
	for child in health_bar.get_children():
		child.queue_free()
	_gems = []
	health_bar.columns = Game.MAX_LIVES
	for i in Game.MAX_LIVES:
		var gem: HealthGem = HEALTH_GEM.instantiate()
		_gems.append(gem)
		health_bar.add_child(gem)
