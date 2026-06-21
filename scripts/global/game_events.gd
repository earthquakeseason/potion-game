extends Node

signal submit_pressed
signal complete_attempt
signal next_round

# debugger gets upset if i dont use it anywhere...
func emit_submit_pressed() -> void:
	submit_pressed.emit()

func emit_minigame_complete_attempt(successful: bool) -> void:
	complete_attempt.emit(successful)

func emit_next_round() -> void:
	next_round.emit()
