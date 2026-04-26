extends ColorRect

const UPGRADE_PANEL = preload("uid://b87x6gwnoo3md")

func get_upgrades() -> void:
	if get_parent().get_parent().upgrade_passed == true:
		return
	$AnimationPlayer.play("show")
	var ups = UpgradeSystem.get_two_upgrade_cards()
	for up in ups:
		var upanel = UPGRADE_PANEL.instantiate()
		upanel.card_id = up
		$Control/upgrades_deck.add_child(upanel)
		await get_tree().create_timer(0.2).timeout

func upgrade_finished(chosen: Control) -> void:
	get_parent().get_parent().upgrade_passed = true
	for c in $Control/upgrades_deck.get_children():
		if c == chosen:
			pass
		else:
			c.dispatch()
	$AnimationPlayer.play_backwards("show")
