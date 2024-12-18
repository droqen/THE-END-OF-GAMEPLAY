extends Node2D

const BGM_MUSICBOX = preload("res://music/musicbox.mp3")
const BGM_ENDOFTHEME = preload("res://music/the-end-of-gameplay-theme.mp3")

var bgm : String = 'endoftheme'

@onready var musicbox : AudioStreamPlayer = $Musicbox

@onready var moo = get_parent()
var glitching : bool = false
var glitching_point : float = 0.0
var glitching_delay : float = 0.0
var glitching_delay_length : float = 0.0

func _ready():
	musicbox.stream = BGM_ENDOFTHEME
	musicbox.play()

func _physics_process(delta: float) -> void:
	if glitching:
		glitching_delay -= delta
		musicbox.volume_db -= 5 * delta
		if glitching_delay <= 0.1:
			glitching_delay = glitching_delay_length
			musicbox.play(glitching_point)
			glitching_delay_length += 0.01
	else:
		match bgm:
			'endoftheme':
				if musicbox.stream != BGM_ENDOFTHEME:
					musicbox.stream = BGM_ENDOFTHEME
					musicbox.play()
					musicbox.volume_db = -10 # fade in
				musicbox.volume_db = lerp(musicbox.volume_db, 0.0, 0.01)
			'musicbox':
				if musicbox.stream != BGM_MUSICBOX:
					musicbox.stream = BGM_MUSICBOX
					musicbox.play()
					musicbox.volume_db = -10 # fade in
				musicbox.volume_db = lerp(musicbox.volume_db, 0.0, 0.01)
			_:
				musicbox.volume_db -= 5 * delta
	match moo.pause_reason:
		moo.PauseReason.LoadingStage, moo.PauseReason.Cancelling:
			if !glitching:
				glitching = true
				glitching_point = $Musicbox.get_playback_position()
				glitching_delay = 0.1
				glitching_delay_length = 0.1
		_:
			glitching = false
	
		
