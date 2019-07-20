extends Node2D

var spawn_points = [-170,0,170]
var cards = [null,null,null]
var node_pkd = preload("res://Node.tscn")
onready var tween = $Tween
var goal_num = 3
var previous_nodes = [Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0)]
var previous_shape = 0
var previous_number = 0
var previous_shape_count = 0
var previous_number_count = 0
onready var main = get_node('/root/Main')
func _ready():
	randomize()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func draw(i,start=null):
	var node_instance = node_pkd.instance()
	node_instance.set_position(Vector2(spawn_points[i],300))
	add_child(node_instance)
	if start:
		node_instance.init(start[0],start[1])
	else:
		cards[i] = null
		var random_num = random_num()
		node_instance.init(random_num.x,random_num.y)
	node_instance.origin = to_global(Vector2(spawn_points[i],0))
	node_instance.hand_pos = i
	cards[i]=node_instance
	tween.interpolate_property(node_instance,'position',node_instance.get_position(),Vector2(spawn_points[i],0),0.5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	tween.start()

func draw_specific(i,shape,number):
	var node_instance = node_pkd.instance()
	node_instance.set_position(Vector2(spawn_points[i],300))
	add_child(node_instance)
	node_instance.init(shape,number)
	node_instance.origin = to_global(Vector2(spawn_points[i],0))
	node_instance.hand_pos = i
	cards[i]=node_instance
	tween.interpolate_property(node_instance,'position',node_instance.get_position(),Vector2(spawn_points[i],0),0.5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	tween.start()

func random_num():
	var card_shape = -1
	var card_number = -1		
	
	var black_list_shape = []
	var black_list_number = []

	if previous_shape_count > 1:
		black_list_shape.append(previous_shape)
	if previous_number_count > 1:
		black_list_number.append(previous_number)

	var shape_num
	var number_num
	while(!shape_num or (black_list_shape.find(shape_num)>-1 or black_list_number.find(number_num)>-1)):
		var rand_goal_num = round(rand_range(goal_num-1,goal_num+1)) 
		shape_num = randi()%int((min(int(rand_goal_num-1),int(main.highest_shape-1))))+1
		number_num = int(clamp(rand_goal_num-shape_num,1,main.highest_number-1))
		print(shape_num)
		print(black_list_shape.find(1))
	if previous_shape == shape_num:
		previous_shape_count+=1
	else:
		previous_shape = shape_num
		previous_shape_count = 1
	if previous_number == number_num:
		previous_number_count+=1
	else:
		previous_number = number_num
		previous_number_count = 1
	return Vector2(shape_num,number_num)

func check_goal_num():
	var new_goal_num = (main.highest_shape+main.highest_number)/3
	if new_goal_num > goal_num:
		goal_num = new_goal_num