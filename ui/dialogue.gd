extends Control

const UNFOCUSED_WIDTH = 300
const FOCUSED_WIDTH = 310
const UNFOCUSED_LIGHTNESS = 0.5
const FOCUSED_LIGHTNESS = 1.0
const FOCUS_DURATION = 0.25
const SLIDE_DURATION = 0.5

func tween_shader_uniform(tween: Tween, textureRect: TextureRect, new_value: float):
	tween.tween_method(
		func(value): textureRect.set_instance_shader_parameter("lightness", value),
		textureRect.get_instance_shader_parameter("lightness"), new_value, FOCUS_DURATION)

func unfocus_left() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitLeft,
		"custom_minimum_size:x", UNFOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(tween,
		$VBoxContainer/Container/PortraitLeft,
		UNFOCUSED_LIGHTNESS)
	return tween.finished

func focus_left() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitLeft,
		"custom_minimum_size:x", FOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(tween,
		$VBoxContainer/Container/PortraitLeft,
		FOCUSED_LIGHTNESS)
	return tween.finished

func unfocus_right() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitRight,
		"custom_minimum_size:x", UNFOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(tween,
		$VBoxContainer/Container/PortraitRight,
		UNFOCUSED_LIGHTNESS)
	return tween.finished

func focus_right() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitRight,
		"custom_minimum_size:x", FOCUSED_WIDTH, FOCUS_DURATION)
	tween_shader_uniform(tween,
		$VBoxContainer/Container/PortraitRight,
		FOCUSED_LIGHTNESS)
	return tween.finished

func slide_left_in() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitLeft,
		"position:x", 0.0, SLIDE_DURATION)
	return tween.finished

func slide_left_out() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitLeft,
		"position:x", -300.0, SLIDE_DURATION)
	return tween.finished

func slide_right_in() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitRight,
		"position:x", 340.0, SLIDE_DURATION)
	return tween.finished

func slide_right_out() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitRight,
		"position:x", 640.0, SLIDE_DURATION)
	return tween.finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	while true:
		slide_left_in()
		await slide_right_in()
		for i in range(2):
			await focus_left()
			await get_tree().create_timer(1.0).timeout
			unfocus_left()
			await focus_right()
			await get_tree().create_timer(1.0).timeout
			unfocus_right()
		await get_tree().create_timer(0.5).timeout
		slide_left_out()
		await slide_right_out()
		await get_tree().create_timer(2.0).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
