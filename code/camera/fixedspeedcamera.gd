extends Camera2D

@export var area : Area2D
@export var speed : float = 100

var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
    area.connect("body_entered", _player_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if moving:
        position = position + Vector2(speed * delta, 0)

func _player_entered(body: Node2D):
    if not body.is_in_group("Player"):
        return

    make_current()
    moving = true
