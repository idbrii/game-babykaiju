extends Camera2D

# Camera script following a target (usually the player) between rooms.
# This camera is snapped to a grid, therefore only moves when the character exits a screen.

@export var target : Node2D
@export var align_time : float = 0.2
@export var screen_size := Vector2(1920, 1080)

func _physics_process(_delta: float) -> void:
    if not target:
        _grab_target()
    if not target:
        return

    # Actual movement
    var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
    tween.tween_property(self, "global_position", desired_position(), align_time)

# Calculating the gridsnapped position
func desired_position() -> Vector2:
    return (target.global_position / screen_size).floor() * screen_size + screen_size/2

func _grab_target():
    var players = get_tree().get_nodes_in_group("Player")
    if players:
        target = players[0]
