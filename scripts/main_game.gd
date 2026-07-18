extends CanvasLayer

const DRAWING_SCREEN: PackedScene = preload("uid://dwobt7r1ywjtw")
const DRAWING = preload("uid://bil0asoipqfqw")
const KNIFE = preload("uid://vwiwro34v66g")
const POTION = preload("uid://b01ve6h62ss44")
const ROUND_TYPE_DISPLAY = preload("res://scenes/round_type_display.tscn")
const ROUND_COMPLETE_SCREEN = preload("uid://ba8w116ntbkex")
const NEXT_UP_CONTAINER_BASE = preload("uid://dmffrccp1rsgw")
const NEXT_UP_CONTAINER_CURRENT = preload("uid://cuc63iatlc1ai")
const POTION_BOTTLING = preload("uid://c47r5qe8xe2ah")
const OPTIONS = preload("res://scenes/options.tscn")

var round_time: float
var game_scene: Node
var options_scene: Node
var round_complete_scene: Node
var selected_potion: Potion

@onready var demand_label: RichTextLabel = $GameDetailsContainer/VBoxContainer/DemandLabel
@onready var potion_label: Label = $GameDetailsContainer/VBoxContainer/PotionLabel
@onready var next_up_h_box: HBoxContainer = $NextUpContainer/HBoxContainer

func _ready() -> void:
	GameEvents.complete_attempt.connect(_on_complete_attempt)
	GameEvents.next_round.connect(_on_next_round)
	GameEvents.change_pause_state.connect(_on_pause_state_changed)
	
	options_scene = OPTIONS.instantiate()
	
	start_round()
	start_turn()

func _process(_delta: float) -> void:
	$RoundTimeProgress.value = 100 * ($RoundTimer.time_left / round_time)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if GameInfo.game_paused:
			GameEvents.emit_change_pause_state(false)
			remove_child(options_scene)
		else:
			GameEvents.emit_change_pause_state(true)
			add_child(options_scene)

func _on_complete_attempt(successful: bool) -> void:
	if successful:
		GameInfo.increment_turn()
		GameInfo.update_time_left($RoundTimer.time_left)
		if GameInfo.round_over:
			round_complete_scene = ROUND_COMPLETE_SCREEN.instantiate()
			add_child(round_complete_scene)
			$RoundTimer.paused = true
		else:
			# remove previous scene
			game_scene.queue_free()
			start_turn()

func _on_next_round() -> void:
	game_scene.queue_free()
	GameInfo.increment_round()
	start_round()
	start_turn()

func start_round() -> void:
	demand_label.text = str(9 - GameInfo.round_num) + " potions left"
	selected_potion = GameInfo.current_round_details.selected_potion
	round_time = (GameInfo.MAX_TIME * selected_potion.potion_time_modification) / (1 + (((float)(GameInfo.round_num)) / 10))
	$RoundTimer.start(round_time)
	$RoundTimer.paused = false
	potion_label.text = selected_potion.name
	
	# clean up from possible previous rounds
	for child: Node in next_up_h_box.get_children():
		# required because queue_free takes too long to remove form the scene tree
		# so the add_child parts get called too soon (to my knowledge)
		next_up_h_box.remove_child(child)
		child.queue_free()

	for ingredient: Ingredient in selected_potion.ingredients:
		for minigame: Minigame in ingredient.preperation_minigames:
			var next_up_container: PanelContainer = PanelContainer.new()
			if (minigame.minigame_type == Minigame.MinigameTypes.TYPING):
				next_up_container = create_next_up_container(KNIFE)
			else:
				next_up_container = create_next_up_container(DRAWING)
			next_up_h_box.add_child(next_up_container)
	next_up_h_box.add_child(create_next_up_container(POTION))

func create_next_up_container(texture: Texture2D) -> PanelContainer:
	var next_up_container: PanelContainer = PanelContainer.new()
	var next_up_symbol = TextureRect.new()

	next_up_container.add_theme_stylebox_override("panel", NEXT_UP_CONTAINER_BASE)
	next_up_symbol.texture = texture
	next_up_container.add_child(next_up_symbol)
	
	return next_up_container

func start_turn() -> void:
	var minigame: Minigame = GameInfo.get_current_minigame()
	var round_type_display = ROUND_TYPE_DISPLAY.instantiate()
	var text: String

	match minigame.minigame_type:
		Minigame.MinigameTypes.TYPING:
			game_scene = minigame.scene.instantiate()
			change_table_dim_state(false)
			text = "Type!"

		Minigame.MinigameTypes.DRAWING:
			game_scene = DRAWING_SCREEN.instantiate()
			change_table_dim_state(true)
			text = "Draw!"

		Minigame.MinigameTypes.BOTTLING:
			game_scene = POTION_BOTTLING.instantiate()
			change_table_dim_state(false)
			text = "Bottle!"

	add_child(game_scene)
	round_type_display.start_animation(text)
	add_child(round_type_display)

	var current_ingredient_position = GameInfo.total_ingredient_step
	var current_next_box: PanelContainer = next_up_h_box.get_child(current_ingredient_position)
	current_next_box.add_theme_stylebox_override("panel", NEXT_UP_CONTAINER_CURRENT)
	
	if current_ingredient_position > 0:
		next_up_h_box.get_child(current_ingredient_position - 1).add_theme_stylebox_override("panel", NEXT_UP_CONTAINER_BASE)

func _on_round_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/lose_screen.tscn")

func change_table_dim_state(dimmed_table: bool) -> void:
	var tween: Tween = create_tween()
	if dimmed_table:
		tween.tween_property($TableTexture, "self_modulate", Color(0.4, 0.4, 0.4, 1.0), 0.2)
	else:
		tween.tween_property($TableTexture, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

func _on_pause_state_changed(paused: bool) -> void:
	if not has_node("RoundCompleteScreen"):
		$RoundTimer.paused = paused
