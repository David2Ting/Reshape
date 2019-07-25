extends "res://Main.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal text_change_completed
onready var tutorial_label = $Control/Header/TutorialLabel
onready var tutorial_tween = $Control/Header/TutorialLabel/Tween
onready var text_timer = $TextTimer
onready var text_pause = $TextPause
var tutorial_status = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	tutorial = true
	pass # Replace with function body.

func start():
	print("test")
	$Control/Header/TutorialLabel.set_text("Place a tile on the board")
	animation.play('Fade in')
	yield(animation, 'animation_finished')
	start_tutorial()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_tutorial():
	hand.draw_specific(1,1,1)
	yield(tile_map,"tile_placed")
	tutorial_status+=1
	change_text(["Placing 3 or more of the same shape next to each other merges them together", "Place the two circles adjacent to the circle you just placed on the board"])
	yield(self,"text_change_completed")
	hand.draw_specific(0,1,2)
	hand.draw_specific(2,1,2)
	target_node = [2,2]
	yield(self,"target_node_completed")
	change_text(["Combining 3 triangles together will make a square", "Place the two triangles adjacent to the triangle you just made"])
	yield(self,"text_change_completed")
	hand.draw_specific(0,2,1)
	hand.draw_specific(2,2,1)
	target_node = [3,2]
	yield(self,"target_node_completed")
	
	change_text(["You can also combine three of the same numbers to make a higher number", "Join the 3 number 2's together"])
	yield(self,"text_change_completed")
	hand.draw_specific(0,1,2)
	hand.draw_specific(2,1,2)
	target_node = [3,3]
	yield(self,"target_node_completed")
	
	change_text(["Remember numbers always merge to the spot where you placed the last tile","Try making a number 4 pentagon now"])
	yield(self,"text_change_completed")
	hand.draw_specific(0,3,3)
	hand.draw_specific(2,3,3)
	target_node = [4,4]
	yield(self,"target_node_completed")
	change_text(["Merging numbers will always make the highest possible number or shape possible","Try merging these shapes together and see what number you get"])
	yield(self,"text_change_completed")
	hand.draw_specific(0,4,1)
	hand.draw_specific(2,4,2)
	target_node = [5,4]
	yield(self,"target_node_completed")
	change_text(["Merging more than three of a type will still only upgrade it once","Merge all these nodes together into one"])
	yield(self,"text_change_completed")
	tutorial_status = 6
	map[last_merged_node.index.x][last_merged_node.index.y]=null
	last_merged_node.queue_free()
	add_node(Vector2(1,0),2,4)
	add_node(Vector2(1,1),3,4)
	add_node(Vector2(1,3),4,4)
	add_node(Vector2(0,2),5,3)
	add_node(Vector2(2,2),5,2)
	add_node(Vector2(3,2),5,1)
	hand.draw_specific(1,5,4)
	tutorial_status = 7
	target_node = [6,5]
	yield(self,"target_node_completed")
	change_text(["Well done! Tutorial Complete!","The aim of the game is to try and make a number 9 decagon","Try to get as high a score as you can before you run out of board space","Goodluck!",""])
	yield(self,"text_change_completed")
	get_tree().change_scene("res://Main.tscn")
func change_text(text):
	text_pause.start()
	yield(text_pause,"timeout")
	for i in range(text.size()):
		var label = text[i]
		tutorial_tween.interpolate_property(tutorial_label,'modulate',Color(1,1,1,1),Color(1,1,1,0),0.4,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tutorial_tween.start()
		yield(tutorial_tween,'tween_completed')
		text_pause.start()
		yield(text_pause,"timeout")
		tutorial_label.set_text(label)
		tutorial_tween.interpolate_property(tutorial_label,'modulate',Color(1,1,1,0),Color(1,1,1,1),0.4,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tutorial_tween.start()
		text_timer.start()
		if(i==text.size()-1):
			emit_signal("text_change_completed")
		yield(text_timer,"timeout")

func add_node(index,shape_num,number_num):
	var node = node_pkd.instance()
	hand.add_child(node)
	node.hand_pos = 0
	node.init(shape_num,number_num)
	tile_map.place(node,index,true)
	node.animation.play("Add")

func save_data():
	pass

func _on_Main_target_node_failed():
	print("failed")
	pass # Replace with function body.
