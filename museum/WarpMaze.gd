extends Maze

@export_file("*.tscn") var goto_1 = ''
@export_file("*.tscn") var goto_2 = ''
@export_file("*.tscn") var goto_3 = ''
@export_file("*.tscn") var goto_4 = ''

func _physics_process(_delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	match get_cell_tid(local_to_map(player.position)):
		1: get_parent().touched_exit.emit(1, goto_1)
		2: get_parent().touched_exit.emit(2, goto_2)
		3: get_parent().touched_exit.emit(3, goto_3)
		4: get_parent().touched_exit.emit(4, goto_4)
