extends Node2D
signal update_train_position(target_pos: Vector2)

@onready var engine_sprite = %Sprite2D

const X_SPEED = 100
var moving_right = false
var moving_left = false
var update_train_pos = false

var shake_duration: float = 0.25
var shake_intensity: float = 0.25

var _shake_timer: float = 0.0
var original_sprite_pos: Vector2

func _ready() -> void:
	original_sprite_pos = engine_sprite.position

func _process(delta):
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		engine_sprite.position += offset
	else:
		engine_sprite.position = original_sprite_pos
		
	if moving_right:
		var target_pos = Vector2(448.0, position.y)
		
		if update_train_pos:
			update_train_position.emit(target_pos)
			update_train_pos = false
		
		if position.x <= target_pos.x:
			position.x += X_SPEED * delta
			#current_pos = position
		else:
			moving_right = false

func start_shake():
	_shake_timer = shake_duration

func _on_main_gameplay_initiate_middle_to_right_transition():
	await get_tree().create_timer(1.75).timeout
	rotation_degrees += 10
	moving_right = true
	update_train_pos = true

func _on_parallax_background_segment_transition_complete():
	rotation_degrees = 0

func _on_shimmy_timer_timeout():
	start_shake()
	print("shimmy!")
