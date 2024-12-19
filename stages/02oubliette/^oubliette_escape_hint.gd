extends Node

var timer : float = 30.0
var visited_middle : bool = false
var visited_topleft : bool = false

func _ready() -> void:
	get_parent().hide()

func _physics_process(delta: float) -> void:
	var ppos = NavdiSolePlayer.GetPlayer(self).position
	if !visited_middle:
		visited_middle = ppos.y < 70
	if !visited_topleft:
		visited_topleft = ppos.x < 38 and ppos.y < 35
	if visited_topleft: timer -= 10 * delta # 3 seconds
	elif visited_middle: timer -= 3 * delta
	else: timer -= delta
	if timer < 0:
		get_parent().show()
		queue_free()
		
