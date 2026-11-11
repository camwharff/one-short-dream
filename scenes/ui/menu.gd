extends CanvasLayer

signal new_game
signal to_title
signal click_sound
signal music_changed(value: float)
signal sounds_changed(value: float)
signal color_access(toggled_on: bool)


func _on_menu_pressed() -> void:
	click_sound.emit()
	if $MenuControl/MenuList.visible:
		$MenuControl/MenuList.hide()
	else:
		$MenuControl/MenuList.show()


func _on_exit_pressed() -> void:
	click_sound.emit()
	get_tree().quit()


func _on_restart_pressed() -> void:
	click_sound.emit()
	new_game.emit()


func _on_title_pressed() -> void:
	click_sound.emit()
	to_title.emit()


func _on_credits_pressed() -> void:
	click_sound.emit()
	if $Credits.visible:
		_show_menu_window($Credits, false)
	else:
		_show_menu_window($Credits, true)


func _on_history_pressed() -> void:
	click_sound.emit()
	$RunHistory.show_runs()
	if $RunHistory.visible:
		_show_menu_window($RunHistory, false)
	else:
		$RunHistory.show_runs()
		_show_menu_window($RunHistory, true)


func _input(event: InputEvent) -> void:
	if not $MenuControl/MenuList.visible:
		return
	if event is InputEventMouseButton and event.pressed:
		if not $MenuControl.get_global_rect().has_point(
			$MenuControl.get_global_mouse_position()
		):
			$MenuControl/MenuList.hide()


func _on_clear_history_pressed() -> void:
	click_sound.emit()
	RunManager.clear_runs()
	$RunHistory.show_runs()


func _on_how_to_pressed() -> void:
	click_sound.emit()
	if $HowTo.visible:
		_show_menu_window($HowTo, false)
	else:
		_show_menu_window($HowTo, true)


func _on_settings_pressed() -> void:
	click_sound.emit()
	if $Settings.visible:
		_show_menu_window($Settings, false)
	else:
		_show_menu_window($Settings, true)


func _show_menu_window(window: Control, enable: bool):
	$HowTo.hide()
	$Credits.hide()
	$RunHistory.hide()
	$Settings.hide()
	if enable:
		window.show()
		$DimBG.show()
	else:
		$DimBG.hide()


func _on_music_volume_value_changed(value: float) -> void:
	music_changed.emit(value)


func _on_sounds_volume_value_changed(value: float) -> void:
	sounds_changed.emit(value)


func _on_color_accessibility_toggled(toggled_on: bool) -> void:
	color_access.emit(toggled_on)


func make_color_accessible(enable: bool):
	var all_buttons: Array[Button] = []
	get_all_buttons(self, all_buttons)
	var t
	if enable:
		t = load("res://resources/menu_button_accessible.tres")
	else:
		t = load("res://resources/menu_button.tres")
	for button in all_buttons:
		button.theme = t


func get_all_buttons(root: Node, button_list: Array[Button]):
	if root is Button:
		button_list.append(root)

	for child in root.get_children():
		get_all_buttons(child, button_list)
