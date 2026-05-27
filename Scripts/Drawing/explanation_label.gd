extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.recognition_attempt.connect(_on_recognition_attempt)
	
func _on_recognition_attempt(successful: bool):
	if successful: get_tree().change_scene_to_file("res://Scenes/rhythm_typing.tscn")
	else: text = "Your sigil is unrecognisable!"
