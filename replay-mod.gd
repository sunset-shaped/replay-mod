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

var replaying

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
	print(base.menu.connect("end_text", self, "save_replay"))
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
	if replaying:
		player.position = Vector2(loadedpositions_x[ii], loadedpositions_y[ii])
		ii += 1

func save_replay():
	level = base.level
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
	loadedreplay.open("user://replays/" + $OptionButton.get_item_text($OptionButton.get_selected()) + ".ssreplay", File.READ)
	loadedlevel = int(loadedreplay.get_line())
	loadedtimes = parse_json(loadedreplay.get_line())
	loadedpositions_x = parse_json(loadedreplay.get_line())
	loadedpositions_y = parse_json(loadedreplay.get_line())
	self.visible = false
	base._playlevel(loadedlevel)
	replaying = true
