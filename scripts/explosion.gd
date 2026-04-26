extends Node2D

func _ready() -> void:
	$audio.pitch_scale = randf_range(0.8, 1.2)
	for p in get_children():
		if p is CPUParticles2D:
			p.emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()
