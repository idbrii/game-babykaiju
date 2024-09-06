class_name Stomach
extends Node2D

@export var anim : AnimatedSprite2D
@export var replacement_for_self_on_transform : PackedScene
@export_range(1, 20000) var transformation_blast_strength := 10000.0

var eat_count := 0


func eat(food : Edible):
    var should_transform := food.is_transformation_food
    var transform_spawnpoint := food.global_position
    eat_count += 1
    if owner is CharacterBody2D:  # player.gd
        owner.ate_bite()

    # Would be nice to have an effect to replace the food?
    food.queue_free()
    anim.play("eat")
    await anim.animation_finished
    anim.play("eat")
    await anim.animation_finished
    anim.play("idle")
    # no wait because idle loops!

    if should_transform:
        printt("Transforming", owner, "into", replacement_for_self_on_transform)

        # Force everything to drop.
        if owner is CharacterBody2D:
            # If player is riding, drop them.
            owner.drop_held_object()
        var grab = get_parent().get_node("Grabbable")
        if grab:
            grab.force_drop()

        # Blast players away.
        var players = get_tree().get_nodes_in_group("Player")
        for p in players:
            var dir = transform_spawnpoint.direction_to(p.global_position)
            p.velocity = dir * transformation_blast_strength

        var s = replacement_for_self_on_transform.instantiate()
        # TODO: Is there a better parent for players and kaiju?
        var penultimate = get_first_parent_in_group(owner, "Player")
        if not penultimate:
            # Not held, our parent should be good.
            penultimate = owner
        penultimate.get_parent().add_child(s)
        s.global_position = transform_spawnpoint

        owner.queue_free()

func get_first_parent_in_group(node, group_name):
    var p = node.get_parent()
    while p:
        if p.is_in_group(group_name):
            return p
        p = p.get_parent()
    return null
