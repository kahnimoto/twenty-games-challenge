extends Node

@onready var h_slider: HSlider = $Control/VBoxContainer/HSlider
@onready var label: Label = $Control/VBoxContainer/Label
@onready var test_object: Node2D = $TestObject



func _ready() -> void:
	h_slider.value_changed.connect(_on_slider_changed)



func _on_slider_changed(value) -> void:
	var radians: float = remap(value, -1.0, 1.0, -PI, PI)
	label.text = "%.2f" % radians
	test_object.rotation = radians


func _process(_delta: float) -> void:
	pass
