extends Node2D

@onready var cork_sprite: Sprite2D = $Cork/CorkSprite
@onready var potion_liquid: Sprite2D = $Potion/PotionLiquid

func _ready() -> void:
	GameEvents.round_transition.connect(_on_round_transition)

func _on_round_transition() -> void:
	var tween = create_tween()
	var potion_liquid_material: ShaderMaterial = potion_liquid.material
	var selected_potion_color: Color = GameInfo.current_round_details.selected_potion.potion_color

	tween.tween_property(potion_liquid_material, "shader_parameter/potion_color", Color(selected_potion_color.r, selected_potion_color.g, selected_potion_color.b, 0.0), 0.1)
	$PotionPlayer.play("potion_fade_out")
