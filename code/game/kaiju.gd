extends Node

@onready var animation = $"%AnimatedSprite2D"


func _ready():
    animation.play("idle")
