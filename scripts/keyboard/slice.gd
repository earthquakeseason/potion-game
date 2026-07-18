extends Node2D

func _ready() -> void:
	GameEvents.increment_mechanical_stage.connect(_increment_mechanical_stage)
	$Ingredient.texture = GameInfo.get_current_ingredient().initial_state

func _increment_mechanical_stage(_change_stage: bool) -> void:
	pass
