extends Node2D

enum PauseReason { None, Cancelling, LoadingStage, FadingInStage }
var pause_reason : PauseReason = PauseReason.None

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
const MENU_STAGE = preload("res://stages/01debugmenu/00_debugmenu.tscn") 

var current_stage : GameStage

func _ready() -> void:
	gradual_goto_gamestage(
		current_stage,
		(first_stage if first_stage else MENU_STAGE).instantiate()
	) # just create one.
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

func _physics_process(delta: float) -> void:
	var player = NavdiSolePlayer.GetPlayer(self)
	if player:
		if player.global_position.y - 5 > get_viewport_rect().position.y + get_viewport_rect().size.y:
			gradual_goto_gamestage(current_stage, MENU_STAGE.instantiate())
		
	if Input.is_action_just_pressed("ui_cancel"):
		try_pause(PauseReason.Cancelling)
	if pause_reason == PauseReason.Cancelling:
		var f2 = fade_progress
		if Input.is_action_pressed("ui_cancel"):
			f2 = clampf(fade_progress + delta, 0.0, 1.0)
		else:
			f2 = clampf(fade_progress - delta, 0.0, 1.0)
		if f2 >= 0.999:
			try_unpause(PauseReason.Cancelling)
			gradual_goto_gamestage(null, MENU_STAGE.instantiate())
		elif f2 <= 0.001:
			set_fade_progress(0.0)
			try_unpause(PauseReason.Cancelling)
			pause_reason = PauseReason.None
		else:
			set_fade_progress(f2)

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
		self.current_stage = stage
		stage.owner = owner if owner else self
		stage.touched_exit.connect(func(xid,xpath):
			match xpath:
				'','res://':
					gradual_goto_gamestage(stage,
						MENU_STAGE.instantiate())
				_:
					if ResourceLoader.exists(xpath): 
						gradual_goto_gamestage(stage,
							load(xpath).instantiate())
					else:
						push_error("[m_00.gd] can't go to scene at bad path '%s'" % xpath)
						print("[m_00.gd] can't go to scene at bad path '%s'" % xpath)
		)
		
		if stage.scene_file_path.contains('debug'):
			$music_player.bgm = 'endoftheme'
		elif stage.scene_file_path.contains('_'):
			$music_player.bgm = 'musicbox'
		else:
			$music_player.bgm = ''
		
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
	
	var moving_within_folder : bool = false
	if (laststage != null and
		laststage.scene_file_path.rsplit("/",true,1)[0] ==
		newstage.scene_file_path.rsplit("/",true,1)[0]):
			moving_within_folder = true
	
	var tenthpause : float = 0.05
	var longpause_chance : float = 0.01
	var longpause_mult : float = 1.00
	var betweenpause_base : float = 0.00
	
	if moving_within_folder:
		#longpause_chance = 0.00
		#tenthpause *= 0.50
		longpause_mult = 0.50
	else:
		betweenpause_base = 1.00
	
	if try_pause(PauseReason.LoadingStage):
		if laststage != null:
			for i in range(0+1,10+1,1):
				await get_tree().create_timer(tenthpause).timeout
				if randf()<longpause_chance: await get_tree().create_timer(randf()*randf()*longpause_mult).timeout
				set_fade_progress(i*0.1)
			newstage.last_stage_path = laststage.scene_file_path
		else:
			set_fade_progress(1.00) # 100%
		
		set_gamestage(newstage)
		if laststage != null:
			await get_tree().create_timer(
				betweenpause_base + randf()*randf()*longpause_mult
					).timeout
		
		if pause_reason == PauseReason.LoadingStage:
			pause_reason = PauseReason.FadingInStage
		
		for i in range(10,0-1,-1):
			await get_tree().create_timer(tenthpause).timeout
			if randf()<longpause_chance: await get_tree().create_timer(randf()*randf()*longpause_mult).timeout
			set_fade_progress(i*0.1)
		set_fade_progress(0.0)
		try_unpause(PauseReason.FadingInStage)

var fade_progress : float = 0.0
func set_fade_progress(f:float):
	fade_progress = f
	set_blur_mult(1.0 + 5.0 * fade_progress)
	if fade_progress < 0.5:
		$EntireScreenOverlay.hide()
	else:
		$EntireScreenOverlay.show()
		$EntireScreenOverlay.modulate.a = 2.0 * (fade_progress - 0.5)
var blur_multiplier : float = 1.0
func set_blur_mult(m:float):
	blur_multiplier = m
	update_blur()
func update_blur():
	(material as ShaderMaterial).set_shader_parameter("blur_amount",
		max(1.0,game_scale * 0.66 * blur_multiplier)
	)

func try_pause(reason:PauseReason)->bool:
	match pause_reason:
		PauseReason.None:
			pause_reason = reason
			$stage_holder.process_mode = Node.PROCESS_MODE_DISABLED
			$player_holder.process_mode = Node.PROCESS_MODE_DISABLED
			return true;
		#reason: return true; # already paused
		_: return false;

func try_unpause(reason:PauseReason)->bool:
	match pause_reason:
		reason:
			pause_reason = PauseReason.None
			$stage_holder.process_mode = Node.PROCESS_MODE_INHERIT
			$player_holder.process_mode = Node.PROCESS_MODE_INHERIT
			return true;
		#PauseReason.None: return true; # already unpaused
		_: return false;
