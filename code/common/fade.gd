extends ColorRect

@export var fade_time : float = 0.5

var is_fading : bool = false
var fade_progress : float = 0.0
var fade_alpha_from : float = 0.0
var fade_alpha_to : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    visible = true
    _set_fade_alpha(1.0)
    fade_in()
    printt("FADE ENABLED:", is_fading)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    #~ printt("FADE ENABLED:", is_fading)
    if is_fading:
        fade_progress = fade_progress + delta / fade_time

        printt("FADE PROGRESS:", fade_progress)

        if fade_progress >= 1.0:
            fade_progress = 1.0
            is_fading = false

        var alpha = lerp(fade_alpha_from, fade_alpha_to, fade_progress)
        _set_fade_alpha(alpha)

func fade_in():
    _fade_to(0.0)

func fade_out():
    _fade_to(1.0)

func _fade_to(alpha: float):
    is_fading = true
    fade_progress = 0.0
    fade_alpha_from = get_modulate().a
    fade_alpha_to = alpha

func _set_fade_alpha(alpha: float):
    var color = get_modulate()
    color.a = alpha
    set_modulate(color)
