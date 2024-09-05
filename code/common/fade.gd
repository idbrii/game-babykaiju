extends ColorRect

@export var fade_time : float = 0.5

var is_fading : bool = false
var fade_progress : float = 0.0
var fade_alpha_from : float = 0.0
var fade_alpha_to : float = 0.0

signal fade_completed

func _ready():
    visible = true
    _set_fade_alpha(1.0)
    fade_in()

func _process(delta):
    #~ printt("FADE ENABLED:", is_fading)
    if is_fading:
        fade_progress = fade_progress + delta / fade_time

        if fade_progress >= 1.0:
            fade_progress = 1.0
            is_fading = false
            fade_completed.emit()

        var alpha = lerp(fade_alpha_from, fade_alpha_to, fade_progress)
        _set_fade_alpha(alpha)

func fade_in():
    _fade_to(0.0)

func fade_out():
    _fade_to(1.0)

func set_fade_time(time: float):
    fade_time = time

func _fade_to(alpha: float):
    is_fading = true
    fade_progress = 0.0
    fade_alpha_from = get_modulate().a
    fade_alpha_to = alpha

func _set_fade_alpha(alpha: float):
    var color = get_modulate()
    color.a = alpha
    set_modulate(color)
