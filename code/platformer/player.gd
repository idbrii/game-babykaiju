extends CharacterBody2D
## This character controller was created with the intent of being a decent starting point for Platformers.
##
## Instead of teaching the basics, I tried to implement more advanced considerations.
## That's why I call it 'Movement 2'. This is a sequel to learning demos of similar a kind.
## Beyond coyote time and a jump buffer I go through all the things listed in the following video:
## https://www.youtube.com/watch?v=2S3g8CgBG1g
## Except for separate air and ground acceleration, as I don't think it's necessary.

# MIT License. Copyright 2023 TheoTheTorch


signal facing_flipped(should_face_right)


# BASIC MOVEMENT VARIABLES ---------------- #
var face_direction := 1
var _block_input := false

@export_group("Movement")
@export_range(0, 1) var run_threshold: float = 0.8 # set to 0 to disable walk detection
@export_range(10, 1000) var max_walk_speed: float = 200
@export_range(10, 1000) var max_run_speed: float = 560
@export_range(1000, 9000) var acceleration: float = 4032
@export_range(1000, 9000) var turning_acceleration : float = 13440
@export_range(1000, 9000) var drag_deceleration: float = 4480

@export_group("Gravity")
@export var gravity_acceleration : float = 3840
@export var gravity_max : float = 1020

@export_group("Jump Movement")
@export var jump_force : float = 1200
@export var jump_cut : float = 0.4
@export var jump_gravity_max : float = 1000
@export var jump_hang_treshold : float = 2.0
@export var jump_hang_gravity_mult : float = 0.05
# Timers
@export var jump_coyote : float = 0.08
@export var jump_buffer : float = 0.1

@export_group("Push")
@export_range(100, 100000) var push_strength: float = 10000.0

@export_group("Grabbing")
@export var has_feature_grab := true


var _input : Baton
var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false
# ----------------------------------- #

var INPUT_MAP := {
    "gamepad": {
        "controls": {
            "jump":       [JOY_BUTTON_A],
            "grab":       [JOY_BUTTON_X],
            "slow":       [JOY_BUTTON_Y],
            "dash":       [JOY_BUTTON_B],
            "walk_left":  [Baton.JoyAxis(JOY_AXIS_LEFT_X, -1)],
            "walk_right": [Baton.JoyAxis(JOY_AXIS_LEFT_X, 1)],
            "walk_up":    [Baton.JoyAxis(JOY_AXIS_LEFT_Y, -1)],
            "walk_down":  [Baton.JoyAxis(JOY_AXIS_LEFT_Y, 1)],
        },
        "device": 0,
    },
    "keyboard": {
        "controls": {
            "jump":       [KEY_UP, KEY_W, KEY_SPACE],
            "grab":       [KEY_F, KEY_K],
            "slow":       [KEY_SHIFT],
            "dash":       [KEY_J],
            "walk_left":  [KEY_A, KEY_LEFT],
            "walk_right": [KEY_D, KEY_RIGHT],
            "walk_up":    [KEY_W, KEY_UP],
            "walk_down":  [KEY_S, KEY_DOWN],
        },
    },
    "pairs": {
        "horizontal": ["walk_left", "walk_right"],
        "vertical":   ["walk_down", "walk_up"],
    },
    "quads": {
        "move": ["walk_left", "walk_right", "walk_down", "walk_up"],
    },
    "deadzone": 0.5,
}

@onready var sm := StateMachine.create(self, states)


func set_block_input(should_block):
    _block_input = should_block
    if should_block:
        velocity = Vector2.ZERO

