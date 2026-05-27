extends Button

func _on_pressed() -> void:
	GameEvents.emit_submit_pressed()
