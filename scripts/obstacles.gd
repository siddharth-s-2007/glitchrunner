extends CharacterBody2D
var speed = 100.0
func _physics_process(delta):
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var body = col.get_collider()
		if body.name == "Player" and not body.is_glitching:
			body.die()

	
	velocity = Vector2(-speed, 0)

	move_and_slide()
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var body = col.get_collider()
		if body.name == "player" and not body.is_glitching:
			body.die()
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
