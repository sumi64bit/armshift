extends StaticBody2D

func init() -> void:
	constant_linear_velocity.x = 20.0 + (get_parent().shift * 5)
