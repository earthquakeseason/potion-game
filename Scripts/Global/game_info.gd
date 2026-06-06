extends Node

var round_num: int
var current_round_turn: int
var current_round_details: Round
var round_over: bool
var demand: int
var game_speed: float = 1.0

func set_base_info() -> void:
	current_round_turn = 0
	round_num = 0
	current_round_details = Round.new()
	current_round_details.minigame_requirements.append(TypingOptions.all_typing_scenes.pick_random())
	current_round_details.minigame_requirements.append(Sigils.all_sigils.pick_random())

func increment_turn() -> void:
	current_round_details.completed_minigames.append(current_round_details.minigame_requirements[current_round_turn])
	current_round_turn += 1
	if current_round_details.completed_minigames.size() >= current_round_details.minigame_requirements.size():
		round_over = true

func _ready() -> void:
	set_base_info()

func get_current_minigame() -> Minigame:
	return current_round_details.minigame_requirements[current_round_turn]
