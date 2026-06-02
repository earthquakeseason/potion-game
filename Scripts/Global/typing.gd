extends Node

const TYPING_SCREEN = preload("uid://b16g7xwgvn2wc")

var cutting: Typing = Typing.new()
var all_typing_scenes: Array[Typing] = [cutting]

func _ready() -> void:
	cutting.scene = TYPING_SCREEN
	cutting.minigame_type = cutting.MinigameType.TYPING
