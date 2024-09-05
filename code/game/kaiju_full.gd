extends CharacterBody2D


@export var speed : float = 300.0
@export var anim_player : AnimationPlayer

var is_chasing : bool = false


func _physics_process(delta):
    if not is_chasing:
        return

    velocity.x = speed

    move_and_slide()

func start_chasing():
    is_chasing = true

func grow1():
    anim_player.play("Grow1")

func grow2():
    anim_player.play("Grow2")
