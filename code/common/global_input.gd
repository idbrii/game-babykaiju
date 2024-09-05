extends Node

const Player = preload("res://code/platformer/Player.tscn")
const DEFAULT_SPAWN_POS = Vector2(400, 300)

var CHEATS_ENABLED := true

func _input(event: InputEvent):
    if event.is_action_pressed("toggle_full_screen"):
        get_viewport().set_input_as_handled()
        _swap_fullscreen_mode()
    elif event.is_action_pressed("quit_game"):
        get_viewport().set_input_as_handled()
        get_tree().quit()
    elif event.is_action_pressed("spawn_player"):
        get_viewport().set_input_as_handled()
        var spawn_position = DEFAULT_SPAWN_POS

        ## Destroy existing player if there's any
        var players = get_tree().get_nodes_in_group("Player")
        while players.size() > 0:
            players[0].queue_free()
            players.remove_at(0)

        var spawn_points = get_tree().get_nodes_in_group("Spawnpoint")
        if spawn_points and spawn_points.size() > 0:
            spawn_position = spawn_points[0].global_position

        var ui = $"%Canvas"
        if ui:
            ui.hide_waiting_for_spawn()

        var p = Player.instantiate()
        p.setup_input(event)
        get_tree().root.add_child(p)
        p.global_position = spawn_position
    elif CHEATS_ENABLED:
        _cheat_input(event)


func _cheat_input(event: InputEvent):
    if event.is_action_pressed("cheat_slomo"):
        get_viewport().set_input_as_handled()
        if Engine.time_scale < 1:
            Engine.time_scale = 1
        else:
            Engine.time_scale = 0.1

    elif event.is_action_pressed("cheat_teleport"):
        get_viewport().set_input_as_handled()
        var player = get_tree().get_nodes_in_group("Player")[0]
        player.global_position = player.get_global_mouse_position()


func _swap_fullscreen_mode():
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
