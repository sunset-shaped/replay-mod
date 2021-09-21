extends Node2D

var base:Node
var player:Node
var camera:Node

var times = []
var positions = []
var replays = []
var buttons = []

var timeDict
var savetime
var menushowing

var loadingreplay = File.new()
var f7_key = InputEventKey.new()

# Called when the node enters the scene tree for the first time.
func _ready():
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
		positions.append(player.position)
	if base.menu.visible == true:
		menushowing = true
	else:
		menushowing = false
	if Input.is_action_just_released("replay_menu"):
		if menushowing:
			$open.grab_focus()
			self.visible = true
			base.menu._hideall()

func save_replay():
	print("got to save")
	var replay = File.new()
	print(replay)
	timeDict = OS.get_datetime()
	savetime = str(timeDict["hour"] , "-" , timeDict["minute"] , "-" , timeDict["second"] , "-" , timeDict["day"] , "-" , timeDict["month"] , "-" , timeDict["year"])
	print(savetime)
	replay.open("user://replays/replay" + "-" + savetime + ".ssreplay", File.WRITE)
	replay.store_line(str(times))
	replay.close()
	
