extends Node

const PHYSICAL_KEYCODE_OPTIONS: Array[int] = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90]

var round_num: int
var current_round_details: Round
var round_over: bool
var demand: float
var ingredient_index: int
var ingredient_step_index: int

func set_base_info() -> void:
	current_round_details = Round.new()
	round_num = 0
	demand = 1.0
	ingredient_index = 0
	ingredient_step_index = 0
	current_round_details.selected_potion = Potions.all_potions.pick_random()

func increment_turn() -> void:
	if current_round_details.selected_potion.ingredients[ingredient_index].preperation_minigames.size() - 1 > ingredient_step_index:
		ingredient_step_index += 1
		return
	if current_round_details.selected_potion.ingredients.size() - 1 > ingredient_index:
		ingredient_index += 1
		ingredient_step_index = 0
		return
	round_over = true

func increment_round() -> void:
	round_num += 1
	demand = 1.0 + (float(round_num) / 10)
	current_round_details.selected_potion = Potions.all_potions.pick_random()
	ingredient_index = 0
	ingredient_step_index = 0
	round_over = false

func _ready() -> void:
	set_base_info()

func get_current_minigame() -> Minigame:
	return current_round_details.selected_potion.ingredients[ingredient_index].preperation_minigames[ingredient_step_index]

func update_time_left(current_time: float) -> void:
	current_round_details.time = current_time
