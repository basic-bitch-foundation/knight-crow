extends Node2D

@onready var crow = $player
@onready var cam = $Camera2D
@onready var start = $SpawnPoint
@onready var obs = $obstaclemanager

var dead = false
var score = 0

func _ready():
	if cam and crow:
		cam.enabled = true
		cam.position = Vector2(crow.position.x + 100, 320)
	setup()

func _process(_delta):
	if dead:
		return
	
	if cam and crow:
		cam.position.x = crow.position.x + 100
		
	

func setup():
	dead = false
	score = 0
	
	var spawn_pos = start.position if start else Vector2(200, 300)
	
	if crow:
		crow.position = spawn_pos
		crow.restart()

func end():
	if dead:
		return
	dead = true
	
	if crow:
		crow.kill()
	
	print("GAME OVER  ")
	
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
