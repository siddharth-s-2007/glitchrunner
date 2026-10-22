extends CharacterBody2D
var coins = 0
var was_in_air = false
var top_speed = 0.0

const GRAVITY = 800.0
const FALL_GRAVITY = 1200.0
const JUMP_FORCE = -340.0
const JUMP_RELEASE_FORCE = 0.4
const GLITCH_DUR = 3.0

var forward_speed = 120.0
var is_glitching = false
var is_dead = false

signal glitch_started
signal glitch_ended
signal died

func _ready():
	add_to_group("player")
	$AnimatedSprite2D.play("default")
	$glitch.wait_time = GLITCH_DUR
	$glitch.one_shot = true
	$glitch.timeout.connect(_on_glitch_expired)
	up_direction = Vector2.UP
	$CoinDetector.area_entered.connect(_on_coin_detected)


func _physics_process(delta):
	if is_dead:
		return

	# Always move forward
	velocity.x = forward_speed
	top_speed = max(top_speed, forward_speed)

	# Gravity
	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += GRAVITY * delta
		else:
			velocity.y += FALL_GRAVITY * delta

	var target_zoom = clamp(1.0 - (forward_speed - 120.0) / 2000.0, 0.7, 1.0)
	$Camera2D.zoom = $Camera2D.zoom.lerp(Vector2(target_zoom, target_zoom), 0.05)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_RELEASE_FORCE

	# Glitch
	if Input.is_action_just_pressed("glitch") and not is_glitching:
		activate_glitch()

	if not is_on_floor():
		was_in_air = true
	elif was_in_air and is_on_floor():
		was_in_air = false
		forward_speed += 15.0

	if not is_glitching and not is_dead:
		var speed_ratio = clamp((forward_speed - 120.0) / 280.0, 0.0, 1.0)
		modulate = Color(1.0, 1.0 - speed_ratio * 0.3, 1.0 - speed_ratio * 0.3)

	move_and_slide()

func activate_glitch():
	is_glitching = true
	set_collision_layer_value(2, false)
	set_collision_mask_value(3, false)
	modulate = Color(0.3, 1.0, 1.0, 0.6)
	emit_signal("glitch_started")
	$glitch.start()

func _on_glitch_expired():
	is_glitching = false
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)
	modulate = Color(1, 1, 1, 1)
	emit_signal("glitch_ended")

func die():
	if is_dead:
		return
	is_dead = true
	forward_speed = 0.0
	modulate = Color(1.0, 0.2, 0.2, 1.0)
	emit_signal("died")

func _on_coin_detected(area):
	if area.is_in_group("coins"):
		coins += 1
		area.queue_free()
