class_name Rideable
extends Area2D

@onready var _body : PhysicsBody2D = get_parent()

var _current_rider : PhysicsBody2D
var _is_on_cooldown := false


func _ready():
    self.body_entered.connect(_on_body_entered)


func _on_body_entered(rider):
    if _is_on_cooldown:
        return

    if rider.is_in_group("Player") and not rider.is_in_group("Kaiju"):
        var grab = rider.get_node("Grabbable")
        grab.acquire(_body)
        _current_rider = rider
        _current_rider.started_riding(self)
        _is_on_cooldown = true


func eject(rider):
    assert(rider == _current_rider, "Different rider.")
    _current_rider = null
    var grab = rider.get_node("Grabbable")
    grab.release(_body)
    rider.stopped_riding(self)
    await get_tree().create_timer(1).timeout
    _is_on_cooldown = false


func get_mount_body():
    return _body
