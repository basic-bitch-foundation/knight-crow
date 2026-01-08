extends Node

# Audio players for different sounds
var jump_player: AudioStreamPlayer
var hit_player: AudioStreamPlayer
var restart_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var game_over_player: AudioStreamPlayer

# Volume settings
var master_volume: float = 1.0
var is_muted: bool = false

func _ready():
	# Create audio stream players
	jump_player = AudioStreamPlayer.new()
	hit_player = AudioStreamPlayer.new()
	restart_player = AudioStreamPlayer.new()
	click_player = AudioStreamPlayer.new()
	game_over_player = AudioStreamPlayer.new()
	
	# Add them as children
	add_child(jump_player)
	add_child(hit_player)
	add_child(restart_player)
	add_child(click_player)
	add_child(game_over_player)
	
	# Load your audio files (UPDATE THESE PATHS TO MATCH YOUR FILES)
	jump_player.stream = load("res://sound/jump.wav")
	hit_player.stream = load("res://sound/hit.wav")  
	restart_player.stream = load("res://sound/start.wav")
	click_player.stream = load("res://sound/click.wav")
	game_over_player.stream = load("res://sound/over.wav")
	
	# Set initial volumes
	update_volume()

# Play jump sound
func play_jump():
	if not is_muted:
		jump_player.play()

# Play hit sound (faahh)
func play_hit():
	if not is_muted:
		hit_player.play()

# Play restart sound
func play_restart():
	if not is_muted:
		restart_player.play()

# Play click sound
func play_click():
	if not is_muted:
		click_player.play()

# Play game over sound
func play_game_over():
	if not is_muted:
		game_over_player.play()

# Set master volume (0.0 to 1.0)
func set_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	update_volume()

# Toggle mute
func toggle_mute():
	is_muted = !is_muted
	update_volume()

# Set mute state
func set_mute(muted: bool):
	is_muted = muted
	update_volume()

# Update volume for all players
func update_volume():
	var volume_db = linear_to_db(master_volume) if not is_muted else -80.0
	jump_player.volume_db = volume_db
	hit_player.volume_db = volume_db
	restart_player.volume_db = volume_db
	click_player.volume_db = volume_db
	game_over_player.volume_db = volume_db

# Convert linear volume to decibels
func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)
