extends Node2D
class_name NavdiSolePlayer
const GROUP_NAME : String = "__NSP"
static func GetPlayer(node_in_tree:Node):
	var player = node_in_tree.get_tree().get_first_node_in_group(GROUP_NAME)
	if is_instance_valid(player): return player # else null
func _ready() -> void:
	var prev_player = GetPlayer(self)
	if prev_player and prev_player != self:
		prev_player.hide(); prev_player.queue_free();
		#prints("well i (",self,") can't replace ",prev_player)
		#hide(); queue_free();
		add_to_group(GROUP_NAME)
	else:
		add_to_group(GROUP_NAME)
