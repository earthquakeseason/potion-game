extends CanvasLayer

const STARTING_SCREEN = preload("res://scenes/starting_screen.tscn")

func _ready() -> void:
	$GPUParticles2D.emitting = true

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(STARTING_SCREEN)
