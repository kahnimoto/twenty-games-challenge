extends Control


@onready var copper_amount_value: Label = %CopperAmountValue
@onready var iron_amount_value: Label = %IronAmountValue
@onready var gold_amount_value: Label = %GoldAmountValue
@onready var diamond_amount_value: Label = %DiamondAmountValue


func _ready() -> void:
	Events.inventory_changed.connect(_on_inventory_changed)
	copper_amount_value.text = "0"
	iron_amount_value.text = "0"
	gold_amount_value.text = "0"
	diamond_amount_value.text = "0"


func _on_inventory_changed() -> void:
	copper_amount_value.text = str(Game.inventory[Ore.Metal.COPPER])
	iron_amount_value.text = str(Game.inventory[Ore.Metal.IRON])
	gold_amount_value.text = str(Game.inventory[Ore.Metal.GOLD])
	diamond_amount_value.text = str(Game.inventory[Ore.Metal.DIAMOND])
