extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var main = get_node("/root/Main")
onready var map = get_node("Control/Mid/MapContainer/HighScore")
onready var map_container = get_node("Control/Mid/MapContainer")
onready var high_score_label = get_node('Control/Mid/HighScoreLabel')
var node_pkd = preload("res://Node.tscn")

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_board_state():
	var data_map = main.user_data["HighestState"]
	var data_score = main.user_data["Highscore"]
	for x in range(data_map.size()):
		for y in range(data_map[0].size()):
			if data_map[x][y]:
				print('test')
				var node_instance = node_pkd.instance()
				map_container.get_node('HighScore').add_child(node_instance)
				node_instance.init(data_map[x][y][0], data_map[x][y][1])
				map_container.place(node_instance,Vector2(x,y), true)
	high_score_label.set_text("Highscore\n"+str(data_score))
func _on_TextureButton_pressed():
	get_node("/root/Main/Camera2D").to_game()
	pass # Replace with function body.




func _on_TutorialButton_pressed():
	main.to_tutorial()
	pass # Replace with function body.
