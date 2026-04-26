class_name PixelLaser
extends RayCast2D

@export_category("Laser Visuals")
## The color of the laser beam.
@export var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0) # Default Red
## How thick the laser is in pixels.
@export var laser_width: float = 2.0
## The "chunkiness" of the laser. 1 is perfectly smooth, higher numbers make it look low-res and jagged.
@export var resolution: int = 2 

@export_category("Laser Physics")
## Maximum distance the laser can travel if it doesn't hit anything.
@export var max_length: float = 500.0
## Is the laser currently firing?
@export var is_firing: bool = false:
	set(value):
		is_firing = value
		set_physics_process(is_firing)
		if line:
			line.visible = is_firing

var line: Line2D

func _ready() -> void:
	# Set up the Line2D dynamically so you don't have to build it in the editor
	line = Line2D.new()
	add_child(line)
	
	# Configure the line for pixel art
	line.width = laser_width
	line.default_color = laser_color
	line.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	line.joint_mode = Line2D.LINE_JOINT_BEVEL
	line.visible = is_firing
	
	# Set raycast initial properties
	enabled = true
	set_physics_process(is_firing)

func _physics_process(_delta: float) -> void:
	# Cast the ray straight out on the local X axis (Godot's default "forward" in 2D)
	target_position = Vector2.RIGHT * max_length
	force_raycast_update()
	
	var cast_point = target_position
	
	# If we hit something, stop the laser at the collision point
	if is_colliding():
		# get_collision_point() is global, so we convert it to local coordinates for the Line2D
		cast_point = to_local(get_collision_point())
		
		# Optional: You can trigger logic on the hit target here!
		# var target = get_collider()
		# if target.has_method("take_damage"):
		#     target.take_damage(10)
			
	draw_pixelated_laser(Vector2.ZERO, cast_point)

func draw_pixelated_laser(start_pos: Vector2, end_pos: Vector2) -> void:
	line.clear_points()
	
	# If resolution is 1, just draw a straight line (native pixel art look)
	if resolution <= 1:
		line.add_point(start_pos)
		line.add_point(end_pos)
		return
		
	# For variable resolution, we step along the line and snap to a grid
	var distance = start_pos.distance_to(end_pos)
	var direction = start_pos.direction_to(end_pos)
	
	var steps = int(distance / resolution)
	
	for i in range(steps + 1):
		var point = start_pos + direction * (i * resolution)
		# Snap the point to create the chunky, jagged pixel effect
		var snapped_point = point.snapped(Vector2(resolution, resolution))+Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
		line.add_point(snapped_point)
	
	# Ensure the laser always ends exactly where the raycast hit
	line.add_point(end_pos.snapped(Vector2(resolution, resolution)))
