extends RigidBody2D

var damage: float = 1.0
var is_grabbed: bool = false
var is_trap: bool = false
var is_healing: bool = false
const BOX_EXPLOSION = preload("uid://b5dmrnvt7lscn")
const DEDUCTION_LABEL = preload("uid://di0ad5bogebab")

var spawn_count: int = 5
const TELEROBO = preload("uid://bqrna5lkggvq4")
var explosion_triggered: bool = false
var shaking_value: float = 0.0
var value: int = 100

@export var down_ray_length: float = 1000.0 
@export var neighbor_ray_length: float = 50.0

func _ready() -> void:
	var r = [0, 1, 2, 3, 4, 5].pick_random()
	if r == 4:
		is_trap = true
		$triggerTrapTimer.start(randf_range(20.0, 40.0))

func hit(v: float) -> void:
	is_healing = false
	$RestTimer.start()
	damage -= v
	if damage <= 0.0:
		get_parent().get_parent().damages -= 30
		var dd = DEDUCTION_LABEL.instantiate()
		dd.position = position
		dd.init(-30)
		get_parent().get_parent().add_child(dd)
		get_parent().get_parent().damages -= 10
		var be = BOX_EXPLOSION.instantiate()
		be.position = position
		get_parent().get_parent().add_child(be)
		queue_free()

func _process(delta: float) -> void:
	$texture.modulate.g = damage
	$texture.modulate.b = damage
	if damage < 1.0 && is_healing:
		damage += delta
	if is_grabbed:
		mass = 0.01
		gravity_scale = 0.1
	else:
		mass = 1.0
		gravity_scale = 1.0
	if explosion_triggered:
		shaking_value = lerp(shaking_value, 0.07, 0.05)
		$texture.scale += Vector2(0.07, 0.07)*delta
		$texture.rotation = randf_range(-shaking_value, shaking_value)
		$texture/exploding.modulate.a = lerp($texture/exploding.modulate.a, 1.0, 0.03)
		if $explosionTimer.is_stopped():
			$explosionTimer.start()

func explode() -> void:
	var r = TELEROBO.instantiate()
	r.position = position
	get_parent().call_deferred("add_child", r)
	var be = BOX_EXPLOSION.instantiate()
	be.position = position
	get_parent().get_parent().add_child(be)
	queue_free()

func get_box_value() -> int:
	var base_value: int = value
	var space_state = get_world_2d().direct_space_state
	
	# ==========================================
	# 1. CHECK IF ON THE VAN
	# ==========================================
	var is_on_van: bool = false
	var down_end_pos = global_position + (Vector2.DOWN * down_ray_length)
	var down_query = PhysicsRayQueryParameters2D.create(global_position, down_end_pos)
	
	# We use an array to store objects we want the raycast to ignore.
	# We start by ignoring the box itself so it doesn't just hit its own center.
	var excluded_objects = [self.get_rid()]
	
	# This loop allows the raycast to "pierce" through other boxes.
	while true:
		down_query.exclude = excluded_objects
		var result = space_state.intersect_ray(down_query)
		
		if result:
			var collider = result.collider
			if collider.is_in_group("van"):
				is_on_van = true
				break # We found the van! Stop casting.
			elif collider.is_in_group("box"):
				# We hit another box. Add its RID to the exclude list and cast again.
				excluded_objects.append(collider.get_rid())
			else:
				# We hit the ground, a wall, or something else.
				break 
		else:
			# We hit absolutely nothing.
			break
			
	# If we aren't above the van, bail out early and return 10.
	if not is_on_van:
		return base_value

	# ==========================================
	# 2. CALCULATE NEIGHBOR BONUS
	# ==========================================
	var final_value: int = base_value
	
	# Raycast on "all angles". I'm using the 4 cardinal directions here. 
	# Add Vector2(1, 1), Vector2(-1, -1), etc., if you want to check diagonals too!
	var check_directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	
	for dir in check_directions:
		var neighbor_end_pos = global_position + (dir * neighbor_ray_length)
		var neighbor_query = PhysicsRayQueryParameters2D.create(global_position, neighbor_end_pos)
		neighbor_query.exclude = [self.get_rid()] # Ignore ourselves
		
		var neighbor_result = space_state.intersect_ray(neighbor_query)
		
		# If the raycast hits something, and that something is in the "box" group
		if neighbor_result and neighbor_result.collider.is_in_group("cargo"):
			final_value += 10
			
	return final_value

func _on_timer_timeout() -> void:
	explode()

func _on_trigger_trap_timer_timeout() -> void:
	explosion_triggered = true

func _on_rest_timer_timeout() -> void:
	is_healing = true
