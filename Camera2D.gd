extends Camera2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var tween = get_node('Tween')
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func to_game():
	tween.interpolate_property(self,'position',get_position(),Vector2(0,0),0.5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	tween.start()

func to_menu():
	print('test')
	tween.interpolate_property(self,'position',get_position(),Vector2(0,-1226.097),0.5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
