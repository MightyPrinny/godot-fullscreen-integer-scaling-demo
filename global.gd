extends Node

var internal_res
var game_viewport:Viewport
var viewport_sprite:Sprite
var main_viewport_bg:ColorRect

var current_scene_node:Node
var current_scene:PackedScene
var prev_scene:PackedScene
var tree:SceneTree
var root:Viewport

var integer_scaling = true

# Called when the node enters the scene tree for the first time.
func _ready():
	tree = get_tree()
	root = tree.root
	current_scene_node = tree.current_scene
	current_scene = load(tree.current_scene.filename)
	call_deferred("init_game")
	tree.connect("screen_resized",self,"on_screen_resized")
	
func init_game():
	internal_res = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))
	game_viewport = Viewport.new()
	game_viewport.size = internal_res
	root.add_child(game_viewport)
	
	viewport_sprite = Sprite.new()
	viewport_sprite.centered = false
	viewport_sprite.flip_v = true
	root.add_child(viewport_sprite)
	viewport_sprite.texture = game_viewport.get_texture()
	
	main_viewport_bg =  ColorRect.new()
	main_viewport_bg.color = Color(0,0,0)
	root.add_child(main_viewport_bg)
	root.move_child(main_viewport_bg,0)	
	
	on_screen_resized()
	
func on_screen_resized():
	var win_size = root.size
	main_viewport_bg.rect_size = win_size
	var scale_x
	var scale_y
	var scale
	if integer_scaling:
		scale_x = floor(win_size.x / internal_res.x)
		scale_y = floor(win_size.y / internal_res.y)
		scale = max(1, min(scale_x, scale_y))
	else:
		scale_x = win_size.x / internal_res.x
		scale_y = win_size.y / internal_res.y
		scale = max(1, min(scale_x, scale_y))

	var form = game_viewport.global_canvas_transform
	var orig = form.origin
	form = Transform2D.IDENTITY
	form.origin = orig
	form = form.scaled(Vector2(scale,scale))
	game_viewport.global_canvas_transform = form
	game_viewport.size = internal_res*scale
	var diff = (win_size-internal_res*scale).abs()
	var diff_half = (diff*0.5).floor()
	viewport_sprite.position = diff_half
	
func change_scene_to(scene:PackedScene):
	on_scene_end()
	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
	current_scene = scene
	current_scene_node = scene.instance()
	game_viewport.add_child(current_scene_node)
	on_scene_start()
	
func on_scene_end():
	pass
	
func on_scene_start():
	pass

func instance_scene(scene:PackedScene,global_position:Vector2):
	var node = scene.instance()
	node.global_position = global_position
	current_scene_node.add_child(node)
