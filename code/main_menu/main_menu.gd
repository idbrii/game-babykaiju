extends Control

@export var play_button : Button
@export_file("*.tscn") var game_scene

func _ready():
    play_button.connect("pressed", _on_play_pressed)

func _on_play_pressed():
    get_tree().change_scene_to_file(game_scene)
