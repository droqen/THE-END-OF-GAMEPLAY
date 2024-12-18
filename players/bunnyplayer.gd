extends NavdiSolePlayer
#extends Node2D

enum {
	FLORBUF,
	JUMPHITBUF,
	CHIMNYBUF,
	SPAWNEDBUF,
}

@onready var spr = $SheetSprite
@onready var mover = $NavdiBodyMover
@onready var solidcast = $NavdiBodyMover/ShapeCast2D
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,5, JUMPHITBUF,5, CHIMNYBUF,3, SPAWNEDBUF,2, ])

var vx : float;
var vy : float;
var ajs : int = 1;
var last_aj : bool = true;
var ajflippyfloppin : bool = false
var ajupsideydowney : bool = false
var ducking : bool = false
var inchimny : bool = false

func _ready() -> void:
	super._ready()
	bufs.on(FLORBUF) # start on the floor, i think.
	bufs.on(SPAWNEDBUF)

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_held(): dpad.y = -1
	if Pin.get_jump_hit(): bufs.on(JUMPHITBUF)
	if bufs.try_eat([JUMPHITBUF,FLORBUF]):
		vy = -1.0
	elif ajs>0 and bufs.try_eat([JUMPHITBUF]):
		vy = -1.0
		ajs -= 1
		ajflippyfloppin = true
	elif ajs==0 and bufs.try_eat([JUMPHITBUF]):
		vx *= 0.5
		vy = -2.0 # but gravity is high
		ajs = -1
		ajupsideydowney = true
	var onfloor : bool = (vy >= 0 and
	mover.cast_fraction(self, solidcast, VERTICAL, 1) < 1
	)
	#var inchimny_now = $left.is_colliding() and $right.is_colliding() and vy >= -0.6
	var inchimny_now = (inchimny or vy >= -0.6) and (
		mover.cast_fraction(self,
			$NavdiBodyMover/squeezecast,
			HORIZONTAL, -5) < 1
		and
		mover.cast_fraction(self,
			$NavdiBodyMover/squeezecast,
			HORIZONTAL, 5) < 1
	)
	if inchimny != inchimny_now:
		inchimny = inchimny_now
		if !inchimny_now and dpad.y < 0:
			bufs.setmin(FLORBUF,20)
			vy = -0.5
			ajs = 1
			ajflippyfloppin = false
			ajupsideydowney = false
	var isduck : bool = onfloor and Pin.get_plant_held() and not inchimny
	if isduck: ducking = true
	elif ducking:
		ducking = false
		if onfloor:
			onfloor = false
			if spr.frame == 20:
				vy = -min(0.5,abs(vx)+0.1)
				bufs.setmin(FLORBUF,20)
		else:
			ajflippyfloppin = true
	
	if inchimny:
		ajflippyfloppin = false # nop
		var chimnyoffset : float = (
			abs($left.get_collision_point().x - $left.global_position.x) -
			abs($right.get_collision_point().x - $right.global_position.x)
		)
		#vx = chimnyoffset
		vx = move_toward(vx * 0.98, dpad.x * 0.5 - 0.5 * chimnyoffset, 0.2)
		if dpad.y > 0:
			vy = move_toward(vy * 0.98, dpad.y * 0.66, 0.3)
		else:
			vy = move_toward(vy * 0.98, dpad.y * 0.66, 0.2)
	elif ajupsideydowney:
		vx = move_toward(vx, dpad.x * 0.25, 0.01) # low maxspeed
	elif ajflippyfloppin:
		if vy < 0:
			vx = move_toward(vx, dpad.x * 1.0, 0.02) # improved control
		else:
			vx = move_toward(vx, dpad.x * 1.0, 0.005) # sliiight control
	else:
		if isduck:
			if abs(vx) > 0.5 and dpad.x: spr.flip_h = dpad.x < 0
			vx = move_toward(vx, 0.0, 0.01)
		elif onfloor:
			if dpad.x: spr.flip_h = dpad.x < 0
			vx = move_toward(vx, dpad.x * 1.0, 0.05)
		else:
			if dpad.x: spr.flip_h = dpad.x < 0
			vx = move_toward(vx, dpad.x * 1.0, 0.02)
	
	if inchimny:
		pass
	elif ajupsideydowney:
		vy = move_toward(vy, 3.0, 0.05)
		if vy < 0 and not Pin.get_jump_held():
			vy += 0.02 # faster fall!
	else:
		vy = move_toward(vy, 2.0, 0.01)
		if vy < 0 and not Pin.get_jump_held():
			vy += 0.02 # faster fall! end your jump early
		elif vy > 0:
			vy += 0.02
			if ajflippyfloppin: vy += 0.01 # flippyfloppin falls a lil xtra fast
	
	if onfloor:
		ajupsideydowney = false
		bufs.on(FLORBUF)
		if vy > 1 and ajflippyfloppin:
			vy = -0.5 # boink
			ajs = 1; ajflippyfloppin = false;
			onfloor = false; bufs.setmin(FLORBUF,20)
	
	if vx and!mover.try_slip_move(self, solidcast, HORIZONTAL, vx):
		if isduck:
			vx *= -0.75
		elif ajupsideydowney:
			vx *= -0.50
		elif ajflippyfloppin or abs(vx) >= 1:
			vx *= -0.75
			if abs(vx) > 0.5: spr.flip_h = vx < 0
			elif dpad.x: spr.flip_h = dpad.x < 0
			vy *= 0.5
			vy -= 0.4
			ajs = 0
			ajflippyfloppin = true;
			onfloor = false
		else:
			vx=0; # it's fine to just stop, lol
	if vy and!mover.try_slip_move(self, solidcast, VERTICAL, vy):
		if vy > 1 and ajflippyfloppin:
			vy = -0.5 # boink
			ajs = 1; ajflippyfloppin = false;
			onfloor = false; bufs.setmin(FLORBUF,20)
		else:
			vy=0;
	
	if bufs.has(SPAWNEDBUF):
		pass
	elif inchimny:
		spr.setup([41,42],10)
		spr.playing = dpad.x or dpad.y
	elif onfloor:
		ajs = 1
		ajflippyfloppin = false
		if isduck:
			if spr.frame == 20: spr.setup([20])
			else: spr.setup([21,20],5)
		elif (dpad.x or vx):
			if len(spr.frames) != 2:
				match spr.frame:
					23: spr.setup([22,23],8)
					_:  spr.setup([23,22],8)
		else:
			spr.setup([22,22,22,23],30)
	else:
		if ajupsideydowney:
			spr.setup([14])
		elif ajflippyfloppin:
			if vy > 0: spr.setup([13,14,15,23],20)
			else: spr.setup([13,14,15,23],6)
		else:
			spr.setup([23])
