extends Node2D

@export var ceiling_y = 150
@export var ground_y = 495
@export var min_gap_size = 191
@export var max_gap_size = 300
@export var obstacle_spacing = 250
@export var despawn_distance = -1000
@export var spawn_ahead_distance = 2000

const TILE_SOURCE_ID = 0
const TILE_SCALE = 4.0

const TILES = {
	"tower1": Vector2i(1, 2),
	"tower2": Vector2i(4, 1),
	"tower3": Vector2i(6, 2),
	"web": Vector2i(8, 0)
}

var active_obstacles = []
var next_spawn_x = 500

@onready var player = get_node_or_null("../player")
@onready var source_layer = get_node_or_null("../TileMap/towers")

func _ready():
	if player:
		next_spawn_x = int(player.position.x) + 500

func _process(_delta):
	if not player:
		return
	
	var player_x = player.global_position.x
	
	while next_spawn_x < player_x + spawn_ahead_distance:
		spawn_obstacle_column(next_spawn_x)
		next_spawn_x += obstacle_spacing
	
	cleanup_obstacles(player_x)

func spawn_obstacle_column(x_pos):
	if not source_layer or not source_layer.tile_set:
		return
	
	var gap_height = randi_range(min_gap_size, max_gap_size)
	
	var min_center_y = ceiling_y + (gap_height / 2.0) + 20
	var max_center_y = ground_y - (gap_height / 2.0) - 20
	
	if min_center_y > max_center_y:
		min_center_y = (ceiling_y + ground_y) / 2.0
		max_center_y = min_center_y
	
	var gap_center = randi_range(int(min_center_y), int(max_center_y))
	
	var top_obstacle_y = gap_center - (gap_height / 2.0)
	var bottom_obstacle_y = gap_center + (gap_height / 2.0)
	
	var bottom_tile = pick_random_tower()
	create_obstacle_node(Vector2(x_pos, bottom_obstacle_y), bottom_tile, false, false)
	
	var top_tile = Vector2i.ZERO
	var is_rotated = false
	var is_web = false
	
	if randf() > 0.5:
		top_tile = TILES["web"]
		is_rotated = false
		is_web = true
	else:
		top_tile = pick_random_tower()
		is_rotated = true
		is_web = false
	
	create_obstacle_node(Vector2(x_pos, top_obstacle_y), top_tile, is_rotated, is_web)

func create_obstacle_node(pos, atlas_coords, rotated, is_web):
	var obs = TileMapLayer.new()
	
	obs.z_index = 10
	obs.tile_set = source_layer.tile_set
	obs.scale = Vector2(TILE_SCALE, TILE_SCALE)
	obs.position = pos
	
	obs.set_cell(Vector2i(0, 0), TILE_SOURCE_ID, atlas_coords)
	
	if rotated:
		obs.rotation_degrees = 180
	
	obs.set_meta("is_web", is_web)
	
	add_child(obs)
	active_obstacles.append(obs)

func cleanup_obstacles(player_x):
	var i = active_obstacles.size() - 1
	while i >= 0:
		var obs = active_obstacles[i]
		if obs.global_position.x < player_x + despawn_distance:
			obs.queue_free()
			active_obstacles.remove_at(i)
		i -= 1

func check_collision(player_pos, player_size):
	var check_radius = 100.0
	var player_rect = Rect2(player_pos - player_size/2, player_size).grow(-4.0)
	
	for obs in active_obstacles:
		if obs.has_meta("is_web") and obs.get_meta("is_web"):
			continue
		
		if obs.global_position.distance_to(player_pos) > check_radius:
			continue
		
		var tile_world_pos = obs.global_position
		var tile_size = Vector2(16, 16) * TILE_SCALE
		
		var obs_rect = Rect2(tile_world_pos, tile_size)
		if obs.rotation_degrees == 180:
			obs_rect = Rect2(tile_world_pos - tile_size, tile_size)
		else:
			obs_rect = Rect2(tile_world_pos - Vector2(8,8) * TILE_SCALE, tile_size)
		
		if player_rect.intersects(obs_rect):
			return true
	
	return false

func pick_random_tower():
	var keys = ["tower1", "tower2", "tower3"]
	return TILES[keys.pick_random()]
