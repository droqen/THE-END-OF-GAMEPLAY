extends Node2D
class_name NavdiSolePlayer
const GROUP_NAME : String = "__NSP"
static func GetPlayer(node_in_tree:Node):
	var player = node_in_tree.get_tree().get_first_node_in_group(GROUP_NAME)
	if is_instance_valid(player): return player # else null
var desires_to_be_held : int = 0
func _ready() -> void:
	var prev_player = GetPlayer(self)
	if prev_player and prev_player != self:
		prints("well i (",self.get_path(),") can't replace",prev_player.get_path())
		hide(); queue_free();
	else:
		add_to_group(GROUP_NAME)
		if not try_to_be_held():
			await get_tree().create_timer(0.1).timeout
			try_to_be_held()
func try_to_be_held():
	var holder = NavdiSolePlayerHolder.GetHolder(self)
	if holder: reparent.call_deferred(holder); return true;
