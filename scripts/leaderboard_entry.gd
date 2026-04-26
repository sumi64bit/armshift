extends Panel

func _ready() -> void:
	Global.score_updated.connect(score_updated)

func score_updated() -> void:
	$loading.show()
	var entry = await Global.get_my_entry()
	$loading.hide()
	if entry.data.is_empty():
		$unranked.show()
	else:
		$rank.text = str(int(entry.data[0].globalRank))
		$name.text = str(entry.data[0].username)
		$points.text = str(int(entry.data[0].score))
	if int(entry.data[0].globalRank) == 1:
		$global1.show()
	else:
		$global1.hide()

func reset() -> void:
	$loading.show()

func init(_name: String = "", _rank: int = 0, _points: int = 0) -> void:
	$loading.hide()
	if _rank != 0:
		$name.text = _name
		$rank.text = str(int(_rank))
		$points.text = str(int(_points))
	else:
		$unranked.show()
	if int(_rank) == 1:
		$global1.show()
	else:
		$global1.hide()


func _on_visibility_changed() -> void:
	reset()
