extends Node

signal stats_changed
signal setup_complete
signal phase_end
signal game_end

const LAST_PHASE = 2

var time_left: int = 0
var time_max: int = 0
var tidiness: int = 0
var energy: int = 0
var satisfaction: int = 0
var performance: int = 0
var carryover: int = 0
var current_phase = 0
var extra_time = 0

var completed: Dictionary = { }
var tasks: Dictionary = { }
var dependencies: Dictionary = { }
var npcs: Dictionary = { }


func _ready():
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true


func setup():
	_init_task_lists()
	_init_phase_groups()
	_build_dependencies()
	_init_task_availabilities()
	DataManager.save_task_data()
	setup_complete.emit()


func new_game_setup():
	for task in tasks.values():
		completed[task.task_name] = false
	_reset_stats()
	_init_task_availabilities()


func _reset_stats():
	time_left = 0
	time_max = 0
	tidiness = 0
	energy = 0
	satisfaction = 0
	performance = 0
	carryover = 0
	current_phase = 0


func _init_npc_lists():
	for npc in get_tree().get_nodes_in_group("npc"):
		completed[npc.npc_name] = false
		npcs[npc.npc_name] = npc


func _init_task_lists():
	for task in get_tree().get_nodes_in_group("tasks"):
		completed[task.task_name] = false
		tasks[task.task_name] = task


func _init_phase_groups():
	for task in tasks.values():
		for phase in task.phases:
			task.add_to_group(phase)


func _build_dependencies():
	for task in tasks.values():
		for other_task in task.prereqs + task.blocked_by:
			dependencies.get_or_add(other_task, []).append(task.task_name)


func _init_task_availabilities():
	for task in tasks.values():
		_update_availability(task)


func start_phase(phase: Phase):
	time_left = phase.time_limit + carryover + extra_time
	time_max = time_left
	carryover = 0
	extra_time = 0
	stats_changed.emit()
	_enable_phase_tasks(phase.phase_name)


func _enable_phase_tasks(phase: String):
	for task in tasks.values():
		task.in_phase = task.phases.has(phase)
		if task.in_phase and task.flags["repeatable"]:
			completed[task.task_name] = false
			task.complete = false
			task.sprite.visible = true
		_update_availability(task)


func apply_task(current_task: Task) -> void:
	time_left = clampi(time_left - current_task.stats["time"], 0, 100)
	tidiness += current_task.stats["tidiness"]
	energy += current_task.stats["energy"]
	satisfaction += current_task.stats["satisfaction"]
	performance += current_task.stats["performance"]
	carryover += current_task.stats["carryover"]
	stats_changed.emit()

	completed[current_task.task_name] = true

	if dependencies.has(current_task.task_name):
		for task in dependencies[current_task.task_name]:
			_update_availability(tasks[task])

	# TODO: Fix this to only update availability for time sensitive tasks, saves unnecessary checking
	for task in tasks.values():
		_update_availability(task)

	if current_task.flags["early_exit"]:
		extra_time = time_left
		time_left = 0

	if time_left <= 0:
		time_out()

	current_task.complete = true
	current_task.complete_task()


func _update_availability(task: Task):
	task.enable = _availability_handler(task)
	if task.enable:
		task.show()
		task.input_pickable = true
	else:
		task.hide()
		task.input_pickable = false


func _availability_handler(task: Task) -> bool:
	if not task.in_phase:
		return false
	if completed[task.task_name]:
		return false

	if task.stats["begin"] > time_max - time_left || task.stats["end"] < time_max - time_left:
		return false

	for req in task.prereqs:
		if !completed[req]:
			return false
	for blocker in task.blocked_by:
		if completed[blocker]:
			return false

	return true


func time_out():
	if current_phase >= LAST_PHASE:
		var stats = normalize_stats()
		game_end.emit()

		var high_three = stats.duplicate()
		high_three.erase(high_three.min())

		RunManager.add_run(
			{
				"timestamp": Time.get_unix_time_from_system(),
				"energy": stats[0],
				"performance": stats[1],
				"satisfaction": stats[2],
				"tidiness": stats[3],
				"total": high_three.reduce(
					func(accum, num):
						return accum + num,
					0,
				)
				/ 3,
			}
		)
	else:
		phase_end.emit()


func normalize_stats() -> Array[int]:
	return [
		clampi(100 * ((energy + 7) / 25.0), 0, 100),
		clampi(100 * ((performance - 8) / 22.0), 0, 100),
		clampi(100 * ((satisfaction - 9) / 17.0), 0, 100),
		clampi(100 * ((tidiness + 4) / 16.0), 0, 100),
	]
