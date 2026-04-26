extends Panel

func update_tool(toolname: String) -> void:
	for t in get_node("tool_panel").get_children():
		if t.name == toolname:
			t.show()
			$weapon_name/weapon_name.text = toolname.capitalize()
		else:
			t.hide()