# All inputs we want to keep track of
func get_input() -> Dictionary:
    if _block_input:
        return {
            "move": Vector2.ZERO,
            "just_jump": false,
            "jump": false,
            "released_jump": false,
            "walk": false,
            "just_dash": false,
            "hold_dash": false,
            "released_dash": false,
            "just_grab": false,
            "hold_grab": false,
        }
    return {
        "move": _input.get_vector("move"),
        "just_jump": _input.is_action_just_pressed("jump"),
        "jump": _input.is_action_pressed("jump"),
        "released_jump": _input.is_action_just_released("jump"),
        "walk": _input.is_action_pressed("slow"),
        "just_dash": _input.is_action_just_pressed("dash"),
        "hold_dash": _input.is_action_pressed("dash"),
        "released_dash": _input.is_action_just_released("dash"),
        "just_grab": _input.is_action_just_pressed("grab"),
        "hold_grab": _input.is_action_pressed("grab"),
    }


func _ready() -> void:
    if not _input:
        printt("[Player] Creating fallback Baton for player that consumes all inputs.", self)
        # Setup default input for convenient placing of player in test levels. It
        # should normally be overridden on spawn in setup_input.
        _input = Baton.new(INPUT_MAP)
    sm.add_label($ui_root/label_bookmark)
    sm.transition_to(states.freestyle, {})


func setup_input(event: InputEvent):
    _input = Baton.new(Baton.filter_for_input_device(INPUT_MAP, event))


func _physics_process(dt: float) -> void:
    var input = get_input()

    sm.tick(dt)
    _tick_timers(dt)

    var collided := move_and_slide()

    if has_feature_grab:
        var is_reaching = input.hold_grab
        _grab_arms.visible = is_reaching

        if collided:
            if is_reaching and not _held_object:
                for i in get_slide_collision_count():
                    var col = get_slide_collision(i)
                    var body = col.get_collider()
                    if body.is_in_group("pushable"):
                        grab_object(body)
                        break
            else:
                apply_push_to_collisions()

        if _held_object and not is_reaching:
            drop_held_object()
    else:
        if collided:
            apply_push_to_collisions()

func apply_push_to_collisions():
    for i in get_slide_collision_count():
        var col = get_slide_collision(i)
        var body = col.get_collider()
        if body.is_in_group("pushable"):
            var push_force = col.get_normal() * -push_strength
            col.get_collider().apply_force(push_force)


# State Machine {{{1

# basic funcs {{{2
# Can't reference these as vars from another file, so copypasted here.
static func always_true0():
    return true
static func always_true1(_data):
    return true
static func always_false1(_data):
    return false
# }}}

# State Machine Data {{{1
var states := {
    default_state = {
        enter = always_true1,
        update = always_true1,
        exit = always_true1,
        is_supported = always_true0,
    },
    freestyle = {
        enter = _enter_state_freestyle,
        update = _update_state_freestyle,
        exit = always_true1,
        is_supported = _state_is_supported_by_floor,
    },
    climb = {
        enter = _enter_state_climb,
        update = _update_state_climb,
        exit = always_true1,
        is_supported = always_true0,
    },
}

# Freestyle Ground and jump movement {{{1
func _state_is_supported_by_floor():
    return is_on_floor()

func _enter_state_freestyle(_data):
    jump_coyote_timer = 0
    jump_buffer_timer = 0
    is_jumping = false

func _update_state_freestyle(dt):
    var input = get_input()
    if not input.jump and can_climb and abs(input.move.y) > 0:
        sm.transition_to(states.climb, {})
        return
    x_movement(dt)
    dash_logic(dt)
    jump_logic(dt)
    apply_gravity(dt)


func reset_state(state):
    state.should_apply = false
    state.should_abort = false
    return state

func brake_from_drag(dt, state, input, brake_accel):
    if abs(input) <= 0.1 or (state.max_speed > 0 and abs(state.vel) >= state.max_speed):
        # Brake if we're not doing movement inputs or slowing to walk
        state.vel = move_toward(state.vel, 0, brake_accel * dt)
        state.should_apply = true
        state.should_abort = true
    return state

