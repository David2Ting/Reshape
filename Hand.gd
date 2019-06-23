extends Node2D

var spawn_points = [-170,0,170]
var cards = [null,null,null]
var node_pkd = preload("res://Node.tscn")
onready var tween = $Tween
var goal_num = 3
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
		var random_num = random_num()
		node_instance.init(random_num.x,random_num.y)
	node_instance.origin = to_global(Vector2(spawn_points[i],0))
	node_instance.hand_pos = i
	cards[i]=node_instance
	tween.interpolate_property(node_instance,'position',node_instance.get_position(),Vector2(spawn_points[i],0),0.5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	tween.start()

func random_num():
	var rand_goal_num = round(rand_range(goal_num-1,goal_num+1)) 
	var shape_num = randi()%int((min(int(rand_goal_num-1),int(main.highest_shape-1))))+1
	var number_num = int(clamp(rand_goal_num-shape_num,1,main.highest_number-1))
	return Vector2(shape_num,number_num)

func check_goal_num():
	var new_goal_num = (main.highest_shape+main.highest_number)/3
	if new_goal_num > goal_num:
		goal_num = new_goal_num