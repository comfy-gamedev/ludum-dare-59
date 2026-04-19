extends Node2D
signal update_train_position(target_pos: Vector2)

const X_SPEED = 100
var moving_right = false
var moving_left = false
var update_train_pos = false

func _process(delta):
	if moving_right:
		var target_pos = Vector2(448.0, position.y)
		
		if update_train_pos:
			update_train_position.emit(target_pos)
			update_train_pos = false
		
		if position.x <= target_pos.x:
			position.x += X_SPEED * delta
		else:
			moving_right = false

func _on_main_gameplay_initiate_middle_to_right_transition():
	await get_tree().create_timer(1.75).timeout
	rotation_degrees += 10
	moving_right = true
	update_train_pos = true


func _on_parallax_background_segment_transition_complete():
	rotation_degrees = 0
