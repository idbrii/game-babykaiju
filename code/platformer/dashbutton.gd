extends Area2D

signal on_hit(btn)


@export var activate_direction := Vector2.RIGHT
@export var anim : AnimatedSprite2D
@export_range(0, 10) var hold_pressed_duration := 0.3

var has_waited_for_unpress := false

func _ready():
    self.body_entered.connect(_on_body_entered)
    self.body_exited.connect(_on_body_exited)
    activate_direction = activate_direction.normalized()


var presser
func _on_body_entered(body):
    if body.is_in_group("Player"):
        var character := body as CharacterBody2D
        if character.is_dashing() and _matches_activate_direction(character.velocity):
            presser = character
            has_waited_for_unpress = false
            self.on_hit.emit(self)
            anim.frame = 1

            await get_tree().create_timer(hold_pressed_duration).timeout
            has_waited_for_unpress = true
            if not presser:
                anim.frame = 0


func _on_body_exited(body):
    if body == presser:
        presser = null
        if has_waited_for_unpress:
            anim.frame = 0


func _matches_activate_direction(v):
    return absf(v.normalized().dot(activate_direction)) > 0.1
