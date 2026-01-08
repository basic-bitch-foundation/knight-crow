extends Node2D

@onready var crow = $player
@onready var cam = $Camera2D
@onready var start = $SpawnPoint
@onready var obs = $obstaclemanager
@onready var over = $ui/over
@onready var pause_btn = $ui/pause

@onready var scorebrd =$ui/score
@onready var digit_sprites = [$ui/score/d1 ,$ui/score/d2,$ui/score/d3,$ui/score/d4]
var time = 0.0;
var digits = []





@onready var prts = $prts

var dead = false
var score = 0
var paused = false

func _ready():
	for i in range(10):
		digits.append(load("res://images/%d.png"  % i))
		
	if over:
		over.visible = false
	if prts:
		prts.visible = true
		
	if cam and crow:
		cam.enabled = true
		cam.position = Vector2(crow.position.x + 100, 320)
	setup()

func _process(_delta):
	if dead:
		return
	
	if cam and crow:
		cam.position.x = crow.position.x + 100
		
	if crow and crow.game_strt and crow.alive:
		time += _delta
		update_score()

func setup():
	audio.play_restart()
	if prts:
		prts.visible = true
	dead = false
	score = 0
	time = 0.0
	
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
	
	await get_tree().create_timer(0.9).timeout
	
	if over:
		over.visible = true
	audio.play_game_over()
	
	
	await get_tree().create_timer(3.0).timeout
	
	
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()


func update_score():
	var time_scr = int(time*10);
	time_scr = min(time_scr,9999)
	var digit = [(time_scr / 1000) % 10,(time_scr / 100) % 10 , (time_scr / 10) % 10,time_scr % 10]
	for i in range(4):
		if digit_sprites[i]:
			digit_sprites[i].texture  = digits[digit[i]]
		
	
	

func _on_pause_toggled(button_pressed):
	audio.play_click()
	get_tree().paused = button_pressed
