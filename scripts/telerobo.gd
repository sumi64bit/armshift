extends RigidBody2D

enum State { CHASE, SHOOTING, IDLE, WANDER }
var current_state: State = State.CHASE

@export var speed: float = 100.0
@export var jump_force: float = 400.0 # Changed to positive force for impulse
@export var shooting_range: float = 150.0

var target: Node2D = null
var move_dir: int = 0
var state_timer: float = 0.0 # Timer for human-like behaviors

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var laser: Node2D = $LaserGun/TeleroboLaserRay
@onready var wall_ray_right: RayCast2D = $WallRayRight
@onready var wall_ray_left: RayCast2D = $WallRayLeft
@onready var ledge_ray_right: RayCast2D = $LedgeRayRight
@onready var ledge_ray_left: RayCast2D = $LedgeRayLeft
@onready var floor_ray: RayCast2D = $FloorRay # NEW: Needed for RigidBody jumping

func _physics_process(delta: float) -> void:
	if !is_instance_valid(target):
		select_new_target()
	else:
		update_state_machine(delta)

	# FIX: Only modify the X axis directly. 
	# Do not overwrite the entire linear_velocity vector!
	linear_velocity.x = move_dir * speed

	update_animations()

func jump() -> void:
	# FIX: While impulses work, directly setting the Y velocity 
	# feels much snappier and more consistent for AI platformers.
	linear_velocity.y = -jump_force # Negative Y goes UP in Godot

func select_new_target() -> void:
	var cargo_list = get_tree().get_nodes_in_group("cargo")
	if cargo_list.size() > 0:
		target = cargo_list.pick_random()
	else:
		target = null
		switch_state(State.IDLE, 1.0) # Just chill if there's nothing to destroy

func update_state_machine(delta: float) -> void:
	var distance = global_position.distance_to(target.global_position)
	# 1. High Priority: Shooting
	if distance <= shooting_range:
		switch_state(State.SHOOTING, 0.1)
		process_shooting()
		return
	elif current_state == State.SHOOTING:
		switch_state(State.IDLE, 0.5)
	# 2. Manage Timers for Human-like behavior
	state_timer -= delta
	if state_timer <= 0 and current_state != State.SHOOTING:
		decide_next_action()

	# 3. Process Movement States
	match current_state:
		State.CHASE:
			process_chase()
		State.WANDER:
			process_wander()
		State.IDLE:
			move_dir = 0
			laser.isFiring = false

func decide_next_action() -> void:
	# Randomly decide what to do next to simulate "thinking"
	var roll = randf()
	
	if roll < 0.60:
		# 60% chance to just chase the target
		switch_state(State.CHASE, randf_range(2.0, 4.0))
	elif roll < 0.80:
		# 20% chance to stop and "think"
		switch_state(State.IDLE, randf_range(0.5, 1.5))
	else:
		# 20% chance to pace back and forth randomly
		switch_state(State.WANDER, randf_range(1.0, 2.5))
		move_dir = [-1, 1].pick_random()

func switch_state(new_state: State, duration: float) -> void:
	current_state = new_state
	state_timer = duration

func process_chase() -> void:
	laser.isFiring = false
	move_dir = sign(target.global_position.x - global_position.x)
	
	if is_path_blocked(move_dir) and floor_ray.is_colliding():
		jump()

func process_wander() -> void:
	laser.isFiring = false
	# If pacing back and forth and we hit a wall/ledge, flip direction
	if is_path_blocked(move_dir):
		move_dir *= -1 

func process_shooting() -> void:
	move_dir = 0 # Stop walking
	laser.isFiring = true
	target.hit(UpgradeSystem.robot_damage)

# --- Physics Interactions ---

func is_path_blocked(dir: int) -> bool:
	if dir == 1: 
		return wall_ray_right.is_colliding() or not ledge_ray_right.is_colliding()
	elif dir == -1: 
		return wall_ray_left.is_colliding() or not ledge_ray_left.is_colliding()
	return false

# --- Animations ---

func update_animations() -> void:
	if current_state == State.SHOOTING or current_state == State.IDLE or move_dir == 0:
		anim_sprite.play("idle")
	else:
		anim_sprite.play("running")
		# Flip based on movement direction
		anim_sprite.flip_h = move_dir < 0
const EXPLOSION = preload("uid://c4ar7uqo63gfv")
var hp: float = 1.0
func hit(value: float) -> void:
	hp -= value
	if hp <= 0.0:
		var ex = EXPLOSION.instantiate()
		ex.position = global_position
		get_parent().get_parent().add_child(ex)
		queue_free()
