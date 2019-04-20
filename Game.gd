extends Node

var snek_dir = Vector2(-1, 0)
var updated_dir = Vector2(-1, 0)
var snek_body
var meats = []
var eat_meat = []
var time_count = 0
var update_freq = 0.1
var snek_lif = true
var hiss_time = 0
var hisssss = [0, 1]
var show_hiss = false
var map = TileMap.new()

func _ready():
	get_tree().set_screen_stretch(
		get_tree().STRETCH_MODE_VIEWPORT,
		get_tree().STRETCH_ASPECT_KEEP,
		Vector2(64, 64)
	)
	VisualServer.set_default_clear_color(Color('#add972'))
	OS.window_size = Vector2(64, 64)*3
	OS.center_window()
	call_deferred('init_map')

func init_map():
	map.cell_size = Vector2(2, 2)
	get_tree().root.add_child(map)
	map.tile_set = create_tile_ssset()
	call_deferred('sssstart')

func sssstart():
	update_freq = 0.1
	snek_dir = Vector2(-1, 0)
	updated_dir = Vector2(-1, 0)
	meats = []
	eat_meat = []
	snek_body = [map.world_to_map(Vector2(32, 32))]
	map.clear()
	spawn_meat()
	for i in range(5):
		snek_body.append(snek_body[0]-snek_dir*(i+1))
	snek_lif = true
	update_snek_body()

func create_tile_ssset():
	var sheeet = TileSet.new()
	var tex = create_texxxture()
	# hisss0
	sheeet.create_tile(0)
	sheeet.tile_set_texture(0, tex)
	sheeet.tile_set_region(0, Rect2( 0, 0, 2, 2 ))
	# hisss1
	sheeet.create_tile(1)
	sheeet.tile_set_texture(1, tex)
	sheeet.tile_set_region(1, Rect2( 2, 0, 2, 2 ))
	# snekk
	sheeet.create_tile(2)
	sheeet.tile_set_texture(2, tex)
	sheeet.tile_set_region(2, Rect2( 4, 0, 2, 2 ))
	# meet
	sheeet.create_tile(3)
	sheeet.tile_set_texture(3, tex)
	sheeet.tile_set_region(3, Rect2( 6, 0, 2, 2 ))
	return sheeet

func create_texxxture():
	var img = Image.new()
	img.create(8, 2, false, Image.FORMAT_RGBA8)
	var colors = [
		Color(), Color(1,1,1), Color(0,0,0,0),
		Color('#fffa63'), Color('#0f200f'),
		Color('#914348'), Color('#ff636c')
	]
	var data = [
		[0,2,2,0,3,4,5,1],
		[2,0,0,2,4,3,6,5]
	]
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			img.lock()
			img.set_pixel(x, y, colors[data[y][x]])
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex

func _process(delta):
	if snek_lif:
		time_count += delta
		if time_count >= update_freq:
			time_count = 0
			if updated_dir != snek_dir:
				snek_dir = updated_dir
			move_snek()
		
		hiss_time += delta
		if hiss_time >= 1 and not show_hiss:
			show_hiss = true
			hiss_time = 0
		
		if show_hiss and hiss_time >= 0.15:
			hiss_time = 0
			if hisssss[0] == 1:
				show_hiss = false
			hisssss.invert()

func _input(event):
	var next_dir
	if event.is_action_pressed('ui_left'):
		next_dir = Vector2(-1, 0)
	elif event.is_action_pressed('ui_right'):
		next_dir = Vector2(1, 0)
	elif event.is_action_pressed('ui_up'):
		next_dir = Vector2(0, -1)
	elif event.is_action_pressed('ui_down'):
		next_dir = Vector2(0, 1)
	if next_dir != null:
		if next_dir != snek_dir*-1:
			updated_dir = next_dir
	if not snek_lif and event.is_action_pressed('ui_cancel'):
		sssstart()

func move_snek():
	snek_body.push_front(snek_body[0]+snek_dir)
	snek_body.pop_back()
	for m in eat_meat:
		if m == snek_body.back():
			eat_meat.remove(eat_meat.find(m))
			snek_body.append(snek_body[-1]+snek_dir)
			
	if snek_body.count(snek_body[0]) > 1:
		snek_lif = false
	elif snek_body[0].x < 0 or snek_body[0].x > 64/2:
		snek_lif = false
	elif snek_body[0].y < 0 or snek_body[0].y > 64/2:
		snek_lif = false
	elif snek_body[0] in meats:
		update_freq /= 1.05
		meats.remove(meats.find(snek_body[0]))
		eat_meat.append(snek_body[0])
		spawn_meat()
	if snek_lif:
		update_snek_body()

func update_snek_body():
	map.clear()
	for p in snek_body:
		map.set_cellv(p, 2)
	for e in eat_meat:
		map.set_cellv(e, 2, true)
	if show_hiss:
		map.set_cellv(snek_body[0]+snek_dir, hisssss[0])
	for m in meats:
		map.set_cellv(m, 3)

func spawn_meat():
	var m = map.world_to_map(Vector2(64, 64))
	var pos = snek_body[0]
	while pos in snek_body: # XXX
		pos = Vector2(rand_range(0, int(m.x)), rand_range(0, int(m.y))).floor()
	meats.append(pos)
