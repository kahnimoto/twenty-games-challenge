extends CanvasLayer

@onready var wallgrab_toggle: CheckButton = %WallgrabToggle
@onready var jetpack_toggle: CheckButton = %JetpackToggle

func _ready() -> void:
	wallgrab_toggle.toggled.connect(_on_feature_toggled.bind(Game.Ability.WALLGRAB))
	wallgrab_toggle.button_pressed = Game.abilities[Game.Ability.WALLGRAB]
	jetpack_toggle.toggled.connect(_on_feature_toggled.bind(Game.Ability.JETPACK))
	jetpack_toggle.button_pressed = Game.abilities[Game.Ability.JETPACK]


func _on_feature_toggled(on: bool, ability: Game.Ability) -> void:
	Game.abilities[ability] = on
	Events.abilities_changed.emit()
	wallgrab_toggle.release_focus()
	jetpack_toggle.release_focus()
