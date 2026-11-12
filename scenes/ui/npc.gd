class_name NPC
extends Area2D

signal hover(
	message: String,
	enable: bool,
	up: String,
	down: String,
	node: Node2D,
)
signal start_puzzle(puzzle: String)

@export var stats: Dictionary[String, int] = {
	"carryover": 0,
	"energy": 0,
	"happiness": 0,
	"sanity": 0,
	"stress": 0,
	"time": 1,
	"begin": 0,
	"end": 100,
}
@export var flags: Dictionary[String, bool] = { "early_exit": false }
@export var icons: Dictionary[String, String] = {
	"up": "energy",
	"down": "time",
}
@export var npc_name: String = "Task"
@export var hover_message: String
@export var prereqs: Array[String] = []
@export var blocked_by: Array[String] = []
@export var triggers: Array[String] = []
@export var dialogue: DialogueResource

var enable = false
var complete = false
var color_accessible = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	add_to_group("npcs")
	add_to_group("clickables")


func _on_mouse_entered() -> void:
	if color_accessible:
		sprite.modulate = Color("00aaffff")
	else:
		sprite.modulate = Color(1.3, 1.3, 1.3)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	hover.emit(hover_message, true, icons["up"], icons["down"], self)


func _on_mouse_exited() -> void:
	if color_accessible:
		sprite.modulate = Color("00fff2ff")
	else:
		sprite.modulate = Color(1, 1, 1)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	hover.emit(hover_message, false, icons["up"], icons["down"], self)


func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("leftclick"):
		DialogueManager.show_dialogue_balloon(dialogue, "start", [self])
		input_pickable = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		audio.play()


func complete_task() -> void:
	complete = true


func enable_accessible_colors(enable_access: bool):
	if enable_access:
		sprite.modulate = Color("00fff2ff")
		color_accessible = true
	else:
		sprite.modulate = Color(1, 1, 1)
		color_accessible = false
