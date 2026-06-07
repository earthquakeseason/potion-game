extends Node2D

@onready var press_label: Label = $ButtonContainer/PressContainer/PressLabel
@onready var closing_animation_player: AnimationPlayer = $ButtonContainer/PressBorder/ClosingAnimationPlayer

const PRESS_RESULT_LABEL = preload("uid://d6870ntks1ks")
const BASE_ANIMATION_SPEED: float = 2.1

var physical_keycode_options: Array[int] = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90]
var chosen_key: int
var score: int = 0
var key_time: float = 2.1 / GameInfo.game_speed

func _ready() -> void:
	position = get_viewport().get_visible_rect().size / 2
	closing_animation_player.speed_scale = BASE_ANIMATION_SPEED / key_time
	$NewKeyTimer.start(key_time)
	get_new_key()
	$ProgressBar.value = score

func _input(event) -> void:
	if event is InputEventKey:
		# because inputeventkey triggers when keys are released and pressed
		if not event.echo and not event.is_released():
			if event.physical_keycode == chosen_key:
				var score_gained: int = score_gain($NewKeyTimer.time_left)
				score += score_gained
				$ProgressBar.value = score
				if $ProgressBar.value < $ProgressBar.max_value: get_new_key()
				else: GameEvents.emit_minigame_complete_attempt(true)
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
	chosen_key = physical_keycode_options.pick_random()
	press_label.text = OS.get_keycode_string(chosen_key)
	$NewKeyTimer.start(key_time)
	closing_animation_player.stop()
	closing_animation_player.play("press_border_shrink")
	
func key_fail() -> void:
	var result_label = PRESS_RESULT_LABEL.instantiate()
	add_child(result_label)
	result_label.show_result("Miss")
	
	score -= min(150, score)
	$ProgressBar.value = score
	get_new_key()

func round_to_dec(num, digit: int): return round(num * pow(10.0, digit)) / pow(10.0, digit)
