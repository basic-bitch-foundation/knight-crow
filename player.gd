extends CharacterBody2D

const xspd = 200.0
const grav = 350.0
const jmp = -200.0
const maxfall = 900.0
const tiltup = -30.0
const tiltdown = 27.0

@export var margin = -29.0

@onready var sprite = $AnimatedSprite2D
@onready var body = $CollisionShape2D

var alive = true
var game_strt = false

func _ready():
	if sprite:
		sprite.play("fly")
	
	set_physics_process(false)
func _input(evenr):
	if evenr.is_action_pressed("ui_accept") and not game_strt:
		game_strt = true
		var map = get_parent()
		if map and map.has_node("prts"):
			map.get_node("prts").visible = false 
		set_physics_process(true)
		
		

func _physics_process(delta):
	if not alive or not game_strt:
		return
	
	velocity.x = xspd
	velocity.y += grav * delta 
	velocity.y = min(velocity.y, maxfall)
	
	if Input.is_action_just_pressed("ui_accept"):
		
			
		velocity.y = jmp
		
		 
		audio.play_jump()
		
	
	var angle = tiltup if velocity.y < 0 else tiltdown * (velocity.y / maxfall)
	var spd = 1.0 if velocity.y < 0 else 2.5
	rotation_degrees = lerp(rotation_degrees, angle, spd * delta)
	
	move_and_slide()
	
	checkbounds()
	
	if get_slide_collision_count() > 0:
		kill()
		return
	
	checkhit()

func checkbounds():
	var cam = get_viewport().get_camera_2d()
	if not cam:
		return
	
	var vsize = get_viewport_rect().size
	var zoom = cam.zoom
	var vheight = vsize.y / zoom.y
	
	var camy = cam.global_position.y
	var top = camy - vheight/2 + margin
	var btm = camy + vheight/2 - margin
	
	if global_position.y < top or global_position.y > btm:
		kill()
  
func checkhit():
	var obs = get_parent().get_node_or_null("obstaclemanager")
	if obs and obs.check_collision(global_position, Vector2(20, 20)):
		kill()

func kill():
	if not alive:
		return
	
	alive = false
	audio.play_hit()
	velocity = Vector2.ZERO
	
	if sprite:
		sprite.stop()
	
	if get_parent().has_method("end"):
		get_parent().end()

func restart():
	alive = true
	game_strt = false 
	velocity = Vector2.ZERO
	rotation_degrees = 0
	set_physics_process(true)
	
	if sprite:
		sprite.play("fly")
		
	
	
