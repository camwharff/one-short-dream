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
