extends Node2D
@onready var camera: Camera2D = $Camera
@onready var arm: Node2D = $axis_ledges/vaxis/haxis/arm_mountpoint/arm
var cam_target_position: Vector2
const UPGRADE_NOTIFICATION = preload("uid://c2tcc8qg15ppo")

var debug: bool = false

const shift_duration:= 360
const starting_points:= 0

var deliveries: int = 0
var points: int = 0
var damages: int = 0
var shift: int = 1
var shift_max_points: int = 3000
var remaining_time: int = 10

var calculate_shiftvalues: bool = false
var shiftend_points: int = 0
var completion: int = 0
var completion_dec: int = 0

var extra_time: int = 0
var extra_points: int = 0

var upgrade_passed: bool = false
var ready_for_next_shift: bool = false

func _ready() -> void:
	UpgradeSystem.inf_upgrade.connect(apply_inf_upgrade)
	if debug:
		$ui/main_menu/Control.show()
		$ui/main_menu/loading.hide()
		$ui/main_menu.is_ready = true
	$ui/time_panel/time.text = format_time(remaining_time)
	points = starting_points
	remaining_time = shift_duration
	refresh_status()
	$ui/time_panel/seconds.rotation = randf_range(0.0, PI*2)
	$ui/time_panel/minutes.rotation = randf_range(0.0, PI*2)
	Global.wavedash_initiated.connect(sdk_loaded)

func apply_inf_upgrade(id) -> void:
	match(id):
		"points_card":
			var rand_value = randi_range(1, 1000)
			post_upgrade_notification("Points: ", points, points+rand_value)
			extra_points += rand_value
		"time_card":
			post_upgrade_notification("Time: ", remaining_time, remaining_time+60)
			extra_time += 60
	refresh_status()

func post_upgrade_notification(_name, _from, _to) -> void:
	var n = UPGRADE_NOTIFICATION.instantiate()
	$ui/notifications_list.add_child(n)
	n.pop(_name, _from, _to)

func sdk_loaded() -> void:
	$ui/main_menu/username_label.text = "Welcome "+str(WavedashSDK.get_username())
	Global.userinfo = WavedashSDK.get_user()

func _process(delta: float) -> void:
	cam_target_position = lerp(cam_target_position, arm.global_position + Vector2(0, 200), 0.2)
	cam_target_position = cam_target_position.clamp(Vector2(150, -1000), Vector2(1000, -465))
	camera.position = cam_target_position
	
	if calculate_shiftvalues:
		if shiftend_points < points - 100:
			shiftend_points = lerp(shiftend_points, points, 0.1)
			$ui/ShiftClearPanel/Control/Panel/points.text = str(shiftend_points)
		else:
			shiftend_points = points
			calculate_shiftvalues = false
			count_percentage()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and ready_for_next_shift and upgrade_passed:
			calculate_next_shift_values()

func count_percentage() -> void:
	#await get_tree().create_timer(0.5).timeout
	var per: Array = get_percentage_parts(shiftend_points, shift_max_points)
	
	$ui/ShiftClearPanel/Control/TextureRect/S.hide()
	$ui/ShiftClearPanel/Control/TextureRect/A.hide()
	$ui/ShiftClearPanel/Control/TextureRect/B.hide()
	$ui/ShiftClearPanel/Control/TextureRect/X.hide()
	
	if per[0] >= 100:
		$ui/ShiftClearPanel/Control/TextureRect/S.show()
		$ui/ShiftClearPanel/Control/Panel/S_glow/AnimationPlayer.play("glow")
	elif per[0] >= 80:
		$ui/ShiftClearPanel/Control/TextureRect/A.show()
	elif per[0] >= 50:
		$ui/ShiftClearPanel/Control/TextureRect/B.show()
	else:
		upgrade_passed = true
		$ui/ShiftClearPanel/Control/TextureRect/X.show()
	$ui/ShiftClearPanel/end_message.text = $ui/ShiftClearPanel.get_shift_end_message(per[0])
	$ui/ShiftClearPanel/message_anim.play("show")
	$ui/ShiftClearPanel/Control/Panel/completion.text = "%"+str(per[0])
	$ui/ShiftClearPanel/Control/Panel/completion_dec.text = str(per[1])
	#await get_tree().create_timer(0.5).timeout
	$ui/ShiftClearPanel/Control/AnimationPlayer.play("show")
	Global.submit_score(Global.total_points)
	$ui/ShiftClearPanel/next_shift_label.show()
	ready_for_next_shift = true
	if per[0] >= 50:
		$ui/upgrades_menu.get_upgrades()
	

