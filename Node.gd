extends Area2D

onready var main = get_node('/root/Main')
onready var sprite = get_node('Holder/Sprite')
onready var label = get_node('Holder/Label')
onready var move_tween = $MoveTween
onready var scale_tween = $ScaleTween
onready var animation = $AnimationPlayer
onready var shadow = get_node('Holder/Shadow')
onready var selector = get_node('Holder/Selector')
onready var highlight = get_node('Holder/Highlight')
onready var outline = get_node('Holder/Outline')
onready var commentary = $CommentPlayer
onready var commentary_label = $CommentaryHolder/Commentary
onready var pop_player = $PopPlayer
var shapes = [null,"res://Images/Shapes/1.png",]
var address = "res://Images/Shapes/3.0/"
var selected = false
var shape = 1
var number = 1
enum STATES{hand,board,placing}
var state = STATES.hand
var origin = Vector2()
var hand_pos = null
var index = Vector2()
var merging = false
#var colours = ['fecd93','13a61d','0977ff','cb2bcd','09cfdb','8509db','fff600','6b4e00','ffffff']
#var colours = ['ffe6c9','92c196','a6cbff','f4c1f5','cf89ff'] design 2.0
var colours = ['cdb383', '92c676','97b7eb','e081eb','99fff5','976fcc','fef07b','fe7b7b','696969']#design 3.0
var outline_colours = ['bbab8e','97aa8c','a4c2c6','e1b1d6','ffffff']
var sizes = [0.8,0.85,0.9,0.95,0.95,0.95,0.95,0.95,0.95,0.95]

var double = ['Nice','Double!','Amazing','Combo!'] 
var triple = ['Awesome','Triple!','Super','Supurb']
var super = ['Extraordinary!','Legendary!','Unbelievable','Spectacular!']
var tutorial = ['Good Job','Well Done']
var comments = [double,triple,super,tutorial]


func _ready():
	init(shape,number)
	pass

func init(shape_num,number_num):
	var max_number = main.max_number
	if shape_num>=max_number:
		shape_num = max_number
	if number_num >=max_number:
		number_num = max_number
	shadow.set_texture(load(address+str(shape_num)+".png"))
	selector.set_texture(load(address+str(shape_num)+".png"))
	sprite.set_texture(load(address+str(shape_num)+".png"))
	sprite.set_modulate(colours[shape_num-1])
	if number_num>=max_number:
		label.set('custom_colors/font_color','7effffff')
#	outline.set_texture(load(address+str(shape_num)+".png"))
#	outline.set("modulate",Color(outline_colours[shape_num-1]))
#	outline.show()
	highlight.set_texture(load(address+str(shape_num)+".png"))
	label.set_text(str(number_num))
	label.set('rect_scale',Vector2(sizes[number_num-1],sizes[number_num-1]))
	if number_num==4:
		label.set('rect_position',Vector2(-67,-66))
	else:
		label.set('rect_position',Vector2(-65,-66))
#	label.set('custom_colors/font_outline_modulate',colours[number_num-1])
#	label.set('custom_colors/font_color',colours[number_num-1])
	shape = shape_num
	number = number_num

func stone():
	pass
#	sprite.set_modulate('ffffff')
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func move_to(pos):
	move_tween.interpolate_property(self,'global_position',get_global_position(),pos,0.04,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	move_tween.start()

func move_to_local(pos):
	move_tween.interpolate_property(self,'position',get_position(),pos,0.04,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	move_tween.start()

func comment(amount):
	if amount>=comments.size():
		amount=comments.size()-1
	commentary_label.set_text(comments[amount][randi()%comments[amount].size()])
	commentary.play('Double')

func comment_end(text):
	commentary_label.set_text(text)
	commentary.play('Double')

func placing(boo):
	if boo:
		shadow.show()
		selector.hide()
		state = STATES.placing
	else:
		shadow.hide()
		if main.selected_card == self:
			main.selected_card = null

func _on_Node_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('left_click') and state == STATES.hand:
		main.selected_card = self
		main.pressed = true
		main.pressed_position = get_global_mouse_position()
	if event.is_action_released('left_click') and state == STATES.hand and main.selected_card == self and !main.select_assist:
		return
		if selected:
			selected(false)
		else:
			selected(true)
	pass # replace with function body

func selected(boo):
	if boo:
		selector.show()
		selected = true
	else:
		selector.hide()
		selected = false
		if main.selected_card == self:
			main.selected_card = null

func flash(boo):
	if boo:
#		animation.play('Flashing')
#		highlight.set('modulate','0046ff')
#		sprite.set('self_modulate','fcf8eb')
		highlight.show()
	else:
#		sprite.set('self_modulate','ffffff')
		highlight.hide()
#		animation.stop()
#		highlight.set('modulate','8f000000')

func pop():
	pop_player.play('Pop')
	yield(pop_player,'animation_finished')
	print('die')
	queue_free()

func merge(obj):
	main.map[index.x][index.y]=null
#	print(index.x, index.y)
	highlight.show()
	merging = true
#	sprite.set_modulate('b2ffffff') #7bffffff
#	sprite.set_texture(load("res://Images/Shapes/2.0/Neutral/"+str(shape)+".png"))
#	sprite.set('self_modulate','d8cdb9')
	scale_tween.interpolate_property(self,'scale',Vector2(1,1),Vector2(0.8,0.8),0.07,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	scale_tween.start()
#	outline.hide()
	yield(scale_tween,'tween_completed')
	label.hide()
	move_tween.interpolate_property(self,'global_position',get_global_position(),obj.get_global_position(),0.2,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	move_tween.start()
	yield(move_tween,'tween_completed')
	queue_free()