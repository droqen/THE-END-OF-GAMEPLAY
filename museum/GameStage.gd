extends Node2D
class_name GameStage
@export var size : Vector2i = Vector2i(100, 100)
signal touched_exit(exit_id, exit_stage_path)
var last_stage_path : String
