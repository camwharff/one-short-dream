class_name Portal

extends Area2D

signal update_scene(dest: String)
signal hover(message: String, enable: bool)

@export var destination: String
@export var hover_message: String
@export var phases: Array[String] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var portal = true
var color_accessible = false


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("portals")
	add_to_group("clickables")

	for phase in phases:
		add_to_group(phase)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if color_accessible:
		sprite.modulate = Color("00aaffff")
	else:
		sprite.modulate = Color(1.3, 1.3, 1.3)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	hover.emit(hover_message, true, "up", "down", self)


func _on_mouse_exited() -> void:
	if color_accessible:
		sprite.modulate = Color("00fff2ff")
	else:
		sprite.modulate = Color(1, 1, 1)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	hover.emit(hover_message, false, "up", "down", self)


# Called when a portal is clicked. Changes the scene to the destination.
func _on_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("leftclick"):
		audio.play()
		update_scene.emit(destination)


func enable_accessible_colors(enable: bool):
	if enable:
		sprite.modulate = Color("00fff2ff")
		color_accessible = true
	else:
		sprite.modulate = Color(1, 1, 1)
		color_accessible = false
