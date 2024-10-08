# MIT License. Copyright 2023 TheoTheTorch

extends CharacterBody2D

@export var rotation_speed : float = 4.0


func _physics_process(delta: float) -> void:
    # Dividing by 2*PI is because 2PI radians is one whole rotation
    rotation += (rotation_speed) / (2*PI) * delta
