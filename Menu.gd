extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var main = get_node("/root/Main")
onready var map_container = get_node("Control/Mid/MidContainer/MapContainer")
onready var high_score_label = get_node('Control/Mid/HighScoreLabel')
onready var highscore_container = get_node("Control/Mid/MidContainer/MapContainer/HighScore")
onready var tutorial_label = get_node("Control/Options/TutorialButton/Label")

onready var sound_button = get_node('Control/Options/Sound_button')
onready var music_button = get_node('Control/Options/Music_button')
onready var menu_button = get_node("Control/Header/MenuButton")
var node_pkd = preload("res://Node.tscn")

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_board_state():
	for child in highscore_container.get_children():
		child.queue_free()
	var data_map = main.user_data["HighestState"]
	var data_score = main.user_data["Highscore"]
	for x in range(data_map.size()):
		for y in range(data_map[0].size()):
			if data_map[x][y]:
				var node_instance = node_pkd.instance()
				map_container.get_node('HighScore').add_child(node_instance)
				node_instance.init(data_map[x][y][0], data_map[x][y][1])
				map_container.place(node_instance,Vector2(x,y), true)
				node_instance.stone()
	high_score_label.set_text(str(data_score))
func _on_TextureButton_pressed():
	main.menu_player.stream = main.back_sound
	main.menu_player.play()
	get_node("/root/Main/Camera2D").to_game()
	pass # Replace with function body.




func _on_TutorialButton_pressed():
	main.menu_player.stream = main.back_sound
	main.menu_player.play()
	main.to_tutorial()
	pass # Replace with function body.


func _on_TutorialButton_button_down():
	tutorial_label.set_modulate('6cffffff')
	pass # Replace with function body.


func _on_TutorialButton_button_up():
	tutorial_label.set_modulate('ffffff')
	pass # Replace with function body.



func _on_MenuButton_button_down():
	menu_button.set_modulate('ffffff')
	pass # Replace with function body.


func _on_MenuButton_button_up():
	menu_button.set_modulate('fff5e5')
	pass # Replace with function body.


func _on_Menu_pressed():
	main.menu_player.stream = main.back_sound
	main.menu_player.play()
	get_node("/root/Main/Camera2D").to_game()
	pass # Replace with function body.
