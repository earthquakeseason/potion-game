extends CanvasLayer

const DRAWING_SCREEN: PackedScene = preload("uid://dwobt7r1ywjtw")
const MAX_TIME: int = 60

var drawing_scene: Node

func _ready() -> void:
	GameEvents.recognition_attempt.connect(_on_recognition_attempt)
	$RoundTimer.start(MAX_TIME)
	start_turn()

func _process(delta: float) -> void:
	$RoundTimeProgress.value = 100 * ($RoundTimer.time_left / MAX_TIME)

func _on_recognition_attempt(successful: bool) -> void:
	if successful and drawing_scene != null:
		drawing_scene.queue_free()
		next_turn()

func start_turn() -> void:
	var minigame_requirement_current: Minigame = GameInfo.get_current_minigame()
	if minigame_requirement_current.minigame_type == Minigame.MinigameType.TYPING:
		var typing_scene = minigame_requirement_current.scene.instantiate()
		add_child(typing_scene)
	else:
		drawing_scene = DRAWING_SCREEN.instantiate()
		add_child(drawing_scene)

func next_turn() -> void:
	GameInfo.increment_turn()
	if GameInfo.round_over:
		# do stuff relating to when the round has finished
		pass
	else:
		start_turn()
