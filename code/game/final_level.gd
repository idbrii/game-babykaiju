extends Node2D

var player
@export var kaiju_text: Label
@export var fixed_speed_camera: Node2D
@export var kaiju: Node2D

@export var end_area : Area2D

@export var game_over_panel: Control
@export var game_over_retry_button: Button
@export var game_over_quit_button: Button

@export var victory_panel: Control
@export var victory_quit_button: Button

@export var quit_scene: PackedScene

@export var skip_intro : bool = false

func _ready():
    _run()

func _run():
    _init_level()

    await _wait(0.1)

    player = get_tree().get_first_node_in_group("Player")
    player.set_block_input(true)

    kaiju.play_anim("idle")

    if not skip_intro:
        await _wait(1)
        kaiju.play_anim("eat_berry")
        kaiju.grow1()
        _kaiju_say("NOM NOM NOM", 28)

        await _wait(2.1)
        kaiju.play_anim("idle")

        await _wait(0.3)
        player.set_direction(-1) ## Face left
        _player_say("Kaiju, what are you doing!?")

        await _wait(2)
        kaiju.play_anim("eat_berry")
        kaiju.grow2()
        _kaiju_say("NOM NOM NOM", 45, Vector2(50, -200))

        await _wait(2.8)
        kaiju.play_anim("idle")
        _player_say("You have to stop! Please, Kaiju!")

        await _wait(2)
        kaiju.play_anim("roar")
        _kaiju_say("RAAAAARRRR", 60, Vector2(0, -100))

        await _wait(1.5)
        kaiju.play_anim("idle")

        await _wait(0.5)
        _player_say("Kaiju, please! It's me!")

        await _wait(2)
        kaiju.play_anim("roar")
        _kaiju_say("RAAAAAAAAAAAAAAAAAAARRRR", 80, Vector2(0, -50))

        await _wait(2.5)
        kaiju.play_anim("idle")

        await _wait(0.5)
        _player_say("Oh no!")

        await _wait(1)
    else: ## Skip. go straight to max size
        kaiju.grow2()

    _player_say("")
    player.set_block_input(false)
    fixed_speed_camera.start_moving()
    kaiju.start_chasing()


func _init_level():
    ## simulate the spawn_player input so the player is spawned right away
    var spawn_event = InputEventAction.new()
    spawn_event.action = "spawn_player"
    spawn_event.pressed = true
    Input.parse_input_event(spawn_event)

    kaiju_text.visible = false

    var ui = owner.find_child("WaitingForSpawn")
    if ui:
        ui.visible = false

    kaiju.connect("on_catch_player", _on_kaiju_catch_player)

    end_area.connect("body_entered", _on_player_escaped)

func _on_kaiju_catch_player(_p: Node2D):
    player.set_block_input(true)
    fixed_speed_camera.stop_moving()
    _kaiju_say("NOM NOM NOM!", 80)
    kaiju.play_anim("eat")

    player.visible = false ## hide the player. The eat anim has the player in it already

    await _wait(2.2)
    kaiju.play_anim("idle")

    await _wait(1.5)
    kaiju.play_anim("roar")
    _kaiju_say("RAAAAAAAAAAAAAAAAAAARRRR", 80)

    await _wait(1.5)
    kaiju.play_anim("idle")

    await _wait(1.5)

    _kaiju_say("", 80)

    var fade = get_tree().get_first_node_in_group("Fade")
    fade.set_fade_time(2)
    fade.fade_out()

    await _wait(3)

    game_over_panel.visible = true
    game_over_retry_button.connect("pressed", _on_retry_pressed)
    game_over_quit_button.connect("pressed", _on_quit_pressed)

func _on_player_escaped(_p: Node2D):
    if not _p.is_in_group("Kaiju"):
        return

    fixed_speed_camera.stop_moving()

    await _wait(1)

    ## case where the player was eaten after the camera stopped moving
    if not player.visible:
        return

    kaiju.stop()
    player.set_block_input(true)
    ## If the player is too close to the right side of the screen, move him a bit to the left so we can read the text on its head
    if player.get_screen_transform().get_origin().x >= 1850:
        player.global_position = player.global_position - Vector2(120, 0)

    await _wait(1.5)
    kaiju.play_anim("roar")
    _kaiju_say("RAAAAAAAAAAAAAAAAAAARRRR", 80)

    await _wait(2.5)
    kaiju.play_anim("idle")

    await _wait(1.5)
    _kaiju_say("", 80)
    kaiju.retreat()

    player.set_direction(-1) ## Face left

    await _wait(3)
    _player_say("Farewell... my friend.")

    await _wait(5)
    _player_say("")

    var fade = get_tree().get_first_node_in_group("Fade")
    fade.set_fade_time(3)
    fade.fade_out()

    await _wait(5)
    victory_panel.visible = true
    victory_quit_button.connect("pressed", _on_quit_pressed)


func _on_retry_pressed():
    player.queue_free()
    get_tree().reload_current_scene()

func _on_quit_pressed():
    player.queue_free()
    get_tree().change_scene_to_packed(quit_scene)

func _player_say(text: String):
    player.say_text(text)
    kaiju_text.visible = false

func _kaiju_say(text: String, font_size: int, offset: Vector2 = Vector2.ZERO):
    kaiju_text.visible = true
    kaiju_text.text = text
    kaiju_text.add_theme_font_size_override("font_size", font_size)
    kaiju_text.position = kaiju_text.position + offset
    player.say_text("")

func _wait(seconds: float):
    return get_tree().create_timer(seconds).timeout
