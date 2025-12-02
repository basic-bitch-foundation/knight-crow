extends Node2D

const scroll = 200.0

@onready var bg = $ParallaxBackground
@onready var crow = $player
@onready var cam = $Camera2D
@onready var start = $SpawnPoint

var dead = false
var offset = 0.0

func _ready():
	if cam:
		cam.position = crow.position
	
	setup()

func _process(delta):
	if dead:
		return
	
	offset += scroll * delta
	bg.scroll_offset.x = -offset
	
	if cam and crow:
		cam.position.x = crow.position.x + 100
		cam.position.y = get_viewport_rect().size.y / 2

func setup():
	dead = false
	offset = 0.0
	
	if crow and start:
		crow.position = start.position
		crow.restart()
	elif crow:
		var h = get_viewport_rect().size.y
		crow.position = Vector2(150, h / 2)
		crow.restart()

func end():
	if dead:
		return
	
	dead = true
	
	if crow:
		crow.kill()
	
	print("GAME OVER!")
	
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
