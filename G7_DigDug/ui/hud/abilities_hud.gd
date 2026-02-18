extends Control


const PICK_LEVEL_TWO: Color = Color(0.522, 1.096, 0.962)
const PICK_LEVEL_THREE: Color = Color(0.628, 0.525, 1.096)

@onready var has_claws: TextureRect = %HasClaws
@onready var has_jetpack: TextureRect = %HasJetpack
@onready var pickaxe_head: TextureRect = %PickaxeHead


func _ready() -> void:
	update_abilities()
	Events.abilities_changed.connect(update_abilities)


func update_abilities() -> void:
	match Game.pickaxe_level:
		1: pass
		2: pickaxe_head.modulate = PICK_LEVEL_TWO
		3: pickaxe_head.modulate = PICK_LEVEL_THREE
	if Game.abilities[Game.Ability.WALLGRAB]:
		has_claws.hide()
	else:
		has_claws.show()
	if Game.abilities[Game.Ability.JETPACK]:
		has_jetpack.hide()
	else:
		has_jetpack.show()
