extends Node
@export var coin_scene: PackedScene
@export var coin_y: float = 130.0  # slightly above ground

@export var obstacle_scene: PackedScene
@export var ground_y: float = 148.0
@export var spawn_distance: float = 380.0  # how far ahead of player to spawn

var spawn_timer: float = 0.0
var spawn_interval: float = 2.0
var game_running: bool = true

const SPEED_INCREMENT = 5.0

signal speed_changed(new_speed)

func _process(delta):
	if not game_running:
		return

	var player = get_parent().get_node("player")
	if player == null:
		return

	# Speed up player over time
	if player.forward_speed < 400.0:
		player.forward_speed += (SPEED_INCREMENT + player.forward_speed * 0.03) * delta
		spawn_interval = clamp(2.0 - (player.forward_speed / 150.0) * 0.5, 0.7, 2.0)
		emit_signal("speed_changed", player.forward_speed)

	# Spawn timer
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_obstacle(player.position.x)
		spawn_coin(player.position.x)
func spawn_obstacle(player_x: float):
	if obstacle_scene == null:
		return
	var obs = obstacle_scene.instantiate()
	# Always spawn ahead of player's CURRENT position
	obs.position = Vector2(player_x + spawn_distance, ground_y)
	get_parent().add_child(obs)

func stop():
	game_running = false
func spawn_coin(player_x: float):
	if coin_scene == null:
		return
	var coin = coin_scene.instantiate()
	# Spawn at random distance ahead, slightly offset from obstacles
	var random_offset = randf_range(100.0, 300.0)
	coin.position = Vector2(player_x + spawn_distance + random_offset, coin_y)
	coin.collected.connect(_on_coin_collected)
	get_parent().add_child(coin)

func _on_coin_collected():
	var player = get_parent().get_node("Player")
	player.coins += 1
	print("Coins: ", player.coins)
