extends CanvasLayer

@onready var value_crumbs: Label = %ValueCrumbs


func _ready() -> void:
	Events.level_started.connect(_on_level_started)
	Events.crumb_eaten.connect(_on_crumb_eaten)

func _on_level_started(total_crumbs: int) -> void:
	value_crumbs.text = str(total_crumbs)


func _on_crumb_eaten(crumbs_left: int) -> void:
	value_crumbs.text = str(crumbs_left)
