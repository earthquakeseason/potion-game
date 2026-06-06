extends CanvasLayer

var chosen_sigil: Sigil = GameInfo.get_current_minigame()

func _ready() -> void:
	$SigilTextureRect.texture = chosen_sigil.icon
