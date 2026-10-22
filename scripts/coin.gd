extends Area2D

signal collected


func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("coins")
	

	
	
	

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("collected")
		queue_free()  # disappear when collected
