class_name FoodCollection
extends Node2D

@export var _final_berry : PackedScene
@export var _berry_spawn : Marker2D

@onready var food_remaining := get_child_count()

func on_eaten(food, _eater):
    food_remaining -= 1
    print("Ate {food}. Remaining: {food_remaining}".format({
        "food": food,
        "food_remaining": food_remaining
    }))
    if food_remaining == 0:
        await get_tree().create_timer(0.5).timeout
        var b = _final_berry.instantiate()
        add_child(b)
        b.global_position = _berry_spawn.global_position
