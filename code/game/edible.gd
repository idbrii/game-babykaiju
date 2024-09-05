class_name Edible
extends Area2D


func _ready():
    self.body_entered.connect(_on_body_entered)


func _on_body_entered(eater):
    if eater.is_in_group("Kaiju"):
        var grab = eater.get_node("Stomach")
        grab.eat(self)
        await get_tree().process_frame
        # Don't allow another eater
        monitoring = false

