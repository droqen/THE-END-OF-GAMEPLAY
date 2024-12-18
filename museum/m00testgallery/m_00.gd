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

@export var first_stage : PackedScene
const FIRST_STAGE_DEFAULT = preload("res://stages/01debugmenu/00_debugmenu.tscn") 

func _ready() -> void:
	gradual_goto_gamestage(
		null,
		(first_stage if first_stage else FIRST_STAGE_DEFAULT).instantiate()
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
			match xpath:
				'','res://':
					gradual_goto_gamestage(stage,
						FIRST_STAGE_DEFAULT.instantiate())
				_:
					if ResourceLoader.exists(xpath): 
						gradual_goto_gamestage(stage,
							load(xpath).instantiate())
					else:
						push_error("[m_00.gd] can't go to scene at bad path '%s'" % xpath)
						print("[m_00.gd] can't go to scene at bad path '%s'" % xpath)
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
		update_blur()
	camera.position = Vector2(floor(stage_size.x/2),floor(stage_size.y/2))

func gradual_goto_gamestage(laststage:GameStage, newstage:GameStage):
	get_tree().paused = true # pause the game.
	if laststage != null:
		$EntireScreenOverlay.modulate.a = 0
		$EntireScreenOverlay.show()
		for i in range(0+1,10+1,1):
			await get_tree().create_timer(0.05).timeout
			if randf()<0.01: await get_tree().create_timer(randf()*randf()).timeout
			set_blur_mult(1.0 + i * 0.5)
			$EntireScreenOverlay.modulate.a = i * 0.2 - 1
		newstage.last_stage_path = laststage.scene_file_path
	else:
		$EntireScreenOverlay.modulate.a = 1
		$EntireScreenOverlay.show()
		set_blur_mult(6.0)
	set_gamestage(newstage)
	await get_tree().create_timer(randf()*randf()).timeout
	for i in range(10,0-1,-1):
		await get_tree().create_timer(0.05).timeout
		if randf()<0.01: await get_tree().create_timer(randf()*randf()).timeout
		set_blur_mult(1.0 + i * 0.5)
		$EntireScreenOverlay.modulate.a = i * 0.2 - 1
	$EntireScreenOverlay.hide()
	get_tree().paused = false # finally -- unpause it.

var blur_multiplier : float = 1.0
func set_blur_mult(m:float):
	blur_multiplier = m
	update_blur()
func update_blur():
	(material as ShaderMaterial).set_shader_parameter("blur_amount",
		max(1.0,game_scale * 0.66 * blur_multiplier)
	)
