extends CanvasLayer

const DRAWING_SCREEN: PackedScene = preload("uid://dwobt7r1ywjtw")
const DRAWING = preload("uid://bil0asoipqfqw")
const KNIFE = preload("uid://vwiwro34v66g")
const COUNTDOWN_TEXT = preload("uid://c762pif0pw7e5")
const MAX_TIME: int = 60

var drawing_scene: Node
var typing_scene: Node
@onready var demand_label: RichTextLabel = $GameDetailsContainer/VBoxContainer/DemandLabel
@onready var potion_label: Label = $GameDetailsContainer/VBoxContainer/PotionLabel

func _ready() -> void:
	demand_label.text = "Demand: " + str(GameInfo.demand) + "%"
	GameEvents.complete_attempt.connect(_on_complete_attempt)
	$RoundTimer.start(MAX_TIME)
	start_turn()
	potion_label.text = GameInfo.current_round_details.selected_potion.name
	for ingredient: Ingredient in GameInfo.current_round_details.selected_potion.ingredients:
		for minigame: Minigame in ingredient.preperation_minigames:
			var next_up_symbol = TextureRect.new()
			if (minigame.minigame_type == Minigame.MinigameTypes.TYPING):
				next_up_symbol.texture = KNIFE
			else:
				next_up_symbol.texture = DRAWING
			$NextUpContainer/HBoxContainer.add_child(next_up_symbol)

func _process(_delta: float) -> void:
	$RoundTimeProgress.value = 100 * ($RoundTimer.time_left / MAX_TIME)

func _on_complete_attempt(successful: bool) -> void:
	if successful:
		if GameInfo.get_current_minigame().minigame_type == Minigame.MinigameTypes.TYPING:
			typing_scene.queue_free()
		else:
			drawing_scene.queue_free()
		GameInfo.increment_turn()
		if GameInfo.round_over:
			get_tree().change_scene_to_file("res://Scenes/victory_screen.tscn")
		else:
			start_turn()

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
