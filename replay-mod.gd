extends Node2D

var base:Node
var player:Node
var camera:Node
var times = []
var positions = []

var replays = []
var timeDict
var savetime

# Called when the node enters the scene tree for the first time.
func _ready():
	var dir =  Directory.new()
	base = get_node("/root/base")
	base.menu.connect("end_text", self, "save_replay")
	player = base.player
	dir.open("user://")
	if dir.dir_exists("user://replays"):
		dir.change_dir("user://replays")
		#dir.list_dir_begin()
		#while true:
		#	var file = dir.get_next()
		#	if file == "":
		#		break
		#	elif not file.begins_with("."):
		#		if ProjectSettings.load_resource_pack("user://replays/" + file):
		#			replays.append(file.get_basename())
				
		#dir.list_dir_end()
	else:
		dir.make_dir("replays")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if base.state == "play":
		times.append(base.timer)
		positions.append(player.position)

func save_replay():
	print("HAHA YES")
	var replay = File.new()
	timeDict = OS.get_datetime()
	savetime = str(timeDict["hour"] , "-" , timeDict["minute"] , "-" , timeDict["second"] , "--" , timeDict["day"] , "-" , timeDict["month"] , "-" , timeDict["year"])
	replay.open("user://replays/replay" + "-" + savetime, File.WRITE)
	replay.store_line(to_json(times))
	replay.close()
	
