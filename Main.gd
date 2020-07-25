extends Node

onready var node_holder = get_node("Control/Centre/Container/NodeHolder")
onready var tile_map = get_node("Control/Centre/Container/TileMapHolder")
onready var check_timer = $CheckTimer
onready var check_timer_flash = $CheckTimerFlash
onready var hand = get_node('Control/Bottom/Container/Hand')
onready var score_label = get_node('Control/Header/Score')
onready var score_animation = get_node('Control/Header/ScoreAnimationPlayer')
onready var high_score_label = get_node('Control/Header/HighScoreLabel')
onready var sub_score = get_node('Control/Header/SubScore')
onready var tween = $Tween
onready var animation = $AnimationPlayer
onready var menu = get_node("Menu")
onready var reset_timer = get_node("ResetTimer")
onready var place_player = get_node('Sounds/PlacePlayer')
onready var merge_player = get_node('Sounds/MergePlayer')
onready var reset_label = get_node("Control/Header/Reset/Label")
onready var menu_button = get_node("Control/Header/Menu/Label")
onready var menu_label = get_node("Control/Header/Menu/Label")
onready var menu_player = get_node("Sounds/MenuPlayer")
var pressed = false
var selected_card = null setget change_selected_card
var pressed_position = Vector2()

var map = [[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]]
var adjacency_checks = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]

var check_shape_num = 0
var check_number_num = 0
#var original_node = []

#var shape_nodes = []
#var number_nodes = []
var score = 0 setget change_score
var highest_shape = 3
var highest_number = 3
var high_score = 0 setget change_high_score
var current_high_score = 0
var blank_user_data = {"Highscore":0, "Map":[[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]], "Hand":[null,null,null], "HighestState":[[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]],"Sound":1,"Music":1}
var user_data = {"Highscore":0, "Map":[[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]], "Hand":[null,null,null], "HighestState":[[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]],"Sound":1,"Music":1}
var node_pkd = preload("res://Node.tscn")
var USER_DIR = 'user://User_info.json'

var swiping = false
var swipe_spot = Vector2()

var select_assist = false
enum STATES{checking, placed}
var state = STATES.checking
var previous_check = Vector2(-1,-1)
var max_number = 9
var target_node = [0,0]
signal target_node_completed
signal target_node_failed
var target_spot = null setget change_target_spot
var last_merged_node #from merge
var tutorial = false

var menu_sound = load("res://Sounds/Effects/ToMenu.ogg")
var back_sound = load("res://Sounds/Effects/Back.ogg")

func _ready():
	start()
	yield(get_tree().create_timer(.5), "timeout")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func start():
	randomize()
	load_data()
	menu.load_board_state()

func _process(delta):
	if pressed and selected_card:
		if selected_card.state == selected_card.STATES.hand and abs((hand.get_global_mouse_position()-pressed_position).length())>20:
			selected_card.placing(true)
		elif selected_card.state == selected_card.STATES.placing:
			selected_card.move_to(selected_card.get_global_mouse_position()+Vector2(0,-80))
			var index = tile_map.tile_map.world_to_map(tile_map.to_local(selected_card.get_global_position()))
			if index != previous_check:
				if tile_map.tile_map.get_cellv(index)==0:
#				selected_card.flash(false)
					previous_check = index
					state = STATES.checking
					for tile in tile_map.tile_map.get_used_cells():
						tile_map.tile_map.set_cellv(tile,0)
					if !map[index.x][index.y]:
						tile_map.tile_map.set_cellv(index,1)
						check(selected_card,index,'Flash')
					else:
						if selected_card and !selected_card.merging:
							selected_card.flash(false)
						for child in node_holder.get_children():
							if !child.merging:
								child.flash(false)
				else:
					for tile in tile_map.tile_map.get_used_cells():
						tile_map.tile_map.set_cellv(tile,0)
					if selected_card and !selected_card.merging:
						selected_card.flash(false)
					for child in node_holder.get_children():
						if !child.merging:
							child.flash(false)
					previous_check = null

	elif swiping and pressed:
		if hand.get_global_mouse_position().x-swipe_spot.x > 200:
			print('test')
	
func _input(event):
	if event.is_action_released('left_click'):
		if selected_card and selected_card.state == selected_card.STATES.placing:
			tile_map.place(selected_card)
			for tile in tile_map.tile_map.get_used_cells():
				tile_map.tile_map.set_cellv(tile,0)
		else:
