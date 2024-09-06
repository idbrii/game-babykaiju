extends Control

@export var play_button : Button
@export_file("*.tscn") var game_scene

func _ready():
    play_button.connect("pressed", _on_play_pressed)
    play_button.call_deferred("grab_focus")

func _on_play_pressed():
    get_tree().change_scene_to_file(game_scene)


func _input(event: InputEvent):
    if event.is_action_pressed("spawn_player"):
        get_viewport().set_input_as_handled()
        _on_play_pressed()
