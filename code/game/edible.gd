class_name Edible
extends Area2D

@export var is_transformation_food := false


func _ready():
    self.area_entered.connect(_on_area_entered)
    self.body_entered.connect(_on_body_entered)


func _on_area_entered(eater):
    var p = eater.get_parent()
    while p:
        if p.is_in_group("Player"):
            # The player's kaiju grabbing region is near the baby's mouth.
            _try_feed(p)
            return
        p = p.get_parent()


func _on_body_entered(eater):
    _try_feed(eater)


func _try_feed(eater):
    if eater.is_in_group("Player"):
        eater = eater.get_held_body()
    if eater and eater.is_in_group("Kaiju"):
        await get_tree().process_frame
        # Don't allow another eater
        monitoring = false

        var grab = eater.get_node("Stomach")
        get_parent().on_eaten(self, eater)
        grab.eat(self)
