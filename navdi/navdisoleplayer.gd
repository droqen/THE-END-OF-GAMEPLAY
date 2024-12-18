extends Node2D
class_name NavdiSolePlayer
const GROUP_NAME : String = "__NSP"
static func GetPlayer(node_in_tree:Node):
	var player = node_in_tree.get_tree().get_first_node_in_group(GROUP_NAME)
	if is_instance_valid(player): return player # else null
static var player_position_set_to = null
static func SetPosition(node_in_tree:Node, pos:Vector2):
	var player = GetPlayer(node_in_tree)
	if player: player.position = pos;
	player_position_set_to = pos;
var desires_to_be_held : int = 0
func _ready() -> void:
	var prev_player = GetPlayer(self)
	if prev_player and prev_player != self and prev_player.name == name:
		hide(); queue_free();
	else:
		if prev_player: prev_player.hide(); prev_player.queue_free();
		add_to_group(GROUP_NAME)
		if not try_to_be_held():
			await get_tree().create_timer(0.1).timeout
			try_to_be_held()
	if player_position_set_to != null:
		position = player_position_set_to;
		player_position_set_to = null;
func try_to_be_held():
	var holder = NavdiSolePlayerHolder.GetHolder(self)
	if holder: reparent.call_deferred(holder); return true;
