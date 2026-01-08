extends Node2D

const TILE_SOURCE_ID=0
const TILE_SCALE= 4.0

const TILES={
	"t1": Vector2i(1, 2),
	"t2": Vector2i(4, 1),
	"t3": Vector2i(6, 2),
	"web": Vector2i(8, 0)
}

@export var ceilng_y = 150



@export var grnd_y=495

@export var min_gap_sz =191

@export var max_gap_sz= 300
@export var obstcl_spcng = 250

@export var dspwn_dist = -1000



@export var spwn_ahd_dist= 2000

var actv_obstcls = []
var nxt_spwn_x=500

@onready var plyr = get_node_or_null("../player")
@onready var src_lyr= get_node_or_null("../TileMap/towers")


func pick_rndm_twr():
	var kys = ["t1", "t2", "t3"]
	
	
	
	return TILES[kys.pick_random()]


func _ready():
	if plyr:
		nxt_spwn_x = int(plyr.position.x) + 500


func crt_obstcl_node(pos, atlas_crds, rotated, isweb):
	var obs = TileMapLayer.new()
	
	obs.z_index =10
	
	obs.tile_set= src_lyr.tile_set
	obs.scale = Vector2(TILE_SCALE, TILE_SCALE)
	
	obs.position= pos
	
	obs.set_cell(Vector2i(0, 0), TILE_SOURCE_ID, atlas_crds)
	
	if rotated:
		
		obs.rotation_degrees= 180
	
	obs.set_meta("isweb", isweb)
	
	add_child(obs)
	
	actv_obstcls.append(obs)


func _process(_delta):
	if not plyr:
		return
	
	
	
	var plyr_x = plyr.global_position.x
	
	while nxt_spwn_x < plyr_x + spwn_ahd_dist:
		spwn_obstcl_col(nxt_spwn_x)
		nxt_spwn_x += obstcl_spcng
	
	clnup_obstcls(plyr_x)


func spwn_obstcl_col(x_pos):
	if not src_lyr or not src_lyr.tile_set:
		return
	
	
	
	var gap_hgt = randi_range(min_gap_sz, max_gap_sz)
	
	var min_cntr_y = ceilng_y + (gap_hgt / 2.0) + 20
	var max_cntr_y = grnd_y - (gap_hgt / 2.0) - 20
	
	if min_cntr_y > max_cntr_y:
		min_cntr_y = (ceilng_y + grnd_y) / 2.0
		
		max_cntr_y= min_cntr_y
	
	var gap_cntr = randi_range(int(min_cntr_y), int(max_cntr_y))
	
	
	var top_obstcl_y = gap_cntr - (gap_hgt / 2.0)
	var bttm_obstcl_y= gap_cntr + (gap_hgt / 2.0)
	
	var bttm_tile = pick_rndm_twr()
	crt_obstcl_node(Vector2(x_pos, bttm_obstcl_y), bttm_tile, false, false)
	
	var top_tile= Vector2i.ZERO
	var rotated = false
	var isweb= false
	
	if randf() > 0.5:
		
		top_tile = TILES["web"]
		
		rotated = false
		isweb = true
	else:
		top_tile= pick_rndm_twr()
		rotated= true
		
		isweb = false
	
	crt_obstcl_node(Vector2(x_pos, top_obstcl_y), top_tile, rotated, isweb)


func clnup_obstcls(plyr_x):
	var i = actv_obstcls.size() - 1
	
	while i >= 0:
		
		
		
		var obs = actv_obstcls[i]
		
		if obs.global_position.x < plyr_x + dspwn_dist:
			obs.queue_free()
			actv_obstcls.remove_at(i)
		i -= 1


func check_collision(plyr_pos, plyr_sz):
	var chck_rad = 100.0
	
	
	var plyr_rct = Rect2(plyr_pos - plyr_sz/2, plyr_sz).grow(-4.0)
	
	for obs in actv_obstcls:
		if obs.has_meta("isweb") and obs.get_meta("isweb"):
			continue
		
		
		
		if obs.global_position.distance_to(plyr_pos) > chck_rad:
			continue
		
		var tile_wrld_pos = obs.global_position
		
		
		var tile_sz = Vector2(16, 16) * TILE_SCALE
		
		
		var obs_rct = Rect2(tile_wrld_pos, tile_sz)
		
		
		if obs.rotation_degrees == 180:
			obs_rct = Rect2(tile_wrld_pos - tile_sz, tile_sz)
		else:
			
			obs_rct= Rect2(tile_wrld_pos - Vector2(8,8) * TILE_SCALE, tile_sz)
		
		if plyr_rct.intersects(obs_rct):
			return true
	
	return false