func accelerate_from_input(dt, state, input, fwd_accel, rev_accel):
    var input_follows_momentum_dir = sign(state.vel) == sign(input)

    # If we are doing movement inputs and above max speed, don't accelerate nor
    # decelerate except if we are turning or walking to keep our momentum
    # gained from outside or slopes.
    # TODO: Should this also check not is_walking?
    if abs(state.vel) >= state.max_speed and input_follows_momentum_dir:
        state.should_abort = true
        return

    # Are we turning?
    # Deciding between acceleration and turn_acceleration
    var accel_rate : float = fwd_accel if input_follows_momentum_dir else rev_accel

    # Accelerate
    state.vel += input * accel_rate * dt
    state.should_apply = true
    return state

func x_movement(dt: float) -> void:
    var input = get_input()
    var x_val = input.move.x
    var x_abs = abs(x_val)
    var x_sign = sign(x_val)
    var x_int = int(ceil(x_abs) * x_sign)
    var is_walking = x_abs < run_threshold or input.walk

    var state = reset_state({
        vel = velocity.x,
        max_speed = max_walk_speed if is_walking else 0.0, # 0 is no maximum
    })
    brake_from_drag(dt, state, x_val, drag_deceleration)
    if state.should_apply:
        velocity.x = state.vel
    if state.should_abort:
        return

    reset_state(state)
    state.max_speed = max_run_speed
    if is_dashing():
        # Lets us increase our dash distance by holding a
        # direction during the dash. Good idea?
        state.max_speed = max_dash_speed
    accelerate_from_input(dt, state, x_val, acceleration, turning_acceleration)
    if state.should_apply:
        velocity.x = state.vel
    if state.should_abort:
        return

    set_direction(roundi(x_int)) # This is purely for visuals


func set_direction(hor_direction) -> void:
    # This is purely for visuals
    if hor_direction == 0:
        # No clear direction, so don't change.
        return
    face_direction = hor_direction # remember direction
    facing_flipped.emit(hor_direction > 0)


# Jumping {{{1

func jump_logic(_delta: float) -> bool:
    # Reset our jump requirements
    if sm.current().is_supported.call():
        jump_coyote_timer = jump_coyote
        is_jumping = false
    if get_input().just_jump:
        jump_buffer_timer = jump_buffer

    # Jump if grounded, there is jump input, and we aren't jumping already
    if ticking(jump_coyote_timer) and ticking(jump_buffer_timer) and not is_jumping:
        is_jumping = true
        jump_coyote_timer = 0
        jump_buffer_timer = 0
        # If falling, account for that lost speed
        if velocity.y > 0:
            velocity.y -= velocity.y

        velocity.y = -jump_force

    # We're not actually interested in checking if the player is holding the
    # jump button. We only care about press and release.
    # if get_input().jump:pass

    # Cut the velocity if let go of jump. This means our jumpheight is variable
    # This should only happen when moving upwards, as doing this while falling would lead to
    # The ability to stutter our player mid falling
    if get_input().released_jump and velocity.y < 0:
        velocity.y -= (jump_cut * velocity.y)

    # This way we won't start slowly descending / floating once hit a ceiling
    # The value added to the threshold is arbitrary,
    # But it solves a problem where jumping into
    if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0

    return is_jumping


func apply_gravity(delta: float) -> void:
    var applied_gravity : float = 0

    # No gravity if we are grounded
    if ticking(jump_coyote_timer):
        return

    # Normal gravity limit
    if velocity.y <= gravity_max:
        applied_gravity = gravity_acceleration * delta

    # If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
    if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
        applied_gravity = 0

    # Lower the gravity at the peak of our jump (where velocity is the smallest)
    if is_jumping and abs(velocity.y) < jump_hang_treshold:
        applied_gravity *= jump_hang_gravity_mult

    velocity.y += applied_gravity


func _tick_timers(dt: float) -> void:
    # Using timer nodes here would mean unnecessary functions and node calls
    # This way everything is contained in just 1 script with no node requirements
    jump_coyote_timer -= dt
    jump_buffer_timer -= dt
    dash_cooldown_timer -= dt
    dash_duration_timer -= dt

# Could be static, but don't want the warning.
func expired(timer: float) -> bool:
    return timer <= 0
