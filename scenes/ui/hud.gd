extends CanvasLayer

signal advance_phase
signal game_ready
signal new_game
signal go_to_title
signal click_sound

@onready var time_text = $Display/TimeBG/Time/Data

@onready var hover_box: Control = $Display/HoverBox

@onready var hover_text: Label = $Display/HoverBox/HoverCols/HoverText
@onready var final_score: Label = $EndScreen/StatsBG/Stats/TotalScore/Score
@onready var final_energy: Label = $EndScreen/StatsBG/Stats/FinalStats/Energy/Score
@onready var final_sat: Label = $EndScreen/StatsBG/Stats/FinalStats/Satisfaction/Score
@onready var final_perf: Label = $EndScreen/StatsBG/Stats/FinalStats/Performance/Score
@onready var final_tidy: Label = $EndScreen/StatsBG/Stats/FinalStats/Tidiness/Score
@onready var final_description: Label = $EndScreen/StatsBG/Stats/Description

@onready var up_icon: TextureRect = $Display/HoverBox/HoverCols/UpIcon/Icon
@onready var down_icon: TextureRect = $Display/HoverBox/HoverCols/DownIcon/Icon

@onready var up_enable: Control = $Display/HoverBox/HoverCols/UpIcon
@onready var down_enable: Control = $Display/HoverBox/HoverCols/DownIcon

var hovered: Node2D
var hover_mutex: Mutex


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.stats_changed.connect(_update_hud)
	GameState.phase_end.connect(_on_phase_end)
	GameState.game_end.connect(_on_game_end)
	GameState.setup_complete.connect(_hud_setup)

	hover_mutex = Mutex.new()


var icons: Dictionary = {
	"time": load("res://assets/icons/clock.png"),
	"performance": load("res://assets/icons/graph.png"),
	"energy": load("res://assets/icons/sleep.png"),
	"satisfaction": load("res://assets/icons/smile.png"),
	"tidiness": load("res://assets/icons/trash.png"),
}


func _hud_setup():
	for task in GameState.tasks.values():
		task.hover.connect(_hover_handler)
	for portal in get_tree().get_nodes_in_group("portals"):
		portal.hover.connect(_hover_handler)
	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.hover.connect(_hover_handler)
	_update_hud()
	_show_component($Display)
	$DimBG.hide()
	game_ready.emit()


func _on_phase_end() -> void:
	var normed_stats = GameState.normalize_stats()

	var high_three = normed_stats.duplicate()
	high_three.erase(high_three.min())

	$PhaseFlash/Content/Stats/ExtraTime/ExtraTime.text = str(
		GameState.extra_time
	) + " (+ " + str(GameState.carryover) + ")"
	$PhaseFlash/Content/Stats/Score/Score.text = str(
		high_three.reduce(
			func(accum, num):
				return accum + num,
			0,
		)
		/ 3
	) + "/100"
	_show_component($PhaseFlash)
	$DimBG.show()


func _update_hud() -> void:
	time_text.text = str(GameState.time_left)


func _hover_handler(
	message: String,
	enable: bool,
	up: String,
	down: String,
	subject: Node2D,
):
	hover_mutex.lock()
	if enable:
		hover_text.text = message
		if subject is Portal:
			up_enable.hide()
			down_enable.hide()
		else:
			up_enable.show()
			down_enable.show()
			up_icon.texture = icons[up]
			down_icon.texture = icons[down]
		hover_box.show()
		hovered = subject
	elif hovered == subject:
		hover_box.hide()
	hover_mutex.unlock()


func _on_advance_button_pressed() -> void:
	click_sound.emit()
	advance_phase.emit()
	_show_component($Display)
	$DimBG.hide()


func _on_game_end():
	var normed_stats = GameState.normalize_stats()

	var high_three = normed_stats.duplicate()
	high_three.erase(high_three.min())

	final_score.text = str(
		high_three.reduce(
			func(accum, num):
				return accum + num,
			0,
		)
		/ 3
	) + "/100"
	final_energy.text = str(normed_stats[0]) + "/100"
	final_perf.text = str(normed_stats[1]) + "/100"
	final_sat.text = str(normed_stats[2]) + "/100"
	final_tidy.text = str(normed_stats[3]) + "/100"
	final_description.text = Endings.generate_description()
	_show_component($EndScreen)
	$DimBG.show()


func _on_quit_pressed() -> void:
	click_sound.emit()
	_show_component($Display)
	$DimBG.hide()
	hide()
	go_to_title.emit()


func _on_restart_pressed() -> void:
	click_sound.emit()
	new_game.emit()
	_show_component($Display)
	$DimBG.hide()


func start_new_game():
	_update_hud()
	_show_component($Display)
	$DimBG.hide()
	show()


func _show_component(node):
	for child in get_children():
		child.hide()
	node.show()


func make_color_accessible(enable: bool):
	var all_buttons: Array[Button] = []
	get_all_buttons(self, all_buttons)
	var t
	if enable:
		t = load("res://resources/style_theme_accessible.tres")
	else:
		t = load("res://resources/style_theme.tres")
	for button in all_buttons:
		button.theme = t


func get_all_buttons(root: Node, button_list: Array[Button]):
	if root is Button:
		button_list.append(root)

	for child in root.get_children():
		get_all_buttons(child, button_list)
