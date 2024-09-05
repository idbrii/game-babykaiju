extends Node2D


func _ready():
    _init_level()
    ##await _wait(0)


func _process(delta):
    pass

func _wait(seconds: float):
    return get_tree().create_timer(seconds).timeout

func _init_level():
    ## simulate the spawn_player input so the player is spawned right away
    var spawn_event = InputEventAction.new()
    spawn_event.action = "spawn_player"
    spawn_event.pressed = true
    Input.parse_input_event(spawn_event)

    var player = get_tree().get_first_node_in_group("Player")
