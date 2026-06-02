extends Node

var round_num: int
var current_round_turn: int
var current_round_details: Round
var round_over: bool

func set_base_info() -> void:
	current_round_turn = 0
	round_num = 0
	current_round_details = Round.new()
	current_round_details.minigame_requirements.append(Sigils.flame_sigil)
	current_round_details.minigame_requirements.append(TypingOptions.cutting)

func increment_turn() -> void:
	current_round_details.completed_minigames.append(current_round_details.minigame_requirements[current_round_turn])
	current_round_turn += 1
	if current_round_details.completed_minigames.size() >= current_round_details.minigame_requirements.size():
		round_over = true

func _ready() -> void:
	set_base_info()

func get_current_minigame() -> Minigame:
	return current_round_details.minigame_requirements[current_round_turn]
