extends Node2D

const X_SPEED = 100
var new_pos = null
var moving_direction = "NONE" # | "RIGHT" | "LEFT" | "DOWN" | "UP"

func _process(delta):
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

func _on_engine_update_train_position(target_pos: Vector2):
	await get_tree().create_timer(0.1).timeout
	
	if target_pos.x > position.x:
		moving_direction = "RIGHT"
		rotation_degrees += 10
	else:
		moving_direction = "LEFT"
		rotation_degrees -= 10
	
	new_pos = target_pos
