extends CanvasLayer

@onready var value_score: RichTextLabel = %ValueScore
@onready var header_label: RichTextLabel = %HeaderLabel

@export var winning := false


func _ready() -> void:
	if winning:
		header_label.text = "[shake]YOU WIN![/shake]"
	var readable_score: String
	if Game.points >= 1000:
		readable_score = "%d,%s" % [ floori(Game.points/1000.), str(Game.points%1000).pad_zeros(3) ]
	else:
		readable_score = str(Game.points)
	value_score.text = "[shake]%s[/shake]" % readable_score


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		get_tree().change_scene_to_file("res://ui/menu.tscn")
		visible = false
		await get_tree().scene_changed
		queue_free()
