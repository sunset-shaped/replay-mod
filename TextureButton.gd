extends TextureButton



onready var particles = $Particles2D
onready var text = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_TextureButton_focus_exited()
	

func _on_TextureButton_focus_entered():
	particles.emitting = true
	if !disabled:
		text.modulate = "#FFCDB2"


func _on_TextureButton_focus_exited():
	particles.emitting = false
	if !disabled:
		text.modulate = "#e5989b"
	
func _set(property, value):
	if property == "disabled":
		if value == true:
			text.modulate = "#b89c9d"
		elif value == false:
			text.modulate = "#e5989b"


func _on_TextureButton_pressed():
	release_focus()
