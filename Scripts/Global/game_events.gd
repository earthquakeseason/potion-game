extends Node

signal submit_pressed
signal recognition_attempt

# debugger gets upset if i dont use it anywhere...
func emit_submit_pressed() -> void:
	submit_pressed.emit()

func emit_recognition_attempt(successful: bool) -> void:
	recognition_attempt.emit(successful)
