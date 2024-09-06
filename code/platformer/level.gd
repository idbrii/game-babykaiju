extends Node2D

const LevelRequirements = preload("res://levels/level_requirements.tscn")

@export var spawn_with_reqs : PackedScene
@export var spawn_target : Node2D

func _ready() -> void:
    _add_level_requirements_if_not_present()

func _add_level_requirements_if_not_present():
    var reqs = get_tree().get_nodes_in_group("LevelRequirements")
    if not reqs or reqs.size() == 0:
        var req = LevelRequirements.instantiate()
        add_child(req)

        if spawn_with_reqs:
            var spawned = spawn_with_reqs.instantiate()
            spawn_target.add_child(spawned)
            spawned.position = Vector2.ZERO
