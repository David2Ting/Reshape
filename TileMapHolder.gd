extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var tile_map = $TileMap
onready var node_holder = get_node('../NodeHolder')
onready var main = get_node('/root/Main')
onready var hand = main.get_node('Control/Bottom/Container/Hand')
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	pass
#	if event.is_action_pressed('left_click'):
#		print(tile_map.world_to_map(get_local_mouse_position()))

func place(node,index=null, start=false):
	if index==null:
		index = tile_map.world_to_map(to_local(node.get_global_position()))
	node.placing(false)
	if tile_map.get_cellv(index)>-1 and !main.map[index.x][index.y]:
		node.get_parent().remove_child(node)
		node_holder.add_child(node)
		node.set_global_position(tile_map.map_to_world(index)+get_global_position()+tile_map.get_cell_size()/2)
		main.map[index.x][index.y] = node
		node.index = index
		node.state = node.STATES.board
		main.state = main.STATES.placed
		main.check(node,Vector2(index.x,index.y))
		if !start:
			hand.draw(node.hand_pos)
			main.save_board_state()
		main.change_score(main.check_board_value())
	else:
		node.move_to(node.origin)
		node.state = node.STATES.hand
		
func check_on_map(global_coordinates):
	var index = tile_map.world_to_map(to_local(global_coordinates))
	if tile_map.get_cellv(index)>-1:
		return true
	return false

func coordinates(global_coordinates):
	var index = tile_map.world_to_map(to_local(global_coordinates))
	return index
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
