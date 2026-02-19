extends CanvasLayer


const REQUIRED_DELAY := 0.4

var playing := false
var showing_hint := 0
var ready_for_next := false
var connected_ui: Array[Control] = []

@onready var input_hint: Control = $InputHint
@onready var hints: Array[Node] = $Hints.get_children()
@onready var hud: HUD = $"../HUD"


func _ready() -> void:
	hints.map(func(c: Control): 
		if c is HintUIConnected and (c as HintUIConnected).connected is Control:
			connected_ui.append((c as HintUIConnected).connected)
			(c as HintUIConnected).connected.hide()
		c.hide()
	)
	input_hint.hide()
	play()


func _unhandled_input(event: InputEvent) -> void:
	if not playing:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		skip_tutorial()
	if not ready_for_next:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		next_hint()
		get_viewport().set_input_as_handled()



func play() -> void:
	showing_hint = -1
	playing = true
	get_tree().paused = true
	next_hint(true)

func next_hint(first: bool = false) -> void:
	ready_for_next = false
	if not first:
		hints[showing_hint].hide()
		#for c in connected_ui:
			#c.hide()
	showing_hint += 1
	if showing_hint >= hints.size():
		done()
		return
	hints[showing_hint].show()
	if hints[showing_hint] is HintUIConnected and  (hints[showing_hint] as HintUIConnected).connected is Control:
		(hints[showing_hint] as HintUIConnected).connected.show()
	input_hint.hide()
	await get_tree().create_timer(REQUIRED_DELAY).timeout
	ready_for_next = true
	input_hint.show()


func skip_tutorial() -> void:
	hud.refresh()
	get_tree().paused = false
	queue_free()
	

func done() -> void:
	hud.refresh()
	get_tree().paused = false
	queue_free()
	
