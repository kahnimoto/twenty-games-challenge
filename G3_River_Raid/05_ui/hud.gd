class_name HUD
extends CanvasLayer

const HEALTH_GEM = preload("uid://b5by8p2v1cyo7")

var _gems: Array[HealthGem] = []

@onready var health_bar: GridContainer = %HealthBar


func _ready() -> void:
	_reset_gems()
	Events.lives_changed.connect(_update_health)


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