#			if selected_card:
#				selected_card.flash(false)
			for child in node_holder.get_children():
				if !tutorial and !child.merging:
					child.flash(false)
		pressed = false
	if event.is_action_pressed('left_click') and selected_card and tile_map.check_on_map(tile_map.get_global_mouse_position()):
		tile_map.place(selected_card, tile_map.coordinates(tile_map.get_global_mouse_position()))
	if event.is_action_pressed('left_click') and select_assist:
		var third = 600/3.0
		var sector = floor(hand.get_global_mouse_position().x/third)
		var select_card = hand.cards[sector]
		selected_card = select_card
		pressed = true
		pressed_position = hand.get_global_mouse_position()
		select_card.placing(true)
		select_card.set_global_position(hand.get_global_mouse_position())
	elif event.is_action_pressed('left_click'):
		swiping = true
		pressed = true
		swipe_spot = hand.get_global_mouse_position()
	if event.is_action_pressed('right_click'):
		game_over()
#		pressed_position = selected_card.get_global_position()
#		selected_card.set_global_position(selected_card.get_global_mouse_position())
#		selected_card.placing(true)
#		pressed = true

#			selected_card = null


func check(node,index,type=null, shape_nodes=null, number_nodes=null, last_node = null, times = 0, prev_nodes = null):
	if !type or type=='Flash':
		if !type:
#			check_timer.start()
			state = STATES.placed
#		else:
#			check_timer_flash.start()
		check_shape_num = node.shape
		check_number_num = node.number
		var original_node = node
		shape_nodes = [original_node]
		number_nodes = [original_node]
		for direction in adjacency_checks:
			var check = index+direction
			if tile_map.tile_map.get_cellv(index+direction)>-1 and map[check.x][check.y]:
				var check_node = map[check.x][check.y]
				if check_node.shape == check_shape_num and !check_shape_num >= max_number:
					shape_nodes.append(check_node)
					shape_nodes = check(check_node,check,'Shape', shape_nodes, number_nodes, last_node, times)
				if check_node.number == check_number_num and !check_number_num >= max_number:
					number_nodes.append(check_node)
					number_nodes = check(check_node,check,'Number',shape_nodes, number_nodes, last_node, times) 
		if(type=="Flash"):
			if selected_card and !selected_card.merging:
				selected_card.flash(false)
			for child in node_holder.get_children():
				if !child.merging:
					child.flash(false)
			if tutorial:
				var nodes = shape_nodes+number_nodes
				if target_spot == index:
					check_results("Flash",shape_nodes,number_nodes,original_node)
			else:
				check_results("Flash",shape_nodes,number_nodes,original_node)
		else:
			check_timer.start()
			check_results("Merge", shape_nodes, number_nodes, original_node, last_node, times,prev_nodes)
		
	else:
		if type == 'Shape':
			for direction in adjacency_checks:
				var check = index+direction
				if tile_map.tile_map.get_cellv(index+direction)>-1 and map[check.x][check.y]:
					var check_node = map[check.x][check.y]
					if check_node.shape == check_shape_num and shape_nodes.find(check_node)==-1:
						shape_nodes.append(check_node)
						check(check_node,check,'Shape', shape_nodes, number_nodes, last_node, times)
			return shape_nodes
		elif type == 'Number':
			for direction in adjacency_checks:
				var check = index+direction
				if tile_map.tile_map.get_cellv(index+direction)>-1 and map[check.x][check.y]:
					var check_node = map[check.x][check.y]
					if check_node.number == check_number_num and number_nodes.find(check_node)==-1:
						number_nodes.append(check_node)
						check(check_node,check,'Number',shape_nodes, number_nodes, last_node, times)
			return number_nodes
	pass

