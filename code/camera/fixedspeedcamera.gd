extends Camera2D

@export var speed : float = 100

var moving = false

func _ready():
    make_current()

func start_moving():
    moving = true

func stop_moving():
    moving = false

func _process(delta):
    if moving:
        position = position + Vector2(speed * delta, 0)
