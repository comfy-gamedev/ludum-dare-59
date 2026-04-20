extends Node2D

@onready var caboose_sprite = %Sprite2D
@onready var tile_area = $Area2D

var new_pos = null
var moving_direction = "NONE" # | "RIGHT" | "LEFT" | "DOWN" ? | "UP" ?

var shimmy_duration: float = 0.25
var shimmy_intensity: float = 0.25
var _shimmy_timer: float = 0.0
var original_sprite_pos: Vector2

var max_health = 10
var health = max_health

var death_explosion_scene = preload("res://objects/vfx/death_explosion/death_explosion.tscn")

func _ready():
	original_sprite_pos = caboose_sprite.position
	#initiate_death_sequence()

func _process(delta):
	process_shimmy(delta)
	process_follow_movement(delta)

func process_follow_movement(delta):
	if new_pos != null:
		match moving_direction:
			"RIGHT":
				if new_pos.x > position.x:
					position.x += Globals.TRAIN_X_SPEED * delta
				else:
					reset_angle()
			"LEFT":
				if new_pos.x < position.x:
					position.x -= Globals.TRAIN_X_SPEED * delta
				else:
					reset_angle()
			"DOWN":
				if new_pos.y > position.y:
					position.y += Globals.TRAIN_Y_SPEED * delta
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

#func _on_engine_update_train_position(target_pos: Vector2):
	#await get_tree().create_timer(0.1).timeout
	#
	#if target_pos.x > position.x:
		#moving_direction = "RIGHT"
		#rotation_degrees += 10
	#else:
		#moving_direction = "LEFT"
		#rotation_degrees -= 10
	#
	#new_pos = target_pos

func initiate_shimmy():
	_shimmy_timer = shimmy_duration

func _on_shimmy_timer_timeout():
	initiate_shimmy()

func _on_flat_bed_update_flatbed_position(target_pos: Vector2, train_direction: Globals.TrainDirections):
	await get_tree().create_timer(Globals.TRAIN_CAR_DELAY).timeout
	#update_flatbed_position.emit()
	#update_flatbed_pos = true
	
	match train_direction:
		Globals.TrainDirections.RIGHT:
			moving_direction = "RIGHT"
			rotation_degrees += Globals.TRAIN_ROTATION
		Globals.TrainDirections.LEFT:
			moving_direction = "LEFT"
			rotation_degrees -= Globals.TRAIN_ROTATION
		Globals.TrainDirections.DOWN:
			moving_direction = "DOWN"
	
	new_pos = target_pos

func get_tiles():
	var areas : Array[Area2D] = tile_area.get_overlapping_areas()
	return areas.map(func(x): return x.get_parent().grid_pos)

func initiate_death_sequence():
	$ExplosionAddedTimer.start()

func _on_explosion_added_timer_timeout():
	var death_explosion: Node2D = death_explosion_scene.instantiate()
	death_explosion.position.x += randf_range(-20, 20)
	death_explosion.position.y += randf_range(-20, 20)
	#death_explosion.play("default")
	$DeathExplosions.add_child(death_explosion)


func _on_main_gameplay_initiate_train_death():
	initiate_death_sequence()

func take_damage(damage: int):
	health -= damage
	Globals.caboose_health_changed.emit(float(health) / float(max_health))
	if health <= 0:
		initiate_death_sequence()

func heal(heal_amount):
	health = clampi(health + heal_amount, 0, max_health)
	Globals.caboose_health_changed.emit(float(health) / float(max_health))
