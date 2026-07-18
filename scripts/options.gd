extends CanvasLayer

@onready var tutorial_button: CheckButton = $VBoxContainer/TutorialButton

# if the game is paused this is being displayed from the actual game,
# if it isnt, this is being displayed from the main menu

func _ready() -> void:
	if GameInfo.game_paused:
		$TitleLabel.text = "Paused"
	else:
		$TitleLabel.text = "Options"

	tutorial_button.button_pressed = Settings.show_tutorials

func _on_tutorial_button_toggled(toggled_on: bool) -> void:
	Settings.show_tutorials = toggled_on

func _on_back_button_pressed() -> void:
	if GameInfo.game_paused:
		GameEvents.emit_change_pause_state(false)
		get_tree().change_scene_to_file("res://scenes/starting_screen.tscn")
		GameInfo.reset_values()
	queue_free()
