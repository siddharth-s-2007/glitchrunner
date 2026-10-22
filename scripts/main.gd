extends Node2D

@onready var spawner = $obstaclespawner
@onready var player = $player

func _ready():
	player.died.connect(_on_player_died)

func _on_player_died():
	spawner.stop()
	
