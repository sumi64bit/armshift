extends Node

# ==========================================
# EASY ACCESS VARIABLES
# ==========================================
signal inf_upgrade(id: String)

var robot_damage: float = 0.01
var box_impact_force: float = 1000.0
var box_moving_speed: float = 1000.0
var truck_torque: float = 5.0

# ==========================================
# SYSTEM VARIABLES
# ==========================================
const MAX_UPGRADE_LEVEL: int = 12
var upgrades: Dictionary = {}

func _ready() -> void:
	randomize() 
	
	# 1. Register Infinite Cards
	upgrades["points_card"] = {"type": "infinite", "weight": 45.0}
	upgrades["time_card"] = {"type": "infinite", "weight": 45.0}
	
	# 2. Register Stat Upgrades
	# FORMAT: _register_stat_upgrade(Upgrade_ID, [Array_of_Variables_to_Update], start_value, target_value)
	
	_register_stat_upgrade("robot_damage_reduction", ["robot_damage"], 0.01, 0.001)
	
	# HERE IS THE MAGIC: One upgrade ID targets BOTH variables
	_register_stat_upgrade("box_reinforcement", ["box_impact_force", "box_moving_speed"], 1000.0, 7000.0)
	
	_register_stat_upgrade("truck_engine", ["truck_torque"], 5.0, 10.0)

# ==========================================
# MODULAR REGISTRATION
# ==========================================
func _register_stat_upgrade(id: String, target_vars: Array, start_val: float, end_val: float) -> void:
	upgrades[id] = {
		"type": "stat",
		"level": 0,
		"target_vars": target_vars, # Stores which variables this card upgrades
		"start_val": start_val,
		"end_val": end_val
	}

# ==========================================
# UPGRADE LOGIC
# ==========================================
func apply_upgrade(id: String) -> void:
	if not upgrades.has(id):
		push_warning("Upgrade ID does not exist: ", id)
		return
		
	var upg = upgrades[id]
	
	if upg["type"] == "infinite":
		print("Applied infinite upgrade: ", id)
		emit_signal("inf_upgrade", id)
		return
		
	if upg["type"] == "stat":
		if upg["level"] < MAX_UPGRADE_LEVEL:
			upg["level"] += 1
			_recalculate_stat(id)
			print("Upgraded ", id, " to level ", upg["level"])

func _recalculate_stat(id: String) -> void:
	var upg = upgrades[id]
	var progress = float(upg["level"]) / float(MAX_UPGRADE_LEVEL)
	var new_value = lerp(upg["start_val"], upg["end_val"], progress)
	
	# Loop through all variables linked to this upgrade and update them
	for var_name in upg["target_vars"]:
		set(var_name, new_value)
		print("  -> Updated ", var_name, " to: ", new_value)

# ==========================================
# CARD SELECTION LOGIC
# ==========================================
func get_two_upgrade_cards() -> Array:
	var card1 = _get_random_card([])
	var card2 = _get_random_card([card1]) 
	
	return [card1, card2]

func _get_random_card(exclude_list: Array) -> String:
	var pool = {}
	var total_weight: float = 0.0
	
	if not exclude_list.has("points_card"):
		pool["points_card"] = upgrades["points_card"]["weight"]
		total_weight += pool["points_card"]
		
	if not exclude_list.has("time_card"):
		pool["time_card"] = upgrades["time_card"]["weight"]
		total_weight += pool["time_card"]
	
	var available_stats = []
	for id in upgrades.keys():
		var upg = upgrades[id]
		if upg["type"] == "stat" and not exclude_list.has(id):
			if upg["level"] < MAX_UPGRADE_LEVEL:
				available_stats.append(id)
	
	if available_stats.size() > 0:
		var weight_per_stat = 10.0 / float(available_stats.size())
		for stat_id in available_stats:
			pool[stat_id] = weight_per_stat
			total_weight += weight_per_stat
			
	var random_roll = randf() * total_weight
	var cumulative_weight = 0.0
	
	for id in pool.keys():
		cumulative_weight += pool[id]
		if random_roll <= cumulative_weight:
			return id
			
	return ""
