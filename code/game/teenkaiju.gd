class_name TeenKaiju
extends Node2D

@onready var _body = get_parent()


func _ready():
    _body.set_block_input(true)
