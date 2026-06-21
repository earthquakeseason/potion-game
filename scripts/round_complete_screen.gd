extends Control

const STAR_EMPTY = preload("uid://clxvuytl3xnv4")
const STAR = preload("uid://cp4ph5k08jxmn")

@onready var title_label: Label = $ContentContainer/VBoxContainerTop/TitleLabel
@onready var time_label: Label = $ContentContainer/VBoxContainerTop/TimeLabel
@onready var stars: Control = $ContentContainer/VBoxContainerTop/Stars

func _ready() -> void:
	title_label.text = "You successfully brewed " + GameInfo.current_round_details.selected_potion.name
	time_label.text = "Time left: " + str(round(GameInfo.current_round_details.time)) + "s"
	for i in range(3):
		var star: TextureRect = TextureRect.new()
		star.texture = STAR
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.size = Vector2(125.0, 125.0)
		star.position = Vector2(0 + + (i * 135), 0)
		star.pivot_offset = Vector2(62.5, 62.5)
		GameInfo.game
		GameInfo.current_round_details.selected_potion.potion_time_modification
		match i:
			0:
				star.rotation = deg_to_rad(-10)
			2:
				star.rotation = deg_to_rad(10)
		stars.add_child(star)

func _on_button_pressed() -> void:
	GameEvents.emit_next_round()
