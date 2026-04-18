extends Control

const UNFOCUSED_WIDTH = 300
const FOCUSED_WIDTH = 310
const UNFOCUSED_LIGHTNESS = 0.5
const FOCUSED_LIGHTNESS = 1.0
const FOCUS_DURATION = 0.5

func tween_shader_uniform(mat: ShaderMaterial, new_value: float):
	create_tween().tween_method(
		func(value): mat.set_shader_parameter("lightness", value),
		mat.get_shader_parameter("lightness"), new_value, FOCUS_DURATION)

func unfocus_left() -> void:
	create_tween().tween_property(
		$VBoxContainer/Container/PortraitLeft,
		"custom_minimum_size:x", UNFOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(
		$VBoxContainer/Container/PortraitLeft.material,
		UNFOCUSED_LIGHTNESS)

func focus_left() -> void:
	create_tween().tween_property(
		$VBoxContainer/Container/PortraitLeft,
		"custom_minimum_size:x", FOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(
		$VBoxContainer/Container/PortraitLeft.material,
		FOCUSED_LIGHTNESS)

func unfocus_right() -> void:
	create_tween().tween_property(
		$VBoxContainer/Container/PortraitRight,
		"custom_minimum_size:x", UNFOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(
		$VBoxContainer/Container/PortraitRight.material,
		UNFOCUSED_LIGHTNESS)

func focus_right() -> void:
	create_tween().tween_property(
		$VBoxContainer/Container/PortraitRight,
		"custom_minimum_size:x", FOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(
		$VBoxContainer/Container/PortraitRight.material,
		FOCUSED_LIGHTNESS)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	while true:
		focus_left()
		await get_tree().create_timer(1.0).timeout
		unfocus_left()
		focus_right()
		await get_tree().create_timer(1.0).timeout
		unfocus_right()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
