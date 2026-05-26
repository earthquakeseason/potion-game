extends Label

func show_result(result_text: String) -> void:
	text = result_text
	$ResultAnimationPlayer.play("result_label")

func _on_result_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "result_label":
		queue_free()
