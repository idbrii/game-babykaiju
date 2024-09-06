extends AnimatedSprite2D

func _ready():
    var max_frame = sprite_frames.get_frame_count(animation)
    play(animation)
    set_frame(randi_range(0, max_frame))
