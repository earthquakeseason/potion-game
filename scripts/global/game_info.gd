extends Node

const PHYSICAL_KEYCODE_OPTIONS: Array[int] = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90]

var round_num: int
var current_round_details: Round
var round_over: bool
var demand: int
var game_speed: float = 1.0
var ingredient_index: int
var ingredient_step_index: int

func set_base_info() -> void:
	current_round_details = Round.new()
	round_num = 0
	demand = 10
	ingredient_index = 0
	ingredient_step_index = 0

func increment_turn() -> void:
	if current_round_details.selected_potion.ingredients[ingredient_index].secondary_prepration_minigame != null:
		ingredient_step_index += 1
		return
	elif current_round_details.selected_potion.ingredients.size() - 1 > ingredient_index:
		ingredient_index += 1
		return
	else:
		round_over = true

func _ready() -> void:
	set_base_info()

func get_current_minigame() -> Minigame:
	if ingredient_step_index == 0:
		return current_round_details.selected_potion.ingredients[ingredient_index].primary_preperation_minigame
	else:
		return current_round_details.selected_potion.ingredients[ingredient_index].secondary_prepration_minigame
