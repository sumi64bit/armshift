extends Control

func pop(_name: String, _from, _to) -> void:
	$AnimationPlayer.play("in")
	$Panel2/HBoxContainer/name.text = _name
	$Panel2/HBoxContainer/from.text = str(_from)
	$Panel2/HBoxContainer/to.text = str(_to)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
