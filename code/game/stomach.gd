class_name Stomach
extends Node2D

@export var anim : AnimatedSprite2D

var eat_count := 0


func eat(food : Edible):
    eat_count += 1
    # Would be nice to have an effect to replace the food?
    food.queue_free()
    anim.play("eat")
    await anim.animation_finished
    anim.play("eat")
    await anim.animation_finished
    anim.play("idle")
