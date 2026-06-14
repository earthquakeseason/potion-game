extends Label

func _ready() -> void:
	GameEvents.complete_attempt.connect(_on_complete_attempt)
	
func _on_complete_attempt(successful: bool):
	if !successful: text = "Your sigil is unrecognisable!"
