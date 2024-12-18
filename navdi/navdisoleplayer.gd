extends Node2D
class_name NavdiSolePlayer
static var _player
static func GetPlayer():
	return _player
func _ready() -> void:
	if _player != null and is_instance_valid(_player):
		hide(); queue_free();
	else:
		_player = self # i am the sole player.
