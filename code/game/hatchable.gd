class_name Hatchable
extends Area2D

const KaijuBaby = preload("res://scenes/kaiju_baby.tscn")

@export var throw_power := 1500.0
@onready var _sprite_animator := $AnimatedSprite2D
@onready var _fx := $AnimatedSprite2D/fx


func _ready():
    self.body_entered.connect(_on_body_entered)


func _on_body_entered(toucher):
    if not toucher.is_in_group("Player"):
        return

    toucher.set_block_input(true)

    await get_tree().process_frame
    monitoring = false

    _fx.visible = true
    _fx.reparent(owner.get_parent())

    _fx.play("hatchfx")
    _sprite_animator.play("hatch")
    await get_tree().create_timer(0.2).timeout
    _fx.play("hatchfx")
    await _sprite_animator.animation_finished

    visible = false
    var baby = KaijuBaby.instantiate()
    toucher.get_parent().add_child(baby)
    baby.add_collision_exception_with(toucher)
    baby.global_position = global_position

    await get_tree().create_timer(0.5).timeout

    var throw = global_position.direction_to($ThrowMarker.global_position) * throw_power
    baby.apply_central_impulse(throw)

    await get_tree().create_timer(1).timeout

    toucher.set_block_input(false)
    baby.remove_collision_exception_with(toucher)
    queue_free()
