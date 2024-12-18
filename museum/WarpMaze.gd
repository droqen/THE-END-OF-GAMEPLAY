extends Maze

@export_file("*.tscn") var goto_1 = ''
@export_file("*.tscn") var goto_2 = ''
@export_file("*.tscn") var goto_3 = ''
@export_file("*.tscn") var goto_4 = ''

var stage_size_in_tiles : Vector2i

func _ready() -> void:
	super._ready()
	var stage : GameStage = get_parent()
	stage_size_in_tiles = Vector2i(stage.size.x, stage.size.y)/10
	var last_stage_path = stage.last_stage_path
	var player = NavdiSolePlayer.GetPlayer(self)
	var enter_id = "*"
	if player and last_stage_path:
		if last_stage_path == goto_1: enter_id = 1;
		if last_stage_path == goto_2: enter_id = 2;
		if last_stage_path == goto_3: enter_id = 3;
		if last_stage_path == goto_4: enter_id = 4;
	NavdiSolePlayer.SetPosition(self, get_exit_pos(enter_id))

func _physics_process(_delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	if player:
		var playercell = local_to_map(player.position)
		match get_cell_tid(playercell):
			1: get_parent().touched_exit.emit(1, goto_1)
			2: get_parent().touched_exit.emit(2, goto_2)
			3: get_parent().touched_exit.emit(3, goto_3)
			4: get_parent().touched_exit.emit(4, goto_4)
			_: # wrap
				# try x-wrap
				if playercell.x < 0:
					player.position.x = map_to_local(stage_size_in_tiles-Vector2i.ONE).x
				if playercell.x >= stage_size_in_tiles.x:
					player.position.x = map_to_local(Vector2i.ZERO).x
				#if playercell.y >= stage_size_in_tiles.y:
					#player.position.y = map_to_local(Vector2i.ZERO).y
				#if playercell.y < 0:
					#player.position.y = map_to_local(stage_size_in_tiles-Vector2i.ONE).y

func get_exit_pos(exit_id):
	
	var exit_cells
	if exit_id is int:
		exit_cells = get_used_cells_by_tids([10 + exit_id])
	if (exit_id is String and exit_id == "*") or (exit_cells.size()==0):
		exit_cells = get_used_cells_by_tids([10])
		if exit_cells.size() == 0:
			exit_cells = get_used_cells_by_tids([11,12,13,14])
	match exit_cells.size():
		0: return map_to_local(Vector2(0,0)) # whoops
		1: return map_to_local(exit_cells[0])
		2: return map_to_local(exit_cells[randi()%exit_cells.size])