func check_results(type, shape_nodes, number_nodes, original_node, last_node = null, times=0,prev_nodes=null):
	var max_shape = 0
	var max_num = 0
	var merge = false
	var nodes = []
	var merging_node = null
	var scored = 0
	var nodes_size = 0
	if shape_nodes.size()>=3:
		merge = true
		max_shape = check_shape_num+1
		nodes += shape_nodes
	if number_nodes.size()>=3:
		merge = true
		for node in number_nodes:
			if nodes.find(node)==-1:
				nodes.append(node)
		max_num = check_number_num+1
	nodes_size = nodes.size()
	if merge:
		if type == 'Flash':
			for node in nodes:
				node.flash(true)
		else:
			original_node.merging = true
			for node in nodes:
				node.merging = true
			yield(check_timer,"timeout")
			for node in nodes:
				node.flash(true)
				if node.shape > max_shape:
					max_shape = node.shape
					scored += node.shape
				if node.number > max_num:
					max_num = node.number
				if node != original_node:
					map[node.index.x][node.index.y]=null
					node.merge(original_node)
					merging_node = node
					scored += node.number
			if max_shape>=max_number:
				max_shape = max_number
			if max_num >=max_number:
				max_num = max_number
			original_node.flash(true)
			original_node.shape = int(max_shape)
			original_node.number = int(max_num)
			yield(merging_node.move_tween,'tween_completed')
			merge_player.set_pitch_scale(merge_player.get_pitch_scale()+0.1)
			if globals.sound:
				merge_player.play() 
			print('test!!')
			original_node.init(max_shape,max_num)
			last_merged_node = original_node
			if [max_shape,max_num] == target_node and tutorial:
				original_node.comment(4)
				emit_signal('target_node_completed')
			original_node.merging = false
			original_node.flash(false)
			original_node.animation.stop()
			original_node.animation.play('Add')
			
			state = STATES.checking
			check(original_node,original_node.index,null,null,null,original_node,times+1,nodes_size)
			if max_shape > highest_shape:
				highest_shape = max_shape
			elif max_num > highest_number:
				highest_number = max_num
			hand.check_goal_num()
			change_score(check_board_value())
			if !tutorial:
				save_board_state()
	else:
		if tutorial and type == "Merge":
			var empty = true
			for card in hand.cards:
				if card!=null:
					empty = false
				if empty:
					emit_signal('target_node_failed')
		if original_node.shape >= max_number and original_node.number >= max_number:
			original_node.comment_end('Final\nForm')
		elif original_node.shape >= max_number:
			original_node.comment_end('Final\nShape')
		elif original_node.number >= max_number:
			original_node.comment_end('Final\nNumber')
		else:
			if times > 1:
				original_node.comment(times-2)
			elif prev_nodes and prev_nodes>4:
				original_node.comment(0)
		var count = 0
		for x in range(map.size()):
			for y in range(map[x].size()):
				if !map[x][y]:
					count+=1
					return
		game_over()
func _on_CheckTimer_timeout():
#	check_results('Merge')
	pass # replace with function body
func _on_CheckTimerFlash_timeout():
#	if selected_card:
#		selected_card.flash(false)
#	for child in node_holder.get_children():
#		child.flash(false)
#	check_results('Flash')
	pass # Replace with function body.



func check_board_value():
	var sum = 0
	for x in range(map.size()):
		for y in range(map[0].size()):
			if map[x][y]:
				sum+=(pow(4,map[x][y].shape-1)+pow(4,map[x][y].number-1))#sum+=(pow(3,map[x][y].shape-1)*pow(3,map[x][y].number-1))
	if sum>high_score:
		change_high_score(sum)
		save_data()
	return sum 

func game_over():
	if globals.sound:
		$Sounds/GameOverPlayer.play()
	animation.play("GameOver")
	hand.disappear()
	for x in range(map.size()):
		for y in range(map[0].size()):
			user_data["Map"][x][y]=null
	for i in range(hand.cards.size()):
		user_data["Hand"][i] = null
	save_data()
func change_score(new_score):
	score = new_score
	if str(score).length()>5:
		score_label.set('rect_scale',Vector2(0.9,0.9))
	else:
		score_label.set('rect_scale',Vector2(1,1))
	if score == current_high_score:
		sub_score.hide()
	elif score > current_high_score:
		current_high_score = score
		sub_score.hide()
		score_animation.play('Score')
		score_label.set_text(str(new_score))
	elif score < current_high_score:
		score_animation.play('UnderScore')
		sub_score.show()
		sub_score.set_text(str(new_score))
	if score >= high_score:
		save_high_state()

func change_high_score(new_score):
	high_score = new_score
	user_data['Highscore'] = new_score
#	score_animation.play('Score')
	high_score_label.set_text(str(new_score))

func save_board_state():
	for x in range(map.size()):
		for y in range(map[0].size()):
			if map[x][y]:
				user_data["Map"][x][y]=[map[x][y].shape,map[x][y].number]
			else:
				user_data["Map"][x][y]=null
	for i in range(hand.cards.size()):
		if hand.cards[i]:
			user_data["Hand"][i] = [hand.cards[i].shape,hand.cards[i].number]
	save_data()

