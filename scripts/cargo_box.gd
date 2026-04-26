extends RigidBody2D

var damage: float = 1.0
var is_grabbed: bool = false
var is_healing: bool = false
const BOX_EXPLOSION = preload("uid://b5dmrnvt7lscn")
const DEDUCTION_LABEL = preload("uid://di0ad5bogebab")

@export var max_impact_force: float = 500.0 # Adjust based on your game scale
@export var max_speed: float = 800.0        # Max velocity before it explodes
@export var value: int = 300

# Set these in the Inspector to match your Sprite/CollisionShape size
@export var box_width: float = 128.0
@export var box_height: float = 64.0

@export var down_ray_length: float = 1000.0
@export var neighbor_ray_length: float = 20.0 # How far to scan for neighbors

func get_box_value() -> int:
	var base_value: int = value # Updated base value
	var space_state = get_world_2d().direct_space_state
	
	# Calculate half-extents to get the edges of the rectangle
	var half_w = box_width / 2.0
	var half_h = box_height / 2.0
	
	# ==========================================
	# 1. CHECK IF ON THE VAN
	# ==========================================
	var is_on_van: bool = false
	# Start the ray from the bottom-center of the rectangle
	var start_pos = to_global(Vector2(0, half_h)) 
	var down_end_pos = start_pos + (Vector2.DOWN * down_ray_length)
	
	var down_query = PhysicsRayQueryParameters2D.create(start_pos, down_end_pos)
	var excluded_objects = [self.get_rid()]
	
	while true:
		down_query.exclude = excluded_objects
		var result = space_state.intersect_ray(down_query)
		
		if result:
			var collider = result.collider
			if collider.is_in_group("van"):
				is_on_van = true
				break
			elif collider.is_in_group("box"):
				excluded_objects.append(collider.get_rid())
			else:
				break 
		else:
			break
			
	if not is_on_van:
		return base_value

	# ==========================================
	# 2. CALCULATE NEIGHBOR BONUS
	# ==========================================
	var final_value: int = base_value
	
	# Define detection points on the edges of the rectangle
	var check_directions = {
		"right": {"start": Vector2(half_w, 0), "dir": Vector2.RIGHT},
		"left":  {"start": Vector2(-half_w, 0), "dir": Vector2.LEFT},
		"up":    {"start": Vector2(0, -half_h), "dir": Vector2.UP},
		"down":  {"start": Vector2(0, half_h),  "dir": Vector2.DOWN}
	}
	
	for key in check_directions:
		var data = check_directions[key]
		var ray_start = to_global(data["start"])
		var ray_end = ray_start + (data["dir"] * neighbor_ray_length)
		
		var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
		query.exclude = [self.get_rid()]
		
		var result = space_state.intersect_ray(query)
		
		if result and result.collider.is_in_group("box"):
			final_value += 50
			
	return final_value

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# 1. CHECK FOR "SQUEEZE" (Crushing force)
	# Check all contacts for this frame
	for i in range(state.get_contact_count()):
		# Get the impulse (the 'force') of the collision
		var impulse = state.get_contact_impulse(i)
		
		# If the force of impact is higher than our threshold, BOOM
		if impulse.length() > UpgradeSystem.box_impact_force:
			explode()
			return # Exit function to avoid multiple explosions

	# 2. CHECK FOR "THROWN HARD" (Velocity check)
	# We check the velocity magnitude of the body
	if linear_velocity.length() > UpgradeSystem.box_moving_speed:
		explode()

func hit(v: float) -> void:
	is_healing = false
	$RestTimer.start()
	damage -= v
	if damage <= 0.0:
		explode()

func explode() -> void:
	get_parent().get_parent().damages -= 30
	var dd = DEDUCTION_LABEL.instantiate()
	dd.position = position
	dd.init(-30)
	get_parent().get_parent().add_child(dd)
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

func _on_rest_timer_timeout() -> void:
	is_healing = true
