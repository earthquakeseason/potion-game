extends CanvasLayer

func _ready() -> void:
	$SigilTimer.start(20)

func _process(delta: float) -> void:
	$TimeLabel.text = "Time left to draw: " + str(round($SigilTimer.time_left)) + "s"

func _on_sigil_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/lose_screen.tscn")
