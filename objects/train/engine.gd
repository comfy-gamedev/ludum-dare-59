extends Node2D
signal update_train_position(target_pos: Vector2, train_direction: Globals.TrainDirections)
signal initiate_train_move

var death_explosion_scene = preload("res://objects/vfx/death_explosion/death_explosion.tscn")

@onready var engine_sprite = %Sprite2D
@onready var tile_area = $Area2D

var moving_right = false
var moving_left = false
var moving_down = false
var moving_up = false
var update_train_pos = false
var target_pos = Vector2(0, 0)

var shimmy_duration: float = 0.25
var shimmy_intensity: float = 0.25
var _shimmy_timer: float = 0.0
var original_sprite_pos: Vector2

var max_health = 10
var health = max_health

const TARGET_RIGHT_X_POS = 384.0
const TARGET_LEFT_X_POS = 128.0
const TARGET_MIDDLE_X_POS = 256.0

const TARGET_DEATH_Y_POS = 2000.0

func _ready() -> void:
	original_sprite_pos = engine_sprite.position

func _process(delta):
	process_shimmy(delta)
	process_movement(delta)

func process_movement(delta):
	if moving_right:
		if update_train_pos:
			update_train_position.emit(target_pos, Globals.TrainDirections.RIGHT)
			update_train_pos = false
		
		if position.x <= target_pos.x:
			position.x += Globals.TRAIN_X_SPEED * delta
			#current_pos = position
		else:
			rotation_degrees = 0
			moving_right = false
	
	if moving_left:
		if update_train_pos:
			update_train_position.emit(target_pos, Globals.TrainDirections.LEFT)
			update_train_pos = false
		
		if position.x >= target_pos.x:
			position.x -= Globals.TRAIN_X_SPEED * delta
			#current_pos = position
		else:
			rotation_degrees = 0
			moving_left = false
	
	if moving_down:
		if update_train_pos:
			update_train_position.emit(target_pos, Globals.TrainDirections.DOWN)
			update_train_pos = false
		
		if position.y <= target_pos.y:
			position.y += Globals.TRAIN_Y_SPEED * delta
			#current_pos = position
		else:
			#rotation_degrees = 0
			moving_down = false

func process_shimmy(delta):
	if _shimmy_timer > 0.0:
		_shimmy_timer -= delta
		var offset = Vector2(
			randf_range(-shimmy_intensity, shimmy_intensity),
			randf_range(-shimmy_intensity, shimmy_intensity)
		)
		engine_sprite.position += offset
	else:
		engine_sprite.position = original_sprite_pos

func initiate_shimmy():
	_shimmy_timer = shimmy_duration

func _on_parallax_background_segment_transition_complete():
	#rotation_degrees = 0
	pass

func _on_shimmy_timer_timeout():
	initiate_shimmy()

func _on_main_gameplay_initiate_middle_to_right_transition():
	#await get_tree().create_timer(1.5).timeout
	await initiate_train_move
	await get_tree().create_timer(Globals.TRAIN_TURN_DELAY).timeout
	target_pos = Vector2(TARGET_RIGHT_X_POS, position.y)
	rotation_degrees += Globals.TRAIN_ROTATION
	moving_right = true
	update_train_pos = true

func _on_main_gameplay_initiate_middle_to_left_transition():
	#await get_tree().create_timer(0.75).timeout
	await initiate_train_move
	await get_tree().create_timer(Globals.TRAIN_TURN_DELAY).timeout
	target_pos = Vector2(TARGET_LEFT_X_POS, position.y)
	moving_left = true
	update_train_pos = true
	rotation_degrees -= Globals.TRAIN_ROTATION

func _on_main_gameplay_initiate_left_to_middle_transition():
	#await get_tree().create_timer(1.5).timeout
	await initiate_train_move
	await get_tree().create_timer(Globals.TRAIN_TURN_DELAY).timeout
	target_pos = Vector2(TARGET_MIDDLE_X_POS, position.y)
	moving_right = true
	update_train_pos = true
	rotation_degrees += Globals.TRAIN_ROTATION

func _on_main_gameplay_initiate_right_to_middle_transition():
	await initiate_train_move
	await get_tree().create_timer(Globals.TRAIN_TURN_DELAY).timeout
	target_pos = Vector2(TARGET_MIDDLE_X_POS, position.y)
	rotation_degrees -= Globals.TRAIN_ROTATION
	moving_left = true
	update_train_pos = true

func _on_parallax_background_segment_transition_initiated():
	initiate_train_move.emit()

func get_tiles():
	var areas : Array[Area2D] = tile_area.get_overlapping_areas()
	return areas.map(func(x): return x.get_parent().grid_pos)
	
func initiate_death_sequence():
	#death_initiated = true
	#$sfx/death_noise.play()
	#$DeathInitiatedTimer.start()
	$ExplosionAddedTimer.start()
	#enable_input = false

#func _on_death_initiated_timer_timeout():
	#SaveGame.reload()
	#get_tree().change_scene_to_file(game_over_scene)
#
#func _on_explosion_added_timer_timeout():
	#var death_explosion: Node2D = death_explosion_scene.instantiate()
	#death_explosion.position.x += randf_range(-20, 20)
	#death_explosion.position.y += randf_range(-20, 20)
	#death_explosion.play("default")
	#$DeathExplosions.add_child(death_explosion)

func _on_explosion_added_timer_timeout():
	var death_explosion: Node2D = death_explosion_scene.instantiate()
	death_explosion.position.x += randf_range(-20, 20)
	death_explosion.position.y += randf_range(-20, 20)
	#death_explosion.play("default")
	$DeathExplosions.add_child(death_explosion)


func _on_main_gameplay_initiate_train_death():
	#await initiate_train_move
	#await get_tree().create_timer(0.34).timeout
	initiate_death_sequence()
	target_pos = Vector2(position.x, TARGET_DEATH_Y_POS)
	#rotation_degrees += Globals.TRAIN_ROTATION
	moving_down = true
	update_train_pos = true

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		initiate_death_sequence()
