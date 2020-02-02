extends RigidBody2D
onready var utilsColor = preload("res://Utils/Color.gd").new()

signal batteryDestroyed
signal batteryFunctionnal

var _colorRequired
var _state
var _elapsedTime = 0.0

enum State {FUNCTIONNAL, BROKEN, DESTROYED}

export (float) var changeStateTime = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("battery")
	$Area2D.connect("body_entered",self,"_onBodyEntered")
	_colorRequired = utilsColor.randomColor()
	_state = State.FUNCTIONNAL

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

# Getter and Setter 
func getColorRequired() -> int:
	return _colorRequired

func setColorRequired(colorGiven):
	_colorRequired = colorGiven

func getState() -> int:
	return _state

func setStateToFunctionnal():
	_elapsedTime = 0.0
	_state = State.FUNCTIONNAL
	emit_signal("batteryFunctionnal",self)

func setStateToBroken():
	_elapsedTime = 0.0
	_state = State.BROKEN

func setStateToDestroyed():
	print("battery is destroyed")
	_elapsedTime = 0.0
	_state = State.DESTROYED
	emit_signal("batteryDestroyed",self)
	
