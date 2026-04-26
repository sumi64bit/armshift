extends Node2D
const HAXIS_RANGE: Vector2 = Vector2(-1200, 170)
const VAXIS_RANGE: Vector2 = Vector2(-1000, -350)

@onready var vaxis: Node2D = $vaxis/haxis
@onready var haxis: Node2D = $vaxis/haxis/arm_mountpoint
@onready var arm_mountpoint: Node2D = $vaxis/haxis/arm_mountpoint
@onready var haxis_motor_audio: AudioStreamPlayer2D = $haxis_motor_audio
@onready var vaxis_motor_audio: AudioStreamPlayer2D = $vaxis_motor_audio

var haxis_value: float
var vaxis_value: float

var movement_speed: float = 300.0

func _ready() -> void:
	haxis_value = HAXIS_RANGE.y
	vaxis_value = VAXIS_RANGE.y

func _process(delta: float) -> void:
	var vinput = Input.get_axis("up", "down")
	var hinput = Input.get_axis("left", "right")
	haxis.position.x = lerp(haxis.position.x, haxis_value, 0.1)
	vaxis.position.y = lerp(vaxis.position.y, vaxis_value, 0.1)
	haxis_value += hinput * delta * movement_speed
	vaxis_value += vinput * delta * movement_speed
	haxis_value = clamp(haxis_value, HAXIS_RANGE.x, HAXIS_RANGE.y)
	vaxis_value = clamp(vaxis_value, VAXIS_RANGE.x, VAXIS_RANGE.y)
	$vaxis/haxis/arm_mountpoint/flat_wire.size.x = arm_mountpoint.position.x/2 * -1 + 135
	if hinput != 0.0:
		haxis_motor_audio.volume_db = lerp(haxis_motor_audio.volume_db, -4.0, 0.2)
	else:
		haxis_motor_audio.volume_db = lerp(haxis_motor_audio.volume_db, -40.0, 0.2)
	if vinput != 0.0:
		vaxis_motor_audio.volume_db = lerp(vaxis_motor_audio.volume_db, -4.0 * vinput, 0.2)
	else:
		vaxis_motor_audio.volume_db = lerp(vaxis_motor_audio.volume_db, -40.0, 0.2)
		
