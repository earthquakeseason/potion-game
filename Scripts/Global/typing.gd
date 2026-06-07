extends Node

const TYPING_SCREEN = preload("uid://b16g7xwgvn2wc")

var cutting: Typing = Typing.new()
var all_typing_scenes: Array[Typing] = [cutting]

func _ready() -> void:
	cutting.scene = TYPING_SCREEN
	cutting.acceptable_next = [Sigils.flame_sigil, Sigils.frost_sigil]
	cutting.minigame_name = "cutting"
