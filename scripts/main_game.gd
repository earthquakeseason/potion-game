extends CanvasLayer

const DRAWING_SCREEN: PackedScene = preload("uid://dwobt7r1ywjtw")
const DRAWING = preload("uid://bil0asoipqfqw")
const KNIFE = preload("uid://vwiwro34v66g")
const COUNTDOWN_TEXT = preload("uid://c762pif0pw7e5")
const ROUND_COMPLETE_SCREEN = preload("uid://ba8w116ntbkex")
const MAX_TIME: int = 60

var round_time: float
var drawing_scene: Node
var typing_scene: Node
var results_scene: Node
var selected_potion: Potion
@onready var demand_label: RichTextLabel = $GameDetailsContainer/VBoxContainer/DemandLabel
@onready var potion_label: Label = $GameDetailsContainer/VBoxContainer/PotionLabel

func _ready() -> void:
	GameEvents.complete_attempt.connect(_on_complete_attempt)
	GameEvents.next_round.connect(_on_next_round)
	start_round()
	start_turn()

func _process(_delta: float) -> void:
	$RoundTimeProgress.value = 100 * ($RoundTimer.time_left / round_time)

func _on_complete_attempt(successful: bool) -> void:
	if successful:
		if GameInfo.get_current_minigame().minigame_type == Minigame.MinigameTypes.TYPING:
			typing_scene.queue_free()
		else:
			drawing_scene.queue_free()
		GameInfo.increment_turn()
		if GameInfo.round_over:
			results_scene = ROUND_COMPLETE_SCREEN.instantiate()
			add_child(results_scene)
			$RoundTimer.stop()
		else:
			start_turn()
		GameInfo.update_time_left($RoundTimer.time_left)

func _on_next_round() -> void:
	results_scene.queue_free()
	GameInfo.increment_round()
	start_turn()
	start_round()

func start_turn() -> void:
	var minigame_requirement_current: Minigame = GameInfo.get_current_minigame()
	var countdown_text_instance = COUNTDOWN_TEXT.instantiate()
	if minigame_requirement_current.minigame_type == Minigame.MinigameTypes.TYPING:
		typing_scene = minigame_requirement_current.scene.instantiate()
		add_child(typing_scene)
		countdown_text_instance.start_animation("Type!")
		add_child(countdown_text_instance)
	else:
		drawing_scene = DRAWING_SCREEN.instantiate()
		add_child(drawing_scene)
		countdown_text_instance.start_animation("Draw!")
		add_child(countdown_text_instance)

func start_round() -> void:
	demand_label.text = "Demand: " + str(int((GameInfo.demand - 1) * 100)) + "%"
	selected_potion = GameInfo.current_round_details.selected_potion
	round_time = (MAX_TIME * selected_potion.potion_time_modification) / ((1 + (GameInfo.demand - 1)) / 1.5)
	$RoundTimer.start(round_time)
	potion_label.text = selected_potion.name
	# clean up from possible previous rounds
	for child: Node in $NextUpContainer/HBoxContainer.get_children():
		child.queue_free()
	for ingredient: Ingredient in selected_potion.ingredients:
		for minigame: Minigame in ingredient.preperation_minigames:
			var next_up_symbol = TextureRect.new()
			if (minigame.minigame_type == Minigame.MinigameTypes.TYPING):
				next_up_symbol.texture = KNIFE
			else:
				next_up_symbol.texture = DRAWING
			$NextUpContainer/HBoxContainer.add_child(next_up_symbol)
