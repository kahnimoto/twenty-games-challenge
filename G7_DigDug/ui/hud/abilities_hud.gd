extends Control


const PICK_LEVEL_TWO: Color = Color(0.522, 1.096, 0.962)
const PICK_LEVEL_THREE: Color = Color(0.628, 0.525, 1.096)

@onready var has_claws: TextureRect = %HasClaws
@onready var has_jetpack: TextureRect = %HasJetpack
@onready var pickaxe_head: TextureRect = %PickaxeHead
@onready var pickaxe_cost: Control = %PickaxeCost
@onready var claws_cost: Control = %ClawsCost
@onready var jetpack_cost: Control = %JetpackCost
@onready var has_scaffold: TextureRect = %HasScaffold
@onready var scaffold_cost: Control = %ScaffoldCost


func _ready() -> void:
	update_abilities()
	Events.abilities_changed.connect(update_abilities)


func update_abilities() -> void:
	match Game.pickaxe_level:
		1: pass
		2:
			pickaxe_head.modulate = PICK_LEVEL_TWO
			pickaxe_cost.modulate = Color(Color.WHITE, 0.0)
		3: pickaxe_head.modulate = PICK_LEVEL_THREE
	if Game.abilities[Game.Ability.WALLGRAB]:
		has_claws.hide()
		claws_cost.modulate = Color(Color.WHITE, 0.0)
	else:
		has_claws.show()
	if Game.abilities[Game.Ability.SCAFFOLD]:
		has_scaffold.hide()
		scaffold_cost.modulate = Color(Color.WHITE, 0.0)
	else:
		has_scaffold.show()
	if Game.abilities[Game.Ability.JETPACK]:
		has_jetpack.hide()
		jetpack_cost.modulate = Color(Color.WHITE, 0.0)
	else:
		has_jetpack.show()
