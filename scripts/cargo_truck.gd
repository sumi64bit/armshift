extends RigidBody2D

var torque: float = 0.0
var active: bool = false
var takeoff: bool = false
var returning: bool = false
@onready var truck_engine_audio: AudioStreamPlayer2D = $truck_engine_audio
@onready var delivery_panel: Control = $"../ui/delivery_panel"

const TRUCK_ENGINE = preload("uid://3oajtoe6ceqr")
const TRUCK_ENGINE_STOP = preload("uid://cxdidfxtl5lk")
const TRUCK_ENGINE_LOOP = preload("uid://cu5uqpjft3p35")

@onready var world: Node2D = $".."

func _process(delta: float) -> void:
	$PinJoint2D/wheel3.angular_velocity = torque
	$PinJoint2D2/wheel3.angular_velocity = torque
	if returning:
		torque = -UpgradeSystem.truck_torque
		if position.x <= 1000:
			returning = false
			torque = 0.0
			active = false
			takeoff = false
			truck_engine_audio.stream = TRUCK_ENGINE_STOP
			truck_engine_audio.play()
			$"../factory_gate/AnimationPlayer".play_backwards("open")
			await $"../factory_gate/AnimationPlayer".animation_finished
			$"../leave_button".active = true
			$"../leave_button/active".show()
	else:
		if active && torque < UpgradeSystem.truck_torque && takeoff:
			torque += delta * (UpgradeSystem.truck_torque/10)
			if truck_engine_audio.pitch_scale < 1.4:
				truck_engine_audio.pitch_scale += 0.1 * delta
		if position.x >= 3000:
			returning = true
			clear_delivered_boxes()

func clear_delivered_boxes() -> void:
	var count: int = 0
	var total_value: int = 0
	for b in $"../spawns".get_children():
		if b.is_in_group("cargo"):
			if b.position.x >= 2000:
				total_value += b.get_box_value()
				b.call_deferred("queue_free")
				count += 1
		if b.is_in_group("enemy"):
			if b.position.x >= 2000:
				total_value += 400
				b.call_deferred("queue_free")
				count += 1
	world.points += total_value
	world.deliveries += count
	world.refresh_status()
	delivery_panel.popup(count, total_value)

func leave() -> void:
	truck_engine_audio.stream = TRUCK_ENGINE
	active = true
	$movingTimer.start()
	$truck_engine_audio.play()

func _on_moving_timer_timeout() -> void:
	takeoff = true

func _on_truck_engine_audio_finished() -> void:
	if truck_engine_audio.stream == TRUCK_ENGINE:
		truck_engine_audio.play(3.88)
