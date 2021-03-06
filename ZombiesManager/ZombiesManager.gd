extends Node2D

# makes sure it's loaded first
var Zombie = preload("res://Zombie/Zombie.tscn")
onready var Generator = preload("res://Generator/Generator.tscn")
onready var Batterie = preload("res://Battery/Battery.tscn")

enum Difficulty {SWEET, REGULAR, SPICY}

# Declare member variables here.
var _generator
var _battery
export (int) var _battID = 0
var _batterieIsFunctionnal = true
var _randGen = RandomNumberGenerator.new()

export (Difficulty) var difficulty = Difficulty.SWEET
var _spawnTime # time between two zombie spawns, in milliseconds
var _zombieSpeed

var _initialized = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("zombie_manager")
	
	_generator = get_tree().get_root().find_node("Generator", true, false)#get_tree().get_nodes_in_group("generator")
	if _generator == null :
		print("No Generator was found by ZombiesManager!")

	print(_generator.batteries.size())
	
	# sets value depending on selected difficulty
	match(difficulty):
		Difficulty.SWEET :
			_spawnTime = 10
			_zombieSpeed = 10
		Difficulty.REGULAR :
			_spawnTime = 8
			_zombieSpeed = 20
		Difficulty.SPICY :
			_spawnTime = 6
			_zombieSpeed = 50
	
	# to test alone (only needs Generator in scene)
	#_spawnZombies()
	pass


# Called every frame.
func _process(delta) :
	if !_initialized :
		_battery = _generator.batteries[_battID]
		if _battery == null :
			return
		else :
			_battery.connect("batteryDestroyed", self, "onBatteryDestroyed")
			_battery.connect("batteryFunctionnal", self, "onBatteryFunctionnal")
			print("batterie connected : " + String(_battID) + " position is " + String(_battery.position))
			_initialized = true
	pass

func _spawnZombies(location) :
	print("spawn!!")
	while(!_batterieIsFunctionnal) :
		
		if _randGen.randi_range(0,100) <= 30 :
			# creates zombie
			var zombie = Zombie.instance()
			
			# sets params
			zombie.speed = _zombieSpeed
			zombie.position = location
			zombie.setTarget(_generator)
			self.add_child(zombie)
		
		# call next spawn
		yield(get_tree().create_timer(_spawnTime), "timeout")

func onBatteryDestroyed(battery) :
	print("zombies manager receives destroyed signal from battery")
	_batterieIsFunctionnal = false
	var position
	if(_battID == 0):
		position = Vector2(-70,550)
	if(_battID == 1):
		position = Vector2(2021,562)
	if(_battID == 2):
		position = Vector2(900,1154)
	if(_battID == 3):
		position = Vector2(940,-46)
	_spawnZombies(battery.global_position)

func onBatteryFunctionnal(battery) :
	print("zombies manager receives functionnal signal from battery")
	_batterieIsFunctionnal = true
