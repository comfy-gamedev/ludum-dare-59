extends Node2D

@onready var caboose_sprite = %Sprite2D

const X_SPEED = 100
var new_pos = null
var moving_direction = "NONE" # | "RIGHT" | "LEFT" | "DOWN" ? | "UP" ?

var shimmy_duration: float = 0.25
var shimmy_intensity: float = 0.25
var _shimmy_timer: float = 0.0
var original_sprite_pos: Vector2

func _process(delta):
	process_shimmy(delta)
	process_follow_movement(delta)

func process_follow_movement(delta):
	if new_pos != null:
		if moving_direction == "RIGHT":
			if new_pos.x > position.x:
				position.x += X_SPEED * delta
			else:
				reset_angle()
		elif moving_direction == "LEFT":
			if new_pos.x < position.y:
				position.x += X_SPEED * delta
			else:
				reset_angle()

func reset_angle():
	if moving_direction != "NONE":
		moving_direction = "NONE"
		rotation_degrees = 0

func process_shimmy(delta):
	if _shimmy_timer > 0.0:
		_shimmy_timer -= delta
		var offset = Vector2(
			randf_range(-shimmy_intensity, shimmy_intensity),
			randf_range(-shimmy_intensity, shimmy_intensity)
		)
		caboose_sprite.position += offset
	else:
		caboose_sprite.position = original_sprite_pos

func _on_engine_update_train_position(target_pos: Vector2):
	await get_tree().create_timer(0.1).timeout
	
	if target_pos.x > position.x:
		moving_direction = "RIGHT"
		rotation_degrees += 10
	else:
		moving_direction = "LEFT"
		rotation_degrees -= 10
	
	new_pos = target_pos

func initiate_shimmy():
	_shimmy_timer = shimmy_duration

func _on_shimmy_timer_timeout():
	initiate_shimmy()
