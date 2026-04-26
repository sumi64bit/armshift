extends Panel

var card_id: String

func _ready() -> void:
	for c in $TextureRect2.get_children():
		c.hide()
	match(card_id):
		"points_card":
			$TextureRect2/get_points.show()
		"time_card":
			$TextureRect2/add_time.show()
		"robot_damage_reduction":
			$TextureRect2/weaken_telebots.show()
		"truck_engine":
			$TextureRect2/truck_engine.show()
		"box_reinforcement":
			$TextureRect2/strengthen_boxes.show()

func _on_button_mouse_entered() -> void:
	$AnimationPlayer.play("in")

func _on_button_mouse_exited() -> void:
	$AnimationPlayer.play("out")

func _on_button_pressed() -> void:
	for c in get_parent().get_children():
		c.get_node("Button").disabled = true
	UpgradeSystem.apply_upgrade(card_id)
	$TextureRect3/AnimationPlayer.play("glow")
	get_parent().get_parent().get_parent().upgrade_finished(self)
	await get_tree().create_timer(1).timeout
	dispatch()

func dispatch() -> void:
	$load_anim.play_backwards("load")
	await $load_anim.animation_finished
	queue_free()
