extends Node

const Player = preload("res://code/platformer/Player.tscn")
const DEFAULT_SPAWN_POS = Vector2(400, 300)

var CHEATS_ENABLED := true

func _input(event: InputEvent):
    if Input.is_action_just_pressed("toggle_full_screen"):
        _swap_fullscreen_mode()
    elif Input.is_action_just_pressed("quit_game"):
        get_tree().quit()
    elif event.is_action_pressed("spawn_player"):
        var spawn_position = DEFAULT_SPAWN_POS

        ## Destroy existing player if there's any
        var players = get_tree().get_nodes_in_group("Player")
        if players and players.size() > 0:
            players[0].queue_free()

        var spawn_points = get_tree().get_nodes_in_group("Spawnpoint")
        if spawn_points and spawn_points.size() > 0:
            spawn_position = spawn_points[0].global_position

        var ui = owner.find_child("WaitingForSpawn")
        if ui:
            ui.visible = false
        var p = Player.instantiate()
        p.setup_input(event)
        get_tree().root.add_child(p)
        p.global_position = spawn_position
    elif CHEATS_ENABLED:
        _cheat_input(event)


func _cheat_input(_event: InputEvent):
    if Input.is_action_just_pressed("cheat_slomo"):
        if Engine.time_scale < 1:
            Engine.time_scale = 1
        else:
            Engine.time_scale = 0.1
    elif Input.is_action_just_pressed("cheat_teleport"):
        var player = get_tree().get_nodes_in_group("Player")[0]
        player.global_position = player.get_global_mouse_position()


func _swap_fullscreen_mode():
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
