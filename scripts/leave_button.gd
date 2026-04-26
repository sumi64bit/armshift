extends Node2D

var clickable: bool = false
var active: bool = true
@export var truck: RigidBody2D

func _input(event: InputEvent) -> void:
	if not (active && clickable):
		return
	if event is InputEventMouseButton:
		if event.button_index == 1:
			trigger()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player"):
		if active:
			clickable = true
			$outline.show()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if not area.is_in_group("player"):
		clickable = false
		$outline.hide()

func trigger() -> void:
	truck.leave()
	$active.hide()
	active = false
	$outline.hide()
	$"../factory_gate/AnimationPlayer".play("open")
