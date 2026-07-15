extends Node

signal submit_pressed
signal complete_attempt
signal next_round
signal round_transition
signal increment_mechanical_stage

# debugger gets upset if i dont use it anywhere...
func emit_submit_pressed() -> void:
	submit_pressed.emit()

func emit_minigame_complete_attempt(successful: bool) -> void:
	complete_attempt.emit(successful)

func emit_next_round() -> void:
	next_round.emit()

func emit_round_transition() -> void:
	round_transition.emit()

func emit_increment_mechanical_stage() -> void:
	increment_mechanical_stage.emit()
