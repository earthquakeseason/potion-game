extends CanvasLayer

@onready var tutorial_button: CheckButton = $VBoxContainer/TutorialButton
@onready var volume_slider: HSlider = $VBoxContainer/MusicVolumeContainer/VolumeSlider

# if the game is paused this is being displayed from the actual game,
# if it isnt, this is being displayed from the main menu
func _ready() -> void:
	if GameInfo.game_paused:
		$TitleLabel.text = "Paused"
	else:
		$TitleLabel.text = "Options"

	$CloseButton.visible = GameInfo.game_paused
	tutorial_button.button_pressed = Settings.show_tutorials
	volume_slider.value = Settings.music_volume

func _on_tutorial_button_toggled(toggled_on: bool) -> void:
	Settings.show_tutorials = toggled_on
	GameEvents.emit_setting_updated()

func _on_back_button_pressed() -> void:
	if GameInfo.game_paused:
		GameEvents.emit_change_pause_state(false)
		get_tree().change_scene_to_file("res://scenes/starting_screen.tscn")
		GameInfo.reset_values()
	queue_free()

func _on_close_button_pressed() -> void:
	GameEvents.emit_change_pause_state(false)
	queue_free()

func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.music_volume = volume_slider.value
		GameEvents.emit_setting_updated()
