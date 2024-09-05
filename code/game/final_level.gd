extends Node2D

var player
@export var player_text: Label
@export var kaiju_text: Label
@export var fixed_speed_camera: Node2D

func _ready():
    _run()

func _run():
    _init_level()

    await _wait(0.1)

    player_text.visible = false
    player = get_tree().get_first_node_in_group("Player")
    player.set_block_input(true)

    await _wait(1)
    _kaiju_say("NOM NOM NOM")

    await _wait(2)
    player.set_direction(-1) ## Face left
    _player_say("Kaiju, what are you doing!?")

    await _wait(2)
    _kaiju_say("NOM NOM NOM")

    await _wait(2)
    _player_say("You have to stop! Please, Kaiju!")

    await _wait(2)
    _kaiju_say("RAAAAARRRR")

    await _wait(2)
    _player_say("")
    player.set_block_input(false)
    fixed_speed_camera.start_moving()



func _init_level():
    ## simulate the spawn_player input so the player is spawned right away
    var spawn_event = InputEventAction.new()
    spawn_event.action = "spawn_player"
    spawn_event.pressed = true
    Input.parse_input_event(spawn_event)

    player_text.visible = false
    kaiju_text.visible = false

    var ui = owner.find_child("WaitingForSpawn")
    if ui:
        ui.visible = false

func _player_say(text: String):
    player_text.visible = true
    player_text.text = text
    kaiju_text.visible = false

func _kaiju_say(text: String):
    kaiju_text.visible = true
    kaiju_text.text = text
    player_text.visible = false

func _wait(seconds: float):
    return get_tree().create_timer(seconds).timeout