func calculate_next_shift_values() -> void:
	ready_for_next_shift = false
	shift_max_points = round(shift_max_points*1.3)
	shift += 1
	points = starting_points + extra_points
	extra_points = 0
	deliveries = 0
	damages = 0
	shiftend_points = 0
	remaining_time = shift_duration + extra_time
	extra_time = 0
	upgrade_passed = false
	$ui/ShiftClearPanel/message_anim.play("RESET")
	$ui/ShiftClearPanel/AnimationPlayer.play("RESET")
	$ui/ShiftClearPanel/Control/AnimationPlayer.play("RESET")
	$ui/ShiftClearPanel/Control/Panel/S_glow/AnimationPlayer.play("glow")
	$ui/status_panel/shift_progress.value = 0.0
	$ui/ShiftClearPanel/Control/Panel/S_glow/AnimationPlayer.play("RESET")
	$ui/ShiftClearPanel/Control/TextureRect/S.hide()
	$ui/ShiftClearPanel/Control/TextureRect/A.hide()
	$ui/ShiftClearPanel/Control/TextureRect/B.hide()
	$ui/ShiftClearPanel/Control/TextureRect/X.hide()
	$ui/ShiftClearPanel/next_shift_label.hide()
	$shift_timer.start()
	refresh_status()
	clean_level()

func clean_level() -> void:
	$axis_ledges.haxis_value = $axis_ledges.HAXIS_RANGE.y
	$axis_ledges.vaxis_value = $axis_ledges.VAXIS_RANGE.y
	for c in $spawns.get_children():
		if c.is_in_group("cargo") or c.is_in_group("enemy"):
			c.call_deferred("queue_free")

func get_percentage_parts(value: float, max_value: float) -> Array[int]:
	# Prevent division by zero
	if max_value <= 0:
		return [0, 0]
	
	# Calculate percentage (0.0 to 100.0)
	var percentage: float = clamp((value / max_value) * 100.0, 0.0, 100.0)
	
	# Extract integer part
	var int_part: int = int(percentage)
	
	# Extract decimal part and round to 2 digits (e.g., 12.345 -> 35)
	var decimal_part: int = int(round((percentage - int_part) * 100))
	
	# Handle edge case where decimal rounding results in 100
	if decimal_part >= 100:
		int_part += 1
		decimal_part = 0
		
	return [int_part, decimal_part]

func refresh_status() -> void:
	$ui/status_panel/HBoxContainer/deliveries_count.text = str(deliveries)
	$ui/status_panel/HBoxContainer2/current_points.text = str(points)
	$ui/status_panel/HBoxContainer2/max_points.text = str(shift_max_points)
	$ui/status_panel/shift.text = str(shift)
	$ui/status_panel/shift_progress.max_value = shift_max_points
	$ui/status_panel/shift_progress.value = points
	if points >= shift_max_points:
		shift_ended()
		$shift_timer.stop()

func shift_ended() -> void:
	MusicManager.increase_volume()
	Global.total_points += points
	Global.total_points += damages
	$ui/ShiftClearPanel/Control/Panel/HBoxContainer/damages.text = str(damages)
	$ui/ShiftClearPanel/AnimationPlayer.play("show")
	calculate_shiftvalues = true
	$ui/ShiftClearPanel/Control/Panel/completion.text = "%00"
	$ui/ShiftClearPanel/Control/Panel/completion_dec.text = "00"
	$ui/ShiftClearPanel/Control/Panel/points.text = "0"

func _on_shift_timer_timeout() -> void:
	remaining_time -= 1
	if remaining_time == 0:
		shift_ended()
		$shift_timer.stop()
		return
	$ui/time_panel/time.text = format_time(remaining_time)
	$ui/time_panel/seconds.rotation_degrees += 6.0
	$ui/time_panel/minutes.rotation_degrees += 0.1
	

func format_time(total_seconds: int) -> String:
	var mins = total_seconds / 60
	var sec = total_seconds % 60
	return "%02d:%02d" % [mins, sec]
