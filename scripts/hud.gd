extends CanvasLayer

@onready var coin_label = $CoinLabel
@onready var speed_bar = $SpeedBar
@onready var speed_label = $SpeedLabel
@onready var glitch_label = $GlitchLabel
@onready var hints_panel = $HintsPanel
@onready var game_over_panel = $GameOverPanel
@onready var coins_result = $GameOverPanel/VBoxContainer/CoinsResult
@onready var speed_result = $GameOverPanel/VBoxContainer/SpeedResult
@onready var restart_btn = $GameOverPanel/VBoxContainer/RestartBtn

var player: CharacterBody2D
var hints_timer: float = 0.0
const HINTS_DURATION: float = 5.0

func _ready():
	game_over_panel.hide()
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: Player not found!")
		return
	player.glitch_started.connect(_on_glitch_started)
	player.glitch_ended.connect(_on_glitch_ended)
	player.died.connect(_on_player_died)
	restart_btn.pressed.connect(_on_restart_pressed)

func _process(delta):
	if player == null:
		return
	if player.is_dead:
		return

	coin_label.text = "🪙 %d" % player.coins
	speed_bar.value = player.forward_speed
	speed_label.text = "SPEED  %d" % int(player.forward_speed)

	var ratio = player.forward_speed / 400.0
	speed_label.modulate = Color(1.0, 1.0 - ratio * 0.8, 1.0 - ratio * 0.8)

	if hints_timer < HINTS_DURATION:
		hints_timer += delta
		hints_panel.modulate.a = clamp((1.0 - hints_timer / HINTS_DURATION) * 3.0, 0.0, 1.0)
	else:
		hints_panel.hide()

func _on_glitch_started():
	glitch_label.text = "⚡ GLITCHING!"
	glitch_label.modulate = Color(0.0, 1.0, 1.0)

func _on_glitch_ended():
	glitch_label.text = "⚡ GLITCH READY"
	glitch_label.modulate = Color(1, 1, 1)

func _on_player_died():
	
	await get_tree().create_timer(0.6).timeout
	coins_result.text = "🪙 COINS:  %d" % player.coins
	speed_result.text = "⚡ TOP SPEED:  %d" % int(player.top_speed)
	game_over_panel.show()
	restart_btn.grab_focus()
	
func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
