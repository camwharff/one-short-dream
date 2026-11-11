extends Node2D

signal new_game

@onready var sprite: Sprite2D = $StartButton/Sprite2D

var color_accessible


func _ready() -> void:
	$StartButton.add_to_group("clickables")
	$StartButton.mouse_entered.connect(_on_mouse_entered)
	$StartButton.mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	$HoverLabel.show()
	if color_accessible:
		sprite.modulate = Color("00aaffff")
	else:
		sprite.modulate = Color(1.3, 1.3, 1.3)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited() -> void:
	$HoverLabel.hide()
	if color_accessible:
		sprite.modulate = Color("00fff2ff")
	else:
		sprite.modulate = Color(1, 1, 1)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("leftclick"):
		new_game.emit()


func enable_accessible_colors(enable: bool):
	if enable:
		sprite.modulate = Color("00fff2ff")
		color_accessible = true
	else:
		sprite.modulate = Color(1, 1, 1)
		color_accessible = false
