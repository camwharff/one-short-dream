extends MarginContainer

@onready var grid: GridContainer = $RunHistorySorting/RunHistoryBG/VBoxContainer/HistScroll/HistGrid

const HEADERS = [
	"Completion Time",
	"Energy",
	"Performance",
	"Satisfaction",
	"Tidiness",
	"Total",
]


func show_runs():
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

	grid.columns = HEADERS.size()

	for header in HEADERS:
		_add_cell(header, true)

	RunManager.runs.sort_custom(
		func(a, b):
			return a["total"] > b["total"],
	)

	for run in RunManager.runs:
		_add_cell(_format_time(int(run["timestamp"])))
		_add_cell(str(int(run["energy"])))
		_add_cell(str(int(run["performance"])))
		_add_cell(str(int(run["satisfaction"])))
		_add_cell(str(int(run["tidiness"])))
		_add_cell(str(int(run["total"])))


func _add_cell(text: String, header: bool = false) -> void:
	var label: Label = Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.BLACK)
	label.add_theme_font_size_override("font_size", 20)
	if header:
		label.uppercase = true
	grid.add_child(label)


func _format_time(unix: int) -> String:
	var bias_seconds = Time.get_time_zone_from_system().bias * 60
	var date = Time.get_datetime_dict_from_unix_time(unix + bias_seconds)
	return "%04d-%02d-%02d %02d:%02d" % [
		date.year,
		date.month,
		date.day,
		date.hour,
		date.minute,
	]
