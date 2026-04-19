extends Control

@export var conversation: Conversation

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
	if is_instance_valid(conversation):
		var left_signal: Signal
		var right_signal: Signal
		var right_done = [false]
		if conversation.left_texture != null:
			$VBoxContainer/Container/PortraitLeft.texture = conversation.left_texture
			left_signal = slide_left_in()
		if conversation.right_texture != null:
			$VBoxContainer/Container/PortraitRight.texture = conversation.right_texture
			right_signal = slide_right_in()
			right_signal.connect(func (): right_done[0] = true)
		if is_instance_valid(left_signal):
			await left_signal
		if is_instance_valid(right_signal) and not right_done[0]:
			await right_signal
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
