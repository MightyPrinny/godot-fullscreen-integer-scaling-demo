tool
extends EditorPlugin
class_name CustomPlayButtonPlugin

var custom_play_button
const scene_setting = "application/run/custom_first_scene"
var old_play_button
var main_play_button

func set_start_scene(scene_path:String):
	if !ProjectSettings.has_setting(scene_setting):
		var pinfo =  {
			"name": "application/run/custom_first_scene",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "scene to load when the game starts"
		}
		ProjectSettings.add_property_info(pinfo)
	ProjectSettings.set_setting("application/run/custom_first_scene",scene_path)
	ProjectSettings.save()
	
func _enter_tree():
	var interface = get_editor_interface().get_base_control()
	var buttons = []
	var play_icon = interface.get_icon("PlayScene","EditorIcons")
	var main_play_icon = interface.get_icon("MainPlay","EditorIcons")
	fetch_potential_play_buttons(interface,buttons)
	var i = 0

	for butt in buttons:
		var b = butt as ToolButton
		if b.icon == main_play_icon:
			i+=1
			main_play_button = butt
		elif b.icon == play_icon:
			old_play_button = b
			b.hide()
	if i == 1:
		custom_play_button = ToolButton.new()
		custom_play_button.icon = play_icon
		custom_play_button.modulate.b = 1.5
		custom_play_button.focus_mode = Control.FOCUS_NONE
		custom_play_button.toggle_mode = false

		var prt = main_play_button.get_parent()
		prt.add_child(custom_play_button)
		var play_signal = main_play_button.get_meta("play_signal")
		custom_play_button.connect("pressed",play_signal["target"],"_menu_option",play_signal["binds"])
		custom_play_button.connect("pressed",self,"play_scene_pressed")
		if !main_play_button.is_connected("pressed",self,"play_game_pressed"):
			main_play_button.connect("pressed",self,"play_game_pressed")
		
func play_game_pressed():
	set_start_scene("")

func play_scene_pressed():
	set_start_scene(get_editor_interface().get_edited_scene_root().filename)

func fetch_potential_play_buttons(node,butt):
	for c in node.get_children():
		if c is ToolButton:
			var connection_list = c.get_signal_connection_list("pressed")
			for s in connection_list:
				if s["method"] == "_menu_option":
					butt.append(c)
					c.set_meta("play_signal",s)
		fetch_potential_play_buttons(c,butt)

func _exit_tree():
	if is_instance_valid(custom_play_button):
		custom_play_button.queue_free()
	if is_instance_valid(old_play_button):
		old_play_button.show()
	if main_play_button.is_connected("pressed",self,"play_game_pressed"):
		main_play_button.disconnect("pressed",self,"play_game_pressed")
