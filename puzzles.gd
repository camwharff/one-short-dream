extends Node2D

var active: Node
var puzzles: Dictionary = { }


func _ready():
	GameState.setup_complete.connect(_puzzle_setup)


func _resolve_puzzle(puzzle_name: String, status: String):
	var resource = load(puzzles[puzzle_name])

	get_node(puzzle_name).hide()
	DialogueManager.show_dialogue_balloon(resource, status, [self])


func _puzzle_setup():
	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.start_puzzle.connect(_on_start_puzzle)
	for puzzle in get_children():
		add_to_group("puzzles")
		puzzle.game_over.connect(_resolve_puzzle)
		puzzles.get_or_add(puzzle.puzzle_name, puzzle.owner_dialogue)
		puzzle.hide()


func _on_start_puzzle(puzzle: String) -> void:
	go_to(get_node(puzzle))


func go_to(room: Node) -> void:
	if active:
		active.hide()
	active = room
	active.show()
