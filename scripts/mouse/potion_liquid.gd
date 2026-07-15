extends Sprite2D

func _ready() -> void:
	var selected_potion_color: Color = GameInfo.current_round_details.selected_potion.potion_color
	material.set_shader_parameter("potion_color", selected_potion_color)
