extends Node2D

var base:Node
var player:Node
var camera:Node

var level
var times = []
var positions_x = []
var positions_y = []

var replays = []

var loadedlevel
var loadedtimes = []
var loadedpositions_x = []
var loadedpositions_y = []

var ii = 0

var replaying = false
var paused = false
var speed = 1

var loadedreplay = File.new()
var loadingreplay = File.new()
var f7_key = InputEventKey.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	replaying = false
	f7_key.scancode = KEY_F7
	self.visible = false
	InputMap.add_action("replay_menu")
	InputMap.action_add_event("replay_menu", f7_key)
	base = get_node("/root/base")
	base.menu.connect("end_text", self, "save_replay")
	base.menu.connect("mainmenu", self, "end_replay")
	player = base.player
	var dir =  Directory.new()
	dir.open("user://")
	if dir.dir_exists("user://replays"):
		dir.change_dir("user://replays")
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			else:
				loadingreplay.open("user://replays/" + file, File.READ)
				if ".ssreplay" in file:
					replays.append(file)
					loadingreplay.close()
		dir.list_dir_end()
	else:
		dir.make_dir("replays")
	for replay in replays:
		$OptionButton.add_item(str(replay).trim_suffix(".ssreplay"))

func end_replay():
	ii = 0
	replaying = false
	base.set_hud_text("replay1", "")
	base.set_hud_text("replay2", "")
	base.set_hud_text("replay3", "")
	base.player.gravity = 2800
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if base.state == "play":
		times.append(base.timer)
		positions_x.append(player.position.x)
		positions_y.append(player.position.y)
	if Input.is_action_just_released("replay_menu"):
		if base.menu.visible:
			$open.grab_focus()
			self.visible = true
			base.menu._hideall()

func _physics_process(_delta):
	if replaying && base.state == "play" && not paused:
		player.position = Vector2(loadedpositions_x[ii], loadedpositions_y[ii])
		ii = clamp(ii + speed, 0, loadedpositions_x.size() - 1)

func save_replay():
	if base.mode == "level":
		level = base.level
	else:
		level = -1
	var replay = File.new()
	var timeDict = OS.get_datetime()
	var savetime = str(timeDict["hour"] , "-" , timeDict["minute"] , "-" , timeDict["second"] , "-" , timeDict["day"] , "-" , timeDict["month"] , "-" , timeDict["year"])
	replay.open("user://replays/replay" + "-" + savetime + ".ssreplay", File.WRITE)
	replay.store_line(str(level))
	replay.store_line(to_json(times))
	replay.store_line(to_json(positions_x))
	replay.store_line(to_json(positions_y))
	replay.close()

func _on_delete_pressed():
	var dir = Directory.new()
	dir.remove("user://replays/" + $OptionButton.get_item_text($OptionButton.get_selected()) + ".ssreplay")

func _on_open_pressed():
	ii = 0
	if $OptionButton.get_selected() != -1:
		loadedreplay.open("user://replays/" + $OptionButton.get_item_text($OptionButton.get_selected()) + ".ssreplay", File.READ)
		loadedlevel = int(loadedreplay.get_line())
		loadedtimes = parse_json(loadedreplay.get_line())
		loadedpositions_x = parse_json(loadedreplay.get_line())
		loadedpositions_y = parse_json(loadedreplay.get_line())
		self.visible = false
		if loadedlevel == -1:
			base._play()
		else:
			base._playlevel(loadedlevel)
		replaying = true
	base.player.gravity = 0
	base.set_hud_text("replay1", "← and → to skip,")
	base.set_hud_text("replay2", "+ and - to modify speed,")
	base.set_hud_text("replay3", "space to pause and resume")
	$WiggleTimeout.start()

func _input(event):
	if event is InputEventMouseMotion:
		base.set_hud_text("replay1", "← and → to skip,")
		base.set_hud_text("replay2", "+ and - to modify speed,")
		base.set_hud_text("replay3", "space to pause and resume")
		$WiggleTimeout.start()
	if event is InputEventKey and replaying:
		if event.pressed and event.scancode == KEY_RIGHT and !paused:
			ii += 100
		if event.pressed and event.scancode == KEY_LEFT and !paused:
			ii -= 100
		if event.pressed and event.scancode == KEY_SPACE:
			paused = !paused
		if event.pressed and event.scancode == KEY_EQUAL:
			speed = clamp(speed + 1, 1, 5)
		if event.pressed and event.scancode == KEY_MINUS:
			speed = clamp(speed - 1, 1, 5)
		
func _on_WiggleTimeout_timeout():
	base.set_hud_text("replay1", "")
	base.set_hud_text("replay2", "")
	base.set_hud_text("replay3", "")
	
