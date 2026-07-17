extends CanvasLayer

var chosen_sigil: Sigil = GameInfo.get_current_minigame()
@onready var sigil_texture_rect: TextureRect = $SigilBackgroundTextureRect/SigilTextureRect

func _ready() -> void:
	sigil_texture_rect.texture = chosen_sigil.icon
