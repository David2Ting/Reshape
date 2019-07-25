extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var state = 1 setget change_state
onready var sprite = $Sprite
onready var option_label = $Option
var on_texture = preload("res://Images/Ui/On.png")
var off_texture = preload("res://Images/Ui/Off.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(state)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_state(new_state):
	state = new_state
	if new_state:
		option_label.set_text('On')
	else:
		option_label.set_text('Off')
func _on_Music_button_pressed():
	if state:
		change_state(0)
	else:
		change_state(1)
	pass # Replace with function body.


func _on_Music_button_button_down():
	option_label.set_modulate('d3d3d3')
	pass # Replace with function body.
func _on_Music_button_button_up():
	option_label.set_modulate('8a8a8a')
