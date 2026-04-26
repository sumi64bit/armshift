extends Node2D

func _ready() -> void:
	var sv = randf_range(1.0, 1.5)
	scale = Vector2(sv, sv)

func init(value: int) -> void:
	$Label.text = str(value)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
