extends Node2D

const NORMAL_BOX = preload("uid://dj8dbpscnoo6h")
const CARGO_BOX = preload("uid://cvqutsatq22rn")
const CARGO_BOX_2 = preload("uid://c31ybfr4rhho1")
const TELEROBO = preload("uid://bqrna5lkggvq4")

var bot_spawnpoints: Array = [
	Vector2(700, -1200),
	Vector2(600, -1200),
	Vector2(500, -1200),
	Vector2(400, -1200),
	Vector2(300, -1200),
	Vector2(200, -1200),
	Vector2(100, -1200),
	Vector2(0, -1200),
	Vector2(-100, -1200)
]

func spawn() -> void:
	var x = [NORMAL_BOX, CARGO_BOX, CARGO_BOX_2, TELEROBO].pick_random().instantiate()
	if x.is_in_group("enemy"):
		x.position = bot_spawnpoints.pick_random()
	else:
		x.position = position
	get_parent().add_child(x)
	#var r = randi_range(0, 2)
	#match(r):
		#0:
			#var box = NORMAL_BOX.instantiate()
			#box.position = position
			#get_parent().add_child(box)
		#1:
			#var box = CARGO_BOX.instantiate()
			#box.position = position
			#get_parent().add_child(box)
		#2:
			#var box = CARGO_BOX_2.instantiate()
			#box.position = position
			#get_parent().add_child(box)

func _on_spawn_timer_timeout() -> void:
	spawn()
	$spawnTimer.start(randf_range(0.5, 5.0) - get_parent().get_parent().shift/10)
