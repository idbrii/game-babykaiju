class_name Grabbable
extends Node2D

@export_range(0, 10000) var drop_impulse := 10.0
@export_range(0, 10000) var drop_uplift := 5.0
@export var _facing_node : Node2D

@onready var _body = get_parent()
@onready var original_parent = _body.get_parent()

var is_held := false
var hold_offset := Vector2.ZERO
var target_marker : Node2D
var current_holder : CharacterBody2D


func acquire(holder: PhysicsBody2D):
    is_held = true
    if _body is RigidBody2D:
        _body.freeze = true
    _body.add_collision_exception_with(holder)
    _body.reparent(holder.get_node("%grab_child_marker"))  # drawn before arms
    hold_offset = _body.global_position - holder.global_position
    target_marker = holder.get_hold_marker()
    current_holder = holder


func release(holder: PhysicsBody2D):
    is_held = false
    var facing = current_holder.face_direction
    target_marker = null
    current_holder = null
    _body.reparent(original_parent)
    if _body is RigidBody2D:
        _body.freeze = false
    await get_tree().process_frame

    var throw_impulse = drop_impulse

    var dir : Vector2
    if holder.velocity.length_squared() > 0.1:
        dir = holder.velocity
    else:
        # Not moving, so use facing direction.
        dir = Vector2.RIGHT * facing
        # Less motion when standing
        throw_impulse *= 0.5
    dir = dir.normalized()

    # Boost height to toss higher when jumping.
    var velocity_boost = 1
    if holder.velocity.y < 0:
        velocity_boost = 3

    var forward = dir * throw_impulse
    var uplift = Vector2.UP * drop_uplift * velocity_boost
    var impulse = forward + uplift
    if _body is RigidBody2D:
        _body.apply_central_impulse(impulse)
    elif _body is CharacterBody2D:
        _body.velocity = impulse

    await get_tree().create_timer(0.75).timeout
    _body.remove_collision_exception_with(holder)


func _physics_process(_dt):
    if is_held:
        _body.global_position = target_marker.global_position
        _facing_node.scale.x = current_holder.face_direction
