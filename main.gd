extends Node2D


@onready var pnl = $Panel
@onready var play = $Node2D/play_btn
@onready var sett = $Node2D/setting_btn

@onready var mute = $Panel/mute
@onready var vol = $Panel/volume
@onready var back = $Panel/back


const GH_URL = "https://github.com/basic-bitch-foundation/knight-crow"

func _ready():
	
	pnl.visible = false
	
	
	play.pressed.connect(play_pressed)
	sett.pressed.connect(sett_pressed)
	
	mute.pressed.connect(mute_pressed)
	vol.value_changed.connect(vol_chg)
	back.pressed.connect(back_pressed)
	
	
	vol.min_value = 0
	vol.max_value = 100
	vol.value = 100

func play_pressed():
	audio.play_click() 
	
	get_tree().change_scene_to_file("res://map.tscn")

func sett_pressed():
	audio.play_click()
	pnl.visible = true



func mute_pressed():
	
	audio.play_click()
	
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus, not AudioServer.is_bus_mute(bus))
	
	
	

func vol_chg(value):
	
	var bus = AudioServer.get_bus_index("Master")
	var vol_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus, vol_db)

func back_pressed():
	audio.play_click()
	
	pnl.visible = false
