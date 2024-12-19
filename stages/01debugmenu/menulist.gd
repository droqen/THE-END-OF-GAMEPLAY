extends Label

@export var menuitems : Array[String]
@export var targetscenes : Array[String]
var cursor : int = 0
var cursor_offset : float = 0.0
func _ready() -> void:
	text = ''
	process_mode = PROCESS_MODE_ALWAYS
func _physics_process(_delta: float) -> void:
	text = ''
	for i in range(len(menuitems)):
		if i == cursor and abs(cursor_offset) <2:
			text += '[%s]\n' % menuitems[i]
		else:
			text += ' %s \n' % menuitems[i]
	cursor_offset *= 0.8
	var p = NavdiSolePlayer.GetPlayer(self)
	if p:
		p.position = position + Vector2(0, cursor * 5 + cursor_offset)
	if abs(cursor_offset) <3:
		if cursor < 0:
			cursor = len(menuitems)-1
		elif cursor >= len(menuitems):
			cursor = 0
		else: match Pin.get_dpad_tap().y:
			1:  cursor += 1; cursor_offset -= 5;
			-1: cursor -= 1; cursor_offset += 5;
			_:
				if Pin.get_action_hit():
					GameStage.GetGameStage(self).touched_exit.emit(
						1,
						targetscenes[cursor]
					)
