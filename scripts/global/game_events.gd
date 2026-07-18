extends Node

signal submit_pressed
signal complete_attempt
signal next_round
signal round_transition
signal increment_mechanical_stage
signal change_pause_state

# debugger gets upset if i dont use it anywhere...
func emit_submit_pressed() -> void:
	submit_pressed.emit()

func emit_minigame_complete_attempt(successful: bool) -> void:
	complete_attempt.emit(successful)

func emit_next_round() -> void:
	next_round.emit()

func emit_round_transition() -> void:
	round_transition.emit()

func emit_increment_mechanical_stage(shrink: bool) -> void:
	increment_mechanical_stage.emit(shrink)

## paused is true if the new state is paused
func emit_change_pause_state(paused: bool) -> void:
	change_pause_state.emit(paused)
	GameInfo.game_paused = paused
