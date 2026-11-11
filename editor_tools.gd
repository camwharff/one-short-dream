@tool
extends EditorScript


func _run():
	load_task_data_to_editor()


func save_task_data():
	var file = FileAccess.open("res://data/tasks.json", FileAccess.WRITE)
	var data = []

	for task in GameState.tasks.values():
		var task_data: Dictionary = { }
		for prop in task.get_property_list():
			if (
				prop["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE
				and prop["usage"] & PROPERTY_USAGE_EDITOR
			):
				task_data.get_or_add(prop["name"], task.get(prop["name"]))
		data.append({ task.task_name: task_data })

	if file:
		file.store_string(JSON.stringify(data, "\t"))


func load_task_data_to_editor():
	if not FileAccess.file_exists("res://data/tasks.json"):
		push_error("JSON file not found: res://data/tasks.json")
		return
	var text = FileAccess.get_file_as_string("res://data/tasks.json")
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Invalid JSON in res://data/tasks.json")
		return

	for task in get_editor_interface().get_selection().get_selected_nodes():
		if task is Task:
			var task_data: Dictionary = data[task.task_name]
			var task_stats: Dictionary[String, int] = { }
			for stat in task_data["stats"]:
				task_stats.get_or_add(stat, int(task_data["stats"][stat]))
			task.stats = task_stats
			task.flags = task_data["flags"]
			task.icons = task_data["icons"]
			task.hover_message = task_data["hover_message"]
			task.prereqs = task_data["prereqs"]
			task.blocked_by = task_data["blocked_by"]
			task.phases = task_data["phases"]


func update_task_data():
	for task in get_editor_interface().get_selection().get_selected_nodes():
		var dupe_stats: Dictionary = task.stats.duplicate(true)
		var dupe_flags: Dictionary = task.flags.duplicate(true)
		var dupe_icons: Dictionary = task.icons.duplicate(true)
		dupe_stats["time"] = task.time_cost
		dupe_stats["tidiness"] = task.tidiness_change
		dupe_stats["energy"] = task.energy_change
		dupe_stats["satisfaction"] = task.satisfaction_change
		dupe_stats["performance"] = task.performance_change
		dupe_stats["carryover"] = task.carryover_change
		dupe_stats["begin"] = task.begin
		dupe_stats["end"] = task.end
		dupe_flags["early_exit"] = task.early_exit
		dupe_flags["repeatable"] = task.repeatable
		dupe_icons["up"] = task.up_icon
		dupe_icons["down"] = task.down_icon
		task.stats = dupe_stats
		task.flags = dupe_flags
		task.icons = dupe_icons
