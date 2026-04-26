extends Node

signal wavedash_initiated
signal leaderboard_initiated
signal log_value(text: String)
signal score_updated

const APIKEY: String = "wd_7d30c2f1446377963a33413b3a96dfd04d37418464362ce251214e3ef3089e45"
var leaderboard_id
var userinfo
var total_points: int

func _ready():
	print("Initiating wavedash")
	WavedashSDK.backend_connected.connect(_on_connected)
	WavedashSDK.init({"debug": true})
	WavedashSDK.ready_for_events()

func _on_connected(_payload):
	print("Playing as: ", WavedashSDK.get_username())
	emit_signal("wavedash_initiated")
	setup_leaderboard()

func setup_leaderboard():
	var leaderboard = await WavedashSDK.get_or_create_leaderboard(
		"global_rank",
		1,
		0
	)
	leaderboard_id = leaderboard.data.id if leaderboard.success else ""
	emit_signal("leaderboard_initiated")
	print("Leaderboard ID: ", leaderboard_id)

func get_my_entry():
	var leaderboard = await WavedashSDK.get_leaderboard("global_rank")
	if not leaderboard.success:
		return
	var lb_id = leaderboard.data.id
	var entries = await WavedashSDK.get_my_leaderboard_entries(lb_id)
	print(entries)
	return entries


func submit_score(score: int):
	var leaderboard = await WavedashSDK.get_leaderboard("global_rank")
	if not leaderboard.success:
		return
	var lb_id = leaderboard.data.id
	
	var result = await WavedashSDK.post_leaderboard_score(lb_id, score, true)
	if result.success:
		print("Rank: ", result.data.globalRank)
		print("score submitted successfully")
	emit_signal("score_updated")

func get_top_scores():
	var leaderboard = await WavedashSDK.get_leaderboard("global_rank")
	if not leaderboard.success:
		return
	var lb_id = leaderboard.data.id

	var response = await WavedashSDK.get_leaderboard_entries(lb_id, 0, 100, false)
	if response.success:
		return response.data
		#for entry in response.data:
			#print("#", entry.globalRank, " ", entry.username, ": ", entry.score)
			#var s = "#"+ str(entry.globalRank)+ " "+ str(entry.username)+ ": "+ str(entry.score)
