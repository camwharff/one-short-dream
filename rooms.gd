extends Node2D

var active: Node2D


func _ready():
	for room in get_children():
		room.hide()
	for portal in get_tree().get_nodes_in_group("portals"):
		portal.update_scene.connect(_on_update_scene)


func _on_update_scene(destination: String) -> void:
	go_to(get_node(destination))


func go_to(room: Node2D) -> void:
	if active:
		active.hide()
	active = room
	active.show()


func enable_phase_portals(phase_name: String) -> void:
	for portal in get_tree().get_nodes_in_group("portals"):
		var on = portal.phases.has(phase_name)
		portal.visible = on
		portal.input_pickable = on
