extends NavdiSolePlayer

func _physics_process(_delta: float) -> void:
	position += Pin.get_dpad() * 0.25
	if Pin.get_action_hit():
		GameStage.GetGameStage(self).touched_exit.emit(
			1, "res://stages/00coins/00coins.tscn")
