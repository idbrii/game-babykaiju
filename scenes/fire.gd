extends Node2D

@export var area : Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
    visible = false
    area.connect("body_entered", _on_body_entered)


func _on_body_entered(body: Node2D):
    if not body.is_in_group("Kaiju"):
        return

    visible = true
    $"AnimatedSprite2D".play()
