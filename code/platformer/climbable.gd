class_name Climbable
extends Area2D


func _ready():
    self.body_entered.connect(_on_body_entered)
    self.body_exited.connect(_on_body_exited)


func _on_body_entered(body):
    if body.is_in_group("Climber"):
        body.set_can_climb(true)


func _on_body_exited(body):
    if body.is_in_group("Climber"):
        body.set_can_climb(false)
