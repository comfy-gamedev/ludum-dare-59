extends Node2D
signal update_flatbed_position(target_pos: Vector2)

@onready var flatbed_sprite = %Sprite2D
@onready var tile_area = $Area2D

var update_flatbed_pos = false

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
		if update_flatbed_pos:
			update_flatbed_position.emit(new_pos)
			update_flatbed_pos = false
		
		#update_train_position.emit(new_pos)
		
		if moving_direction == "RIGHT":
			if new_pos.x > position.x:
				position.x += Globals.TRAIN_X_SPEED * delta
			else:
				reset_angle()
		elif moving_direction == "LEFT":
			if new_pos.x < position.x:
				position.x -= Globals.TRAIN_X_SPEED * delta
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
		flatbed_sprite.position += offset
	else:
		flatbed_sprite.position = original_sprite_pos

func _on_engine_update_train_position(target_pos: Vector2):
	await get_tree().create_timer(Globals.TRAIN_CAR_DELAY).timeout
	#update_flatbed_position.emit()
	update_flatbed_pos = true
	
	if target_pos.x > position.x:
		moving_direction = "RIGHT"
		rotation_degrees += Globals.TRAIN_ROTATION
	else:
		moving_direction = "LEFT"
		rotation_degrees -= Globals.TRAIN_ROTATION
	
	new_pos = target_pos

func initiate_shimmy():
	_shimmy_timer = shimmy_duration

func _on_shimmy_timer_timeout():
	initiate_shimmy()

func get_tiles():
	var areas : Array[Area2D] = tile_area.get_overlapping_areas()
	return areas.map(func(x): return x.get_parent().grid_pos)
