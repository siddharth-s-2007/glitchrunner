extends Control

var blink_timer: float = 0.0

func _process(delta):
	# Blink the "press space" label
	blink_timer += delta
	$VBoxContainer/prompt.modulate.a = abs(sin(blink_timer * 2.5))
	
	# Start game on space
	if Input.is_action_just_pressed("jump"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
