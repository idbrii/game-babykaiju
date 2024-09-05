class_name Grabbable
extends Node2D

@export_range(0, 10000) var drop_impulse := 10.0
@export_range(0, 10000) var drop_uplift := 5.0

@onready var _body = get_parent()
@onready var original_parent = _body.get_parent()

var is_held := false
var hold_offset := Vector2.ZERO
var target_marker : Node2D


func acquire(holder: PhysicsBody2D):
    is_held = true
    if _body is RigidBody2D:
        _body.freeze = true
    _body.add_collision_exception_with(holder)
    _body.reparent(holder)
    hold_offset = _body.global_position - holder.global_position
    target_marker = holder.get_hold_marker()


func release(holder: PhysicsBody2D):
    is_held = false
    target_marker = null
    _body.remove_collision_exception_with(holder)
    _body.reparent(original_parent)
    if _body is RigidBody2D:
        _body.freeze = false
    await get_tree().process_frame
    var dir = _body.global_position - holder.global_position
    dir.normalized()

    # Boost height to toss higher when jumping.
    var velocity_boost = 1
    if holder.velocity.y < 0:
        velocity_boost = 3

    var forward = dir * drop_impulse
    var uplift = Vector2.UP * drop_uplift * velocity_boost
    var impulse = forward + uplift
    if _body is RigidBody2D:
        _body.apply_central_impulse(impulse)
    elif _body is CharacterBody2D:
        _body.velocity = impulse


func _physics_process(_dt):
    if is_held:
        _body.position = hold_offset
        # TODO: How can we attach them to the arms instead?
        #~ _body.global_position = target_marker.global_position
