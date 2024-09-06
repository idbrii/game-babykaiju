extends CharacterBody2D


@export var speed : float = 300.0
@export var anim_sprite : AnimatedSprite2D
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
    play_anim("run")

func retreat():
    is_chasing = false
    is_retreating = true
    $"visual".scale.x = -absf($"visual".scale.x) ## Face left
    play_anim("walk")

func stop():
    is_chasing = false
    is_retreating = false
    play_anim("idle")

func anim_complete():
    return anim_player.animation_finished

func play_anim(anim : StringName):
    anim_sprite.play(anim)

func grow1():
    anim_player.play("Grow1")

func grow2():
    anim_player.play("Grow2")
