extends Node2D

const PRESS_RESULT_LABEL = preload("uid://d6870ntks1ks")
const BASE_ANIMATION_SPEED: float = 2.1
const BASE_MAX_SCORE: int = 1500
## 5 total stages, not starting at 0
const INGREDIENT_STAGES_COUNT: int = 5
const CRUSH = preload("res://scenes/keyboard/crush.tscn")
const SLICE = preload("res://scenes/keyboard/slice.tscn")

var chosen_key: int
var score: int = 0
var key_time: float = 2.1 / (1 + (((float)(GameInfo.round_num)) / 15))
var first_key: bool = false
var ingredient_stage_counter: int = 0
var current_minigame: Minigame
@onready var press_label: Label = $ButtonContainer/PressContainer/PressLabel
@onready var closing_animation_player: AnimationPlayer = $ButtonContainer/PressBorder/ClosingAnimationPlayer

func _ready() -> void:
	current_minigame = GameInfo.get_current_minigame()
	# why can't i preload these resources? nobody knows
	if current_minigame == load("res://resources/mechanical/crushing.tres"):
		var crush_instance: Node = CRUSH.instantiate()
		crush_instance.position.x = -400 
		add_child(crush_instance)
	# technically could be else as ideally it could never be anything else but you never know i guess
	elif current_minigame == load("res://resources/mechanical/cutting.tres"):
		var slice_instance: Node = SLICE.instantiate()
		slice_instance.position.x = -400 
		add_child(slice_instance)

	position = get_viewport().get_visible_rect().size / 2
	first_key = true
	get_new_key()

func _input(event) -> void:
	if event is InputEventKey:
		# because inputeventkey triggers when keys are released and pressed
		if not event.echo and not event.is_released():
			if event.physical_keycode == chosen_key:
				var score_gained: int = score_gain($NewKeyTimer.time_left)
				score += score_gained
				if score < BASE_MAX_SCORE:
					get_new_key()
					print("original: " + str(ingredient_stage_counter))
					ingredient_stage_counter += score_gained
					print("new: " + str(ingredient_stage_counter))
				else:
					GameEvents.emit_minigame_complete_attempt(true)
					GameInfo.typing_accuracy += 1
				if ingredient_stage_counter >= float(BASE_MAX_SCORE) / 6:
					ingredient_stage_counter = 0
					GameEvents.emit_increment_mechanical_stage(true)
					print("trigged")
				else:
					GameEvents.emit_increment_mechanical_stage(false)
			else:
				key_fail()

func _on_new_key_timer_timeout() -> void:
	key_fail()

# reward players for doing it as fast as possible
func score_gain(time_left: float) -> int:
	var result_label = PRESS_RESULT_LABEL.instantiate()
	add_child(result_label)

	if time_left > (0.5 / 2) * key_time  && time_left <= (0.9 / 2) * key_time:
		result_label.show_result("Close")
		return 10
	elif time_left > (0.9 / 2) * key_time && time_left <= (1.1 / 2) * key_time:
		result_label.show_result("Fine")
		return 100
	elif time_left > (1.1 / 2) * key_time && time_left <= (1.5 / 2) * key_time:
		result_label.show_result("Good")
		return 150
	else:
		result_label.show_result("Perfect")
		return 300

func get_new_key() -> void:
	chosen_key = GameInfo.PHYSICAL_KEYCODE_OPTIONS.pick_random()
	press_label.text = OS.get_keycode_string(chosen_key)
	if first_key:
		first_key = false
		# to make the first key slow and easy to get
		$NewKeyTimer.start(5)
		closing_animation_player.speed_scale = BASE_ANIMATION_SPEED / 5
	else:
		$NewKeyTimer.start(key_time)
		closing_animation_player.speed_scale = BASE_ANIMATION_SPEED / key_time
	closing_animation_player.stop()
	closing_animation_player.play("press_border_shrink")

func key_fail() -> void:
	var result_label = PRESS_RESULT_LABEL.instantiate()
	add_child(result_label)
	result_label.show_result("Miss")
	GameInfo.typing_accuracy -= 1
	score -= min(150, score)
	get_new_key()

func round_to_dec(num, digit: int): return round(num * pow(10.0, digit)) / pow(10.0, digit)
