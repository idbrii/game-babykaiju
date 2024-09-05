class_name Bouncer
extends Area2D

@export_range(0, 10000) var uplift_strength := 1300.0


func _ready():
    self.body_entered.connect(_on_body_entered)


func _on_body_entered(victim):
    if not victim.is_in_group("Kaiju"):
        return
    var body = victim as RigidBody2D
    if not body:
        return
    while overlaps_body(body):
        var impulse = Vector2.UP * uplift_strength
        body.apply_force(impulse)
        await get_tree().process_frame
