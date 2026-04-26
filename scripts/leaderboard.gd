extends ColorRect
@onready var board_list: VBoxContainer = $ScrollContainer/board_list
const LEADERBOARD_ENTRY = preload("uid://w5gfer5gsxsx")

func load_leaderboard() -> void:
	show()
	$my_ranking.text = ""
	$loading.show()
	for c in board_list.get_children():
		c.queue_free()
	$my_ranking.text = ""
	var lb = await Global.get_top_scores()
	for entry in lb:
		var le = LEADERBOARD_ENTRY.instantiate()
		board_list.add_child(le)
		le.init(entry.username, entry.globalRank, entry.score)
	var mye = await Global.get_my_entry()
	$my_ranking.text = str(int(mye.data[0].globalRank))
	$loading.hide()


func _on_close_pressed() -> void:
	$open_lb_anim.play_backwards("show")


func _on_button_pressed() -> void:
	$open_lb_anim.play("show")
	$loading.show()
	load_leaderboard()
