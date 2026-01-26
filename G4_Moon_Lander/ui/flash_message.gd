## Flash Message
extends Node

const TIME_PER_MSG := 4.0

var _timer: float = INF

@onready var message: Label = %Message
@onready var container: Control = $CanvasLayer/Control


func _ready() -> void:
	Events.level_completed.connect(_on_level_completed)
	Events.message.connect(_on_flash_message)
	Events.level_loaded.connect(_on_level_loaded)
	container.hide()


func _on_flash_message(msg: String) -> void:
	message.text = msg
	container.visible = true
	_timer = 0.0


func _on_level_completed() -> void:
	#_on_flash_message("You landed safely!")
	container.hide()


func _on_level_loaded() -> void:
	container.show()


func _process(delta: float) -> void:
	_timer += delta
	container.visible = _timer < TIME_PER_MSG
