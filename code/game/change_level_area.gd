extends Area2D

@export var level : PackedScene
@export var fade_time : float = 0.5

var changing_level : bool = false
var changing_level_progress : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("body_entered", _player_entered)

func _player_entered(body: Node2D):
    if not body.is_in_group("Player"):
        return

    _transition_to_level(body)


func _transition_to_level(player: Node2D):
    if changing_level:
        return

    changing_level = true
    var fade = get_tree().get_first_node_in_group("Fade")
    fade.set_fade_time(fade_time)
    fade.fade_out()
    fade.connect("fade_completed", _change_level)


    await get_tree().create_timer(0.2).timeout
    player.set_block_input(true)

func _change_level():
    get_tree().change_scene_to_packed(level)
