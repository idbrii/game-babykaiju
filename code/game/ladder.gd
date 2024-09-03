extends Node2D

@export var ladder_section : PackedScene

@export_range(1, 1000) var ladder_section_height := 32
@export_range(1, 1000) var ladder_section_width := 32
# Extra collision area around ladder for better feel.
@export_range(0, 1) var ladder_width_fudge := 0.2
@export_range(0, 5) var grow_stage_delay_sec := 1.0
@export_range(0, 100) var instagrow := 0
var bottom_pos := Vector2.ZERO


func _ready():
    if instagrow > 0:
        grow(instagrow)

func _create_section():
    var s = ladder_section.instantiate()
    $sections.add_child(s)
    return s

func grow(length):
    var offset = Vector2.DOWN * ladder_section_height
    var shape : RectangleShape2D = $Area2D/CollisionShape2D.shape
    var section_width := ladder_section_width * (1 + ladder_width_fudge)

    for i in length:
        for node in $sections.get_children():
            node.flip_h = not node.flip_h
        var section = _create_section()
        section.flip_h = i % 2 == 0
        section.set_position(bottom_pos)
        bottom_pos += offset
        var shape_size := bottom_pos
        shape_size.x = section_width
        shape.size = shape_size
        var shape_pos := shape_size * 0.5
        shape_pos.x = 0
        $Area2D/CollisionShape2D.position = shape_pos
        if grow_stage_delay_sec > 0:
            await get_tree().create_timer(grow_stage_delay_sec).timeout

