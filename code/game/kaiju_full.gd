extends CharacterBody2D


@export var speed : float = 300.0
@export var anim_player : AnimationPlayer

signal on_catch_player

var is_chasing : bool = false
var is_retreating : bool = false

func _ready():
    pass


func _physics_process(delta):
    if not is_chasing and not is_retreating:
        return

    if is_chasing:
        velocity.x = speed
    else:
        velocity.x = -speed

    move_and_slide()

    if is_chasing:
        var cols = get_slide_collision_count()

        for i in cols:
            var obj = get_slide_collision(i)
            var col = obj.get_collider()

            if col.is_in_group("Player"):
                _on_catch_player(col)

func _on_catch_player(player: Node2D):
    is_chasing = false
    on_catch_player.emit(player)


func start_chasing():
    is_chasing = true

func retreat():
    is_chasing = false
    is_retreating = true

func stop():
    is_chasing = false
    is_retreating = false


func grow1():
    anim_player.play("Grow1")

func grow2():
    anim_player.play("Grow2")
