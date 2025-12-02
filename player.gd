extends CharacterBody2D

const xspeed = 200.0
const fall = 350.0
const jump = -90.0
const maxfall = 900.0

const tiltup = -30.0
const tiltdown = 27.0
const rotup = 1.0
const rotdown = 2.5

@onready var sprite = $AnimatedSprite2D
@onready var body = $CollisionShape2D

var alive = true

func _ready():
	if sprite:
		sprite.play("fly")

func _physics_process(delta):
	if not alive:
		return
	
	velocity.x = xspeed
	velocity.y += fall * delta
	
	if velocity.y > maxfall:
		velocity.y = maxfall
	
	if Input.is_action_just_pressed("ui_accept"):
		go()
	
	turn(delta)
	move_and_slide()
	hit()

func go():
	velocity.y = jump

func turn(delta):
	var angle = 0.0
	var speed = 0.0
	
	if velocity.y < 0:
		angle = tiltup
		speed = rotup
	else:
		var ratio = velocity.y / maxfall
		angle = tiltdown * ratio
		speed = rotdown
	
	rotation_degrees = lerp(rotation_degrees, angle, speed * delta)

func hit():
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col:
			kill()
			break

func kill():
	if not alive:
		return
	
	alive = false
	velocity = Vector2.ZERO
	
	if sprite:
		sprite.stop()
	
	set_physics_process(false)
	
	if get_parent().has_method("end"):
		get_parent().end()
	
	print("Player died!")

func restart():
	alive = true
	velocity = Vector2.ZERO
	rotation_degrees = 0
	set_physics_process(true)
	
	if sprite:
		sprite.play("fly")
		#i am here to type my resume cz tommorow is my pt test an dher ei am bscoing death
