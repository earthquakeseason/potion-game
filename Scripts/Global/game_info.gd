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
	generate_round()

func increment_turn() -> void:
	current_round_details.completed_minigames.append(current_round_details.minigame_requirements[current_round_turn])
	current_round_turn += 1
	if current_round_details.completed_minigames.size() >= current_round_details.minigame_requirements.size():
		round_over = true

func _ready() -> void:
	set_base_info()

func get_current_minigame() -> Minigame:
	return current_round_details.minigame_requirements[current_round_turn]

func generate_round() -> void:
	current_round_details.minigame_requirements.clear()
	var available_minigame_options: Array[Minigame]
	available_minigame_options.append_array(TypingOptions.all_typing_scenes)
	available_minigame_options.append_array(Sigils.all_sigils)
	available_minigame_options.shuffle()
	for i in range(available_minigame_options.size()):
		if not available_minigame_options[i].acceptable_next.is_empty():
			current_round_details.minigame_requirements.append(available_minigame_options[i])
			print(current_round_details.minigame_requirements.back().minigame_name)
			break
	while 0 == 0:
		if not current_round_details.minigame_requirements.back().acceptable_next.is_empty():
			print(current_round_details.minigame_requirements.back().minigame_name)
			var found: bool = false
			for i in range(current_round_details.minigame_requirements.back().acceptable_next.size()):
				print(current_round_details.minigame_requirements.back().minigame_name)
				if not current_round_details.minigame_requirements.has(current_round_details.minigame_requirements.back().acceptable_next[i]):
					found = true
					current_round_details.minigame_requirements.append(current_round_details.minigame_requirements.back().acceptable_next[i])
					break
			if not found:
				print("not found")
				return
		else:
			return
