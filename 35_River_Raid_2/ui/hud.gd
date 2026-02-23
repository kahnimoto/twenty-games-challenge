class_name HUD
extends CanvasLayer

const LIFE_ON: Color = Color.WHITE
const LIFE_OFF: Color = Color.DIM_GRAY

@onready var fuel_gauge: TextureProgressBar = %FuelGauge
@onready var life_1: TextureRect = %Life1
@onready var life_2: TextureRect = %Life2
@onready var life_3: TextureRect = %Life3
@onready var score: RichTextLabel = %ValueScore


func _ready() -> void:
	life_1.self_modulate = LIFE_ON
	life_2.self_modulate = LIFE_ON
	life_2.self_modulate = LIFE_ON
	Events.scored.connect(_on_player_scored)
	score.text = "0"
	

func _process(_delta: float) -> void:
	_update_fuel()
	_update_lives()


func _on_player_scored(new_total: int) -> void:
	var readable_score: String
	if new_total >= 1000:
		readable_score = "%d,%s" % [ floori(new_total/1000.), str(new_total%1000).pad_zeros(3) ]
	else:
		readable_score = str(new_total)
	score.text = "[shake]%s[/shake]" % readable_score
	await get_tree().create_timer(0.2).timeout
	score.text = readable_score


func _update_fuel() -> void:
	fuel_gauge.value = Game.fuel


func _update_lives() -> void:
	if Game.lives < 3:
		life_3.self_modulate = LIFE_OFF
	else:
		life_3.self_modulate = LIFE_ON
	if Game.lives < 2:
		life_2.self_modulate = LIFE_OFF
	else:
		life_2.self_modulate = LIFE_ON
