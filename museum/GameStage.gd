@tool
extends Node2D
class_name GameStage
@export var size : Vector2i = Vector2i(100, 100)
signal touched_exit(exit_id, exit_stage_path)
var last_stage_path : String
const GROUP_NAME = "__GMSTG"
func _ready() -> void:
	add_to_group(GROUP_NAME)
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(0,0,size.x,size.y),Color.MAROON,false)
		draw_rect(Rect2(-2,-2,size.x+4,size.y+4),Color.WEB_MAROON,false)

static func GetGameStage(node_in_tree:Node) -> GameStage:
	return node_in_tree.get_tree().get_first_node_in_group(GROUP_NAME)
