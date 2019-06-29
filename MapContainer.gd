extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
onready var tile_map = get_node("HighScore")
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func place(node,index=null, start=false):
	if index==null:
		index = tile_map.world_to_map(to_local(node.get_global_position()))
	node.placing(false)
	node.set_position(tile_map.map_to_world(index)+get_global_position()+tile_map.get_cell_size()/2)
	node.index = index
	node.state = node.STATES.board