func ticking(timer: float) -> bool:
    return not expired(timer)


# Dashing {{{1
@export_group("Dash Movement")
# TODO: Tune this in terms of distance instead of speed?
@export_range(10, 1000) var max_dash_speed: float = 860
@export_range(10, 1000) var dash_force : float = 1000
@export_range(1000, 9000) var dash_deceleration: float = 8480
@export_range(0, 10) var dash_cooldown : float = 0.05
@export_range(0, 10) var dash_duration : float = 0.2

var dash_cooldown_timer : float = -1.0
var dash_duration_timer : float = 0
var _is_dashing := false

func is_dashing():
    return _is_dashing

func dash_logic(_dt):
    var input = get_input()
    var was_dashing = _is_dashing
    _is_dashing = _is_dashing and input.hold_dash and not expired(dash_duration_timer)

    if was_dashing and not _is_dashing:
        # Once we stopped dashing, truncate speed to run.
        velocity = velocity.limit_length(max_run_speed)
        dash_duration_timer = 0

    elif input.just_dash and expired(dash_cooldown_timer):
        _is_dashing = true
        dash_duration_timer = dash_duration
        var dir = input.move
        if dir.is_zero_approx():
            dir = velocity
        if dir.is_zero_approx():
            dir = Vector2(face_direction, 0)
        dir = dir.normalized()
        # TODO: Should this set the velocity so dash has a limited distance?
        velocity += dir * dash_force

    # Cooldown starts once dash ends, so never let timer expire during dash.
    if _is_dashing:
        dash_cooldown_timer = dash_cooldown



# Climbing {{{1
@export_group("Climbing")
@export_range(10, 1000) var max_climb_speed: float = 200.0
@export_range(10, 1000) var climb_jump_speed := 500.0

var can_climb := false

func is_climbing():
    return sm.current() == states.climb

func _enter_state_climb(_data):
    # Remove speed so you don't fall off the climb
    velocity = Vector2.ZERO

func _update_state_climb(dt):
    # CONSIDER: Maybe should use coyote time to allow you to keep climbing if
    # you missed a climb?
    if not can_climb:
        sm.transition_to(states.freestyle, {})
        return
    if jump_logic(dt):
        sm.transition_to(states.freestyle, {})
        # Make jumps off of climbs huge because you can't climb horizontally fast.
        # TODO: project onto velocity to prevent huge vertical jumps?
        velocity.x = sign(velocity.x) * climb_jump_speed
        return
    climb_movement(dt)

func set_can_climb(is_allowed):
    can_climb = is_allowed

func climb_movement(dt: float) -> void:
    var input = get_input()

    var x_state = reset_state({
        vel = velocity.x,
        max_speed = max_climb_speed,
    })
    var y_state = reset_state({
        vel = velocity.y,
        max_speed = max_climb_speed,
    })
    brake_from_drag(dt, x_state, input.move.x, drag_deceleration)
    brake_from_drag(dt, y_state, input.move.y, drag_deceleration)
    if x_state.should_apply and y_state.should_apply:
        velocity.x = x_state.vel
        velocity.y = y_state.vel
        return

    reset_state(x_state)
    reset_state(y_state)
    accelerate_from_input(dt, x_state, input.move.x, acceleration, turning_acceleration)
    accelerate_from_input(dt, y_state, input.move.y, acceleration, turning_acceleration)
    if x_state.should_apply:
        velocity.x = x_state.vel
    if y_state.should_apply:
        velocity.y = y_state.vel
    if x_state.should_abort and y_state.should_abort:
        return


# Grabbing {{{1
@onready var _grab_arms := $"%arm_root/grab_arms"
@onready var _hold_marker := $"%arm_root/hold_marker"
var _held_object : RigidBody2D

func grab_object(target):
    drop_held_object()
    _held_object = target
    _held_object.acquire(self)

func drop_held_object():
    if _held_object:
        _held_object.release(self)
    _held_object = null
    _grab_arms.visible = false

func get_hold_marker():
    return _hold_marker
