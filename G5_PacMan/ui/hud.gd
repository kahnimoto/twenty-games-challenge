extends CanvasLayer

@onready var value_crumbs: Label = %ValueCrumbs
@onready var game_over_message: Control = %GameOverMessage
@onready var level_complete_message: Control = %LevelComplete


func _ready() -> void:
	Events.level_started.connect(_on_level_started)
	Events.crumb_eaten.connect(_on_crumb_eaten)
	game_over_message.hide()
	Events.level_failed.connect(game_over_message.show)
	level_complete_message.hide()
	Events.level_completed.connect(level_complete_message.show)

func _on_level_started(total_crumbs: int) -> void:
	value_crumbs.text = str(total_crumbs)


func _on_crumb_eaten(crumbs_left: int) -> void:
	value_crumbs.text = str(crumbs_left)
