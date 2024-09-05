extends Control

@export var play_button : Button
@export var game_scene : PackedScene

func _ready():
    play_button.connect("pressed", _on_play_pressed)

func _on_play_pressed():
    get_tree().change_scene_to_packed(game_scene)
