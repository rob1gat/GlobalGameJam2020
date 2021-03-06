extends RigidBody2D

onready var utilsColor = preload("res://Utils/Color.gd").new()

signal batteryDestroyed
signal batteryFunctionnal

var _colorRequired
var _state
export (float) var _elapsedTime = -5 # original delay (should be negative)

enum State {FUNCTIONNAL, BROKEN, DESTROYED}

export (float) var changeStateTime = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	setStateToFunctionnal()
	#$SpriteBG.set_texture(preload("res://Battery/BatteryStep1BG.png"))
	add_to_group("battery")
	$Area2D.connect("body_entered",self,"_onBodyEntered")
	changeColor()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_elapsedTime += delta
	_manageState()

func checkDowngradeState():
	if(_state == State.FUNCTIONNAL):
		setStateToBroken()
	elif(_state == State.BROKEN):
		setStateToDestroyed()

func _manageState():
	if(_elapsedTime >= changeStateTime):
		checkDowngradeState()

func _onBodyEntered(body):
	if(body.is_in_group("crystal")):
		var crystal = body
		if(crystal.getColor() == _colorRequired):
			setStateToFunctionnal()
		else:
			checkDowngradeState()
		crystal.die()

# Getter and Setter 
func getColorRequired() -> int:
	return _colorRequired

func setColorRequired(colorGiven):
	_colorRequired = colorGiven

func changeColor():
	var newcolor = utilsColor.randomColor()
	while(newcolor == _colorRequired):
		 newcolor = utilsColor.randomColor()
	_colorRequired = newcolor
	$Sprite.modulate = utilsColor.getColorValue(_colorRequired)
	print(utilsColor.getColorValue(_colorRequired))
	$Sprite.modulate.a = 1

func getState() -> int:
	return _state

func setStateToFunctionnal():
	print("FUNCTIONNAL")
	$Sprite.set_texture(preload("res://Battery/Changeables/BatteryStep1.png"))
	#$SpriteBG.set_texture(preload("res://Battery/BatteryStep1BG.png"))
	_elapsedTime = 0.0
	_state = State.FUNCTIONNAL
	changeColor()
	emit_signal("batteryFunctionnal",self)

func setStateToBroken():
	print("BROKEN")
	$Sprite.set_texture(preload("res://Battery/Changeables/BatteryStep2.png"))
	#$SpriteBG.set_texture(preload("res://Battery/BatteryStep2BG.png"))
	_elapsedTime = 0.0
	_state = State.BROKEN

func setStateToDestroyed():
	print("DESTROYED")
	$Sprite.set_texture(preload("res://Battery/Changeables/BatteryStep3.png"))
	#$SpriteBG.set_texture(preload("res://Battery/BatteryStep3BG.png"))
	_elapsedTime = 0.0
	_state = State.DESTROYED
	emit_signal("batteryDestroyed",self)
	
