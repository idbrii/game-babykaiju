extends RigidBody2D

@export_range(0, 10000) var drop_impulse := 10.0
@export_range(0, 10000) var drop_uplift := 5.0

@onready var original_parent = get_parent()

var is_held := false
var hold_offset := Vector2.ZERO
var target_marker : Node2D


func acquire(holder: PhysicsBody2D):
    is_held = true
    freeze = true
    add_collision_exception_with(holder)
    reparent(holder)
    hold_offset = global_position - holder.global_position
    target_marker = holder.get_hold_marker()


func release(holder: PhysicsBody2D):
    is_held = false
    target_marker = null
    remove_collision_exception_with(holder)
    reparent(original_parent)
    freeze = false
    await get_tree().process_frame
    var dir = global_position - holder.global_position
    dir.normalized()

    # Boost height to toss higher when jumping.
    var velocity_boost = 1
    if holder.velocity.y < 0:
        velocity_boost = 3

    var forward = dir * drop_impulse
    var uplift = Vector2.UP * drop_uplift * velocity_boost
    apply_central_impulse(forward + uplift)


func _physics_process(_dt):
    if is_held:
        position = hold_offset
        # TODO: How can we attach them to the arms instead?
        #~ global_position = target_marker.global_position
