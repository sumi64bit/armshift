extends Node2D
@onready var ik_target: Node2D = $ik_target
@onready var camera: Camera2D = $camera
@onready var laser_ray: PixelLaser = $body/laser_arm/laser_gun/laser_ray
@onready var laser_audio: AudioStreamPlayer2D = $laser_audio
@onready var status_panel: Panel = $"../../../../../ui/status_panel"

var box_in_range: Node2D

var available_weapons: Array = ["GRABBLER", "LAZER"]
var active_weapon: int = 1

const MECHANICAL_GRABBLER_CLOSED = preload("uid://cspey1svpn14c")
const MECHANICAL_GRABBLER_OPEN = preload("uid://cm6ci0w2eu1u2")

func _ready() -> void:
	refresh_weapons()

func _process(delta: float) -> void:
	ik_target.global_position = get_global_mouse_position()
	ik_target.position = ik_target.position.clamp(Vector2(-1000, 120), Vector2(1000, 500))
	if Input.is_action_just_pressed("next_weapon"):
		active_weapon += 1
		if active_weapon > available_weapons.size()-1:
			active_weapon = 0
		refresh_weapons()
	if Input.is_action_just_pressed("previous_weapon"):
		active_weapon -= 1
		if active_weapon < 0:
			active_weapon = available_weapons.size()-1
		refresh_weapons()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		process_active_weapon(true)
	else:
		process_active_weapon(false)

func refresh_weapons() -> void:
	match(available_weapons[active_weapon-1]):
		"LAZER":
			$body/laser_arm.show()
			$body/grabbler_arm.hide()
		"GRABBLER":
			$body/laser_arm.hide()
			$body/grabbler_arm.show()
	status_panel.update_tool(available_weapons[active_weapon-1])

func process_active_weapon(value: bool) -> void:
	match(available_weapons[active_weapon-1]):
		"LAZER":
			if value:
				process_shooting()
			else:
				if laser_audio.playing:
					$laser_audio.stop()
				$body/laser_arm/glow2.scale = lerp($body/laser_arm/glow2.scale, Vector2.ZERO, 0.5)
				laser_ray.line.width = lerp(laser_ray.line.width, 0.0, 0.3)
				if laser_ray.line.width == 0.0:
					laser_ray.is_firing = false
		"GRABBLER":
			if value:
				if box_in_range != null:
					$body/grabbler_arm/TextureRect.texture = MECHANICAL_GRABBLER_CLOSED
					$body/hand/PinJoint2D.node_b = box_in_range.get_path()
					$body/grabbler_arm/TextureRect.look_at(box_in_range.global_position)
				else:
					$body/hand/PinJoint2D.node_b = ""
					$body/grabbler_arm/TextureRect.texture = MECHANICAL_GRABBLER_OPEN
					$body/grabbler_arm/TextureRect.rotation = 0.0
			else:
				$body/hand/PinJoint2D.node_b = ""
				$body/grabbler_arm/TextureRect.texture = MECHANICAL_GRABBLER_OPEN
				$body/grabbler_arm/TextureRect.rotation = 0.0

func process_shooting() -> void:
	if not laser_audio.playing:
		$laser_audio.play()
	laser_ray.is_firing = true
	laser_ray.line.width = randf_range(10.0, 20.0)
	$body/laser_arm/glow2.scale = Vector2(3.6, 3.6)
	$body/laser_arm/glow2.global_position = laser_ray.get_collision_point()
	if not is_instance_valid(laser_ray.get_collider()):
		return
	if laser_ray.get_collider().is_in_group("enemy"):
		laser_ray.get_collider().hit(0.1)
	elif laser_ray.get_collider().is_in_group("cargo"):
		laser_ray.get_collider().hit(0.05)

func _on_grabbing_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("grabbables") && box_in_range == null:
		box_in_range = body

func _on_grabbing_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("grabbables"):
		if box_in_range == body:
			box_in_range = null
