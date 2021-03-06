extends "res://TileMapHolder.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal tile_placed
var adjacency_checks = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]
onready var selector_map = $Selector
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func place(node,index=null, start=false):
	if index==null:
		index = tile_map.world_to_map(to_local(node.get_global_position()))
	node.placing(false)
	if tile_map.get_cellv(index)>-1 and !main.map[index.x][index.y] and index==main.target_spot:#(main.tutorial_status==0 or main.tutorial_status==6 or (main.tutorial_status==7 and index==Vector2(1,2)) or (main.tutorial_status!=7 and check_adjacent(index))):
		node.get_parent().remove_child(node)
		node_holder.add_child(node)
		node.set_global_position(tile_map.map_to_world(index)+get_global_position()+tile_map.get_cell_size()/2)
		main.map[index.x][index.y] = node
		node.index = index
		node.state = node.STATES.board
		main.state = main.STATES.placed
		main.check(node,Vector2(index.x,index.y))
		main.merge_player.set_pitch_scale(0.9)
		hand.cards[node.hand_pos] = null
		if globals.sound and !start:
			main.place_player.play()
		emit_signal("tile_placed")
		selector_map.set_cellv(index,-1)
		main.selectors.pop_front()
		if main.selectors.size()>0:
			main.target_spot = main.selectors[0]
			
	else:
		node.move_to(node.origin)
		node.state = node.STATES.hand
		node.flash(false)
		
func check_adjacent(index):
	print(main.map)
	for dir in adjacency_checks:
		var check = index+dir
		if check.y > 3 or check.x > 3:
			continue
		if main.map[check.x][check.y] != null:
			return true
	return false