extends Node

@onready var rooms = $Rooms
@onready var phases: Array = $Phases.get_children()

var first_game = true


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.setup()


func _start_first_phase():
	_play_click_audio()
	if first_game:
		$Menu/HowTo.show()
		$Menu/DimBG.show()
		first_game = false
	GameState.new_game_setup()
	$Rooms.show()
	$Title.hide()
	$HUD.start_new_game()
	_start_phase()


func _on_hud_advance_phase():
	GameState.current_phase += 1
	if GameState.current_phase >= phases.size():
		$HUD.game_end()
	else:
		_start_phase()


func _start_phase():
	var phase: Phase = phases[GameState.current_phase]
	GameState.start_phase(phase)
	rooms.enable_phase_portals(phase.phase_name)
	rooms.go_to(phase.default_room)


func _on_new_game() -> void:
	GameState.new_game_setup()
	$Rooms.show()
	$HUD.start_new_game()
	_start_phase()


func _on_to_title() -> void:
	$HUD.hide()
	$Rooms.hide()
	$Title.show()


func _on_menu_open_credits() -> void:
	$HUD.open_credits()


func _play_click_audio():
	$ClickSound.play()


func _on_menu_music_changed(value: float) -> void:
	$BackgroundMusic.volume_db = linear_to_db(value)


func _on_menu_sounds_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Sounds")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_menu_color_access(toggled_on: bool) -> void:
	for n in get_tree().get_nodes_in_group("clickables"):
		n.enable_accessible_colors(toggled_on)

	$HUD.make_color_accessible(toggled_on)
	$Menu.make_color_accessible(toggled_on)
