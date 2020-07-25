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

var selectors = []
# Called when the node enters the scene tree for the first time.
func _ready():
	tutorial = true
	pass # Replace with function body.

func start():
	print("test")
	$Control/Header/TutorialLabel.set_text("Welcome to Reshape!")
	animation.play('Fade in')
	yield(animation, 'animation_finished')
	start_tutorial()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_target_spot(new_spot):
	target_spot = new_spot
	tile_map.selector_map.set_cellv(new_spot,2)
	print(new_spot)

func new_selectors(boo):
	if !boo:
		for spot in tile_map.selector_map.get_cellv(2):
			tile_map.selector_map.set_cellv(-1)
	else:
		selectors=boo
		self.target_spot = selectors[0]
func start_tutorial():
	change_text(["The aim of this game is to combine tokens to make bigger tokens","Start by placing the circle token onto the highlighted space"])
	yield(self,"text_change_completed")
	hand.draw_specific(1,1,1)
	self.target_spot=Vector2(2,2)
	yield(tile_map,"tile_placed")
	tutorial_status+=1
	change_text(["When 3 of the same shape are next to each other they merge", "Place the two circles in the highlighted spots on the board"])
	yield(self,"text_change_completed")
	new_selectors([Vector2(2,1),Vector2(1,2)])
	hand.draw_specific(0,1,2)
	hand.draw_specific(2,1,2)
	target_node = [2,2]
	yield(self,"target_node_completed")
	change_text(["The two circles merged into a triangle","They will always merge to the spot of the last placed token", "Placing 3 or more of the same number also merge them","Place these 3 number 1's onto the board"])
	yield(self,"text_change_completed")
	new_selectors([Vector2(2,0),Vector2(2,1),Vector2(1,1)])
	hand.draw_specific(0,1,1)
	hand.draw_specific(1,1,1)
	hand.draw_specific(2,2,1)
	target_node = [2,2]
	yield(self,"target_node_completed")
	change_text(["See how they merged to make a 2","Now make another triangle next to the other two"])
	yield(self,"text_change_completed")
	new_selectors([Vector2(2,2),Vector2(2,3),Vector2(1,3)])
	hand.draw_specific(0,1,1)
	hand.draw_specific(1,1,1)
	hand.draw_specific(2,1,1)
	target_node = [3,3]
	yield(self,"target_node_completed")
	
	change_text(["After creating a triangle the three triangles automatically merged into a square", "What happens if there isn't 3 shapes or numbers during a merge?","Merge these triangles together to try"])
	yield(self,"text_change_completed")
	new_selectors([Vector2(2,3),Vector2(2,2),Vector2(1,2)])
	hand.draw_specific(0,2,1)
	hand.draw_specific(1,2,3)
	hand.draw_specific(2,2,2)
	target_node = [3,3]
	yield(self,"target_node_completed")
	
	change_text(["This makes a square 3 because 3 was the highest number of the merged tiles","Try merging these number 2's now"])
	yield(self,"text_change_completed")
	new_selectors([Vector2(1,0),Vector2(2,0),Vector2(2,1)])
	hand.draw_specific(0,1,2)
	hand.draw_specific(1,2,2)
	hand.draw_specific(2,3,2)
	target_node = [3,3]
	yield(self,"target_node_completed")
	change_text(["This makes a 3 square because the square was the highest shape of the merged tiles","Merging numbers will always make the highest possible number or shape possible and if there's 3 or more upgrade it","Additionally merging more than 3 will still just upgrade it once","For example try merging 4 square's and 3's together"])
	yield(self,"text_change_completed")
	new_selectors([Vector2(1,1)])
	hand.draw_specific(1,3,3)
	target_node = [4,4]
	yield(self,"target_node_completed")
	change_text(["Keep merging nodes and try to get the highest number and shape that you can without filling the board up","Goodluck!"])
	yield(self,"text_change_completed")
#	add_node(Vector2(1,0),2,4)
	globals.tutorial_complete = true
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
		if text[i].length()>100:
			text_timer.set_wait_time(5)
		else:
			text_timer.set_wait_time(2.6)
		text_timer.start()
		if(i==text.size()-1):
			emit_signal("text_change_completed")

		yield(text_timer,"timeout")

func _input(event):
	._input(event)
	if event.is_action_pressed('left_click'):
		text_timer.stop()
		text_timer.emit_signal("timeout")

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
	pass # Replace with function body.
