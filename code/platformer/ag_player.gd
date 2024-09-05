extends Node2D


@export var player_path : NodePath
@onready var _player := get_node(player_path)
@onready var _scale_animator := $AnimationPlayer
@onready var _sprite_animator := $AnimatedSprite2D
@onready var _sprite_arms := $AnimatedSprite2D/arm_root

@onready var sm := StateMachine.create(self, states)


func _ready() -> void:
    if _player == null:
        # Avoid errors
        print("playersg.gd is missing player_path")
        set_process(false)
    else:
        _player.facing_flipped.connect(_on_facing_flipped)
        #~ sm.add_label($ui_root/label_bookmark)
        sm.transition_to(states.ground_idle, {})


func _on_facing_flipped(should_face_right):
    # No longer using flip_h because we want markers and visible child objects to flip too.
    #~ _sprite_animator.flip_h = not should_face_right
    if should_face_right:
        scale.x = 1
    else:
        scale.x = -1

func _is_falling(vel):
    return vel.y > 0

func _is_soaring(vel):
    return vel.y < 0

func _is_run(vel):
    return vel.x != 0

# wrapper function to allow printing or other debugging
func _play_anim(anim):
    _sprite_animator.play(anim)
func _play_fx(anim):
    _scale_animator.play(anim)


# basic funcs {{{2
# Can't reference these as vars from another file, so copypasted here.
static func always_true1(_data):
    return true
static func always_false1(_data):
    return false
# }}}

var states := {
    default_state = {
        enter = always_true1,
        update = always_true1,
        exit = always_true1,
    },
    ground_idle = {
        enter = _enter_state_ground_idle,
        update = _update_state_ground_idle,
        exit = always_true1,
    },
    ground_run = {
        enter = _enter_state_ground_run,
        update = _update_state_ground_run,
        exit = always_true1,
    },
    climb = {
        enter = _enter_state_climb,
        update = _update_state_climb,
        exit = always_true1,
    },
    jump = {
        enter = _enter_state_jump,
        update = _update_state_jump,
        exit = always_true1,
    },
    fall = {
        enter = _enter_state_fall,
        update = _update_state_fall,
        exit = always_true1,
    },
    land = {
        enter = _enter_state_land,
        update = always_true1,
        exit = always_true1,
    },
    dash = {
        enter = _enter_state_dash,
        update = _update_state_dash,
        exit = always_true1,
    },
}

func _compute_state():
    # Can transition from any state to these based on these conditions. Order
    # is very important.
    if _player.is_climbing():
        return states.climb
    elif _player.is_dashing():
        return states.dash
    elif _is_soaring(_player.velocity):
        return states.jump
    elif _is_falling(_player.velocity):
        return states.fall

func _update_state_generic(_dt):
    var dest = _compute_state()
    if dest and dest != sm.current():
        return sm.transition_to(dest, {})


func _update_state_fall(dt):
    if _player.is_on_floor():
        return sm.transition_to(states.land, {})
    else:
        return _update_state_generic(dt)


func _update_state_jump(dt):
    if _player.is_on_floor():
        return sm.transition_to(states.ground_idle, {})
    elif _is_falling(_player.velocity):
        return sm.transition_to(states.fall, {})
    else:
        return _update_state_generic(dt)


func _update_state_ground_idle(dt):
    if _player.is_on_floor() and _is_run(_player.velocity):
        return sm.transition_to(states.ground_run, {})
    return _update_state_generic(dt)


func _update_state_ground_run(dt):
    if _player.is_on_floor() and not _is_run(_player.velocity):
        return sm.transition_to(states.ground_idle, {})
    return _update_state_generic(dt)


func _update_state_climb(dt):
    if _player.velocity.is_zero_approx():
        _sprite_animator.pause()
    else:
        _sprite_animator.play()

    if _player.is_on_floor():
        return sm.transition_to(states.ground_idle, {})
    return _update_state_generic(dt)


func _update_state_dash(dt):
    if not _player.is_dashing():
        return _update_state_generic(dt)


func _enter_state_climb(_data):
    _play_anim("ladder")

func _enter_state_jump(_data):
    _play_anim("jump")
    _play_fx("Jump")

func _enter_state_fall(_data):
    _play_anim("fall")

func _enter_state_land(_data):
    _play_fx("Land")
    _play_anim("land")
    sm.transition_to(states.ground_idle, {})

func _enter_state_dash(_data):
    _play_anim("dash")

func _enter_state_ground_idle(_data):
    _play_anim("idle")

func _enter_state_ground_run(_data):
    _play_anim("run")


func _process(dt: float) -> void:
    sm.tick(dt)
