extends Node2D

const LevelRequirements = preload("res://levels/level_requirements.tscn")

func _ready() -> void:
    _add_level_requirements_if_not_present()

func _add_level_requirements_if_not_present():
    var reqs = get_tree().get_nodes_in_group("LevelRequirements")
    if not reqs or reqs.size() == 0:
        var req = LevelRequirements.instantiate()
        add_child(req)
