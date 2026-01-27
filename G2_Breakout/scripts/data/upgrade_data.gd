class_name UpgradeData
extends Resource

enum Types {
	NONE,
	EXTRA_BALL,
	FASTER_BALLS,
	FASTER_PADDLE,
	BROADER_PADDLE,
	SHOOTING_PADDLE,
}

@export var type: UpgradeData.Types = UpgradeData.Types.NONE
@export_range(1.0, 60, 0.5) var duration: float = 5.0
@export var strength: float = 1.0
@export var color: Color = Color.SEA_GREEN
