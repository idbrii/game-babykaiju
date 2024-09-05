class_name Stomach
extends Node2D

@export var anim : AnimatedSprite2D

var eat_count := 0


func eat(food : Edible):
    eat_count += 1
    anim.play("eat")
    await anim.animation_finished
    food.queue_free()
    anim.play("eat")
    await anim.animation_finished
    anim.play("idle")
