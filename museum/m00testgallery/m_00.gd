extends Node2D

#@onready var view_container : SubViewportContainer = $vpc
#@onready var game_viewport : SubViewport = $vpc/vp
#var stage : GameStage = null
var stage_size : Vector2i = Vector2i(100, 100)
@onready var stage_holder : Node2D = $stage_holder
@onready var camera : Camera2D = $Camera2D
var game_scale : int = 0
@export var border : int = 20
#var _last_known_viewport_size : Vector2i

#var blurmin : float = 0.0
#var blurmax : float = 0.0
#var blurphase : float = 0.0

func _ready() -> void:
	set_gamestage(
		load("res://stages/00coins/00coins.tscn").instantiate()
	) # just create one.
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

func set_gamestage(stage:GameStage) -> void:
	stage_size = stage.size
	#stage.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var stage_is_already_vps_child : bool = false
	for prestage in stage_holder.get_children():
		if prestage == stage:
			stage_is_already_vps_child = true
		else:
			# boom, goodbye any leftover children.
			prestage.process_mode = Node.PROCESS_MODE_DISABLED
			prestage.hide()
			prestage.queue_free()
	if not stage_is_already_vps_child:
		stage_holder.add_child(stage)
		stage.owner = owner if owner else self
		stage.touched_exit.connect(func(xid,xpath):
			var new_stage = load(xpath).instantiate()
			if new_stage:
				set_gamestage(new_stage)
		)
	_on_resize()

func _on_resize() -> void:
	var screen_size : Vector2i = get_viewport_rect().size
	var game_scale_2 : int = maxi(1,mini(
		screen_size.x / (stage_size.x + border),
		screen_size.y / (stage_size.y + border)
	))
	if game_scale != game_scale_2:
		game_scale = game_scale_2
		camera.zoom = Vector2(game_scale, game_scale)
		#blurmin = max(1.0,game_scale * 0.66)
		#blurmax = max(1.0,game_scale * 1.33)
		(material as ShaderMaterial).set_shader_parameter("blur_amount", max(1.0,game_scale * 0.66))
	camera.position = Vector2(floor(stage_size.x/2),floor(stage_size.y/2))

#func _physics_process(delta: float) -> void:
	#blurphase += delta
	#(material as ShaderMaterial).set_shader_parameter("blur_amount", lerp(blurmin,blurmax,0.5+0.5*sin(blurphase)))
	#