func save_high_state():
	for x in range(map.size()):
		for y in range(map[0].size()):
			if map[x][y]:
				user_data["HighestState"][x][y]=[map[x][y].shape,map[x][y].number]
			else:
				user_data["HighestState"][x][y]=null
	save_data()

func load_board_state():
	var data_map = user_data["Map"]
	for x in range(map.size()):
		for y in range(map[0].size()):
			if data_map[x][y]:
				var node_instance = node_pkd.instance()
				hand.add_child(node_instance)
				node_instance.init(data_map[x][y][0], data_map[x][y][1])
				if data_map[x][y][0] > highest_shape:
					highest_shape = data_map[x][y][0]
				if data_map[x][y][1] > highest_number:
					highest_number = data_map[x][y][1]
				tile_map.place(node_instance,Vector2(x,y), true)
	for x in range(user_data["Hand"].size()):
		if user_data["Hand"][x]:
			print('test')
			hand.draw(x,user_data["Hand"][x])
		else:
			print('1')
			hand.draw(x)

func save_data():
	var save_file = File.new()
	save_file.open(USER_DIR, File.WRITE)
	save_file.store_line(to_json(user_data))
	save_file.close()

func load_data():
	var load_file = File.new()
	if load_file.open(USER_DIR, File.READ)==0:
		var raw_user_data = parse_json(load_file.get_as_text())
		for key in raw_user_data:
			user_data[key]=raw_user_data[key]
		change_high_score(user_data['Highscore'])
		load_board_state()
		load_settings()
		load_file.close()
	else:
		load_file.open(USER_DIR, File.WRITE)
		load_file.store_line(to_json(blank_user_data))
		load_board_state()
		load_file.close()
	if user_data['Highscore'] == 0 and !globals.tutorial_complete:
		get_tree().change_scene("res://Tutorial.tscn")

func load_settings():
	menu.sound_button.change_state(user_data['Sound'])
	menu.music_button.change_state(user_data['Music'])

func to_tutorial():
	tween.interpolate_property($Menu,'modulate',Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,'tween_completed')
	get_tree().change_scene("res://Tutorial.tscn")
	
func to_menu():
	tween.interpolate_property($Control,'modulate',Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,'tween_completed')
	get_tree().change_scene("res://Main.tscn")

func change_selected_card(new_card):
	selected_card = new_card
	for card in hand.cards:
		if card and card != new_card:
			card.selected(false)
	


func _on_Reset_pressed():
	menu_player.stream = back_sound
	menu_player.play()
	hand.disappear()
	print(blank_user_data["Map"])
	user_data["Map"]=[[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]]
	user_data["Hand"]=[null,null,null]
	save_data()
	animation.play('UnGameOver')
	map =  [[null,null,null,null],[null,null,null,null],[null,null,null,null],[null,null,null,null]]
	highest_shape = 3
	highest_number = 3
	hand.previous_shape = 0
	hand.previous_number = 0
	hand.previous_shape_count = 0
	hand.previous_number_count = 0
	var children = node_holder.get_children()
	for node in children:
		node.pop()
	reset_timer.start()
	current_high_score = -1
	self.score = 0
	yield(reset_timer,'timeout')
	print('start')
	load_board_state()
	pass # replace with function body


func _on_MenuButton_pressed():
	menu_player.stream = menu_sound
	menu_player.play()
	menu.load_board_state()
	$Camera2D.to_menu()
	pass # Replace with function body.


func _on_Reset_button_down():
	reset_label.set('custom_colors/font_color','c4c4c4')


func _on_Reset_button_up():
	reset_label.set('custom_colors/font_color','9c9c9c')


func _on_MenuButton_button_down():
	menu_button.set_modulate('ffffff')
	pass # Replace with function body.


func _on_MenuButton_button_up():
	menu_button.set_modulate('fff5e5')
	pass # Replace with function body.

func change_target_spot(new_spot):
	pass

func _on_Menu_pressed():
	menu_player.stream = menu_sound
	menu_player.play()
	menu.load_board_state()
	$Camera2D.to_menu()
	pass # Replace with function body.


func _on_Menu_button_down():
	menu_label.set('custom_colors/font_color','c4c4c4')
	pass # Replace with function body.


func _on_Menu_button_up():
	menu_label.set('custom_colors/font_color','9c9c9c')
	pass # Replace with function body.
