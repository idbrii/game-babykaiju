extends Node2D


func _ready():
    $Area2D.body_entered.connect(_on_body_entered)


func _on_body_entered(body):
    if body.is_in_group("Player"):
        self.set_deferred("monitoring", false)
        print('Entered door')
        await get_tree().create_timer(0.1).timeout
        body.set_block_input(true)
        $visual.play("opening")
        await $visual.animation_finished
        await get_tree().create_timer(0.5).timeout
        body.hide()
        $visual.play("closing")
        await $visual.animation_finished
        await get_tree().create_timer(0.5).timeout
        Broadcast.completed_level.emit()
