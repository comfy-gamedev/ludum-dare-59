extends Node2D

const X_SPEED = 100
var new_pos = null
var moving_direction = "RIGHT" # | "LEFT" | "DOWN" | "UP"

func _process(delta):
	if new_pos != null:
		if moving_direction == "RIGHT":
			if new_pos.x > position.x:
				position.x += X_SPEED * delta
		elif moving_direction == "LEFT":
			if new_pos.x < position.y:
				position.x += X_SPEED * delta

func _on_engine_update_train_position(target_pos: Vector2):
	if target_pos.x > position.x:
		moving_direction = "RIGHT"
	else:
		moving_direction = "LEFT"
	
	await get_tree().create_timer(0.05).timeout
	new_pos = target_pos
