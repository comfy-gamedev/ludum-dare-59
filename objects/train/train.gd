extends Sprite2D

const X_SPEED = 100
var moving_right = false
var moving_left = false

func _process(delta):
	if moving_right:
		await get_tree().create_timer(1.15).timeout
		
		if position.x <= 448.0:
			position.x += X_SPEED * delta
		else:
			moving_right = false

func _on_main_gameplay_initiate_middle_to_right_transition():
	moving_right = true
