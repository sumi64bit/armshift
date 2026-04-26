extends Node

@onready var tracks: Array = [
	preload("uid://dxtf2rrhxr0tk"),
	preload("uid://c46eb3qi61ynd")
]
var audio_streamer: AudioStreamPlayer
var current_track: int = 0
var volume:= 0.0

func _ready() -> void:
	audio_streamer = AudioStreamPlayer.new()
	add_child(audio_streamer)
	audio_streamer.stream = tracks.pick_random()
	audio_streamer.play()
	audio_streamer.finished.connect(track_finished)

func _process(delta: float) -> void:
	if audio_streamer.volume_db != volume:
		audio_streamer.volume_db = lerp(audio_streamer.volume_db, volume, 0.1)

func lower_volume() -> void:
	volume = -10.0

func increase_volume() -> void:
	volume = 0.0

func next_track() -> void:
	if current_track < tracks.size():
		current_track += 1
	else:
		current_track = 0
	audio_streamer.stream = tracks[current_track]
	audio_streamer.play()

func track_finished() -> void:
	next_track()
