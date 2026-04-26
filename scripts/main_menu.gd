extends ColorRect

var is_ready: bool = false

func _ready() -> void:
	show()
	Global.wavedash_initiated.connect(login_success)

func login_success() -> void:
	is_ready = true
	$loading.hide()
	$Control.show()
	$username_label.show()
	$leaderboard_entry.show()
	var entry = await Global.get_my_entry()
	print("entry result: ", entry)
	if entry.data.is_empty():
		$leaderboard_entry.init()
	else:
		$leaderboard_entry.init(entry.data[0].username, entry.data[0].globalRank, entry.data[0].score)

func _on_start_game_pressed() -> void:
	if is_ready:
		$starting_anim.play("start")
		is_ready = false
		MusicManager.lower_volume()
		$"../../shift_timer".start()
		$"../../spawns/spawner"._on_spawn_timer_timeout()
