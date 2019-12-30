extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("init")

func init():
	var scene_path = ProjectSettings.get_setting(CustomPlayButtonPlugin.scene_setting)
	if scene_path == "res://Init.tscn" || !ResourceLoader.exists(scene_path,"PackedScene"):
		scene_path = "res://MainScene.tscn"
	Global.change_scene_to(load(scene_path))
