extends Node2D

@export var text : String = "Hello"
@export var duration : float = 3
@export var area : Area2D

var has_been_triggered : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
    visible = false
    area.connect("body_entered", _on_body_entered)


func _on_body_entered(body: Node2D):
    if not body.is_in_group("Player") and not body.is_in_group("Kaiju"):
        return

    if has_been_triggered:
        return

    has_been_triggered = true
    var player = get_tree().get_first_node_in_group("Player")
    player.say_text(text)

    await get_tree().create_timer(duration).timeout
    player.say_text("")
