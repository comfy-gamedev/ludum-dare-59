extends Control

@export var conversation: Conversation

const UNFOCUSED_WIDTH = 300
const FOCUSED_WIDTH = 310
const UNFOCUSED_LIGHTNESS = 0.5
const FOCUSED_LIGHTNESS = 1.0
const FOCUS_DURATION = 0.25
const SLIDE_DURATION = 0.5

const LEFT_OFFSCREEN_X = -300
const LEFT_ONSCREEN_X = 0
const RIGHT_OFFSCREEN_X = 640
const RIGHT_ONSCREEN_X =  340

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
		"position:x", LEFT_ONSCREEN_X, SLIDE_DURATION)
	return tween.finished

func slide_left_out() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitLeft,
		"position:x", LEFT_OFFSCREEN_X, SLIDE_DURATION)
	return tween.finished

func slide_right_in() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitRight,
		"position:x", RIGHT_ONSCREEN_X, SLIDE_DURATION)
	return tween.finished

func slide_right_out() -> Signal:
	var tween = create_tween()
	tween.tween_property(
		$VBoxContainer/Container/PortraitRight,
		"position:x", RIGHT_OFFSCREEN_X, SLIDE_DURATION)
	return tween.finished
	
func show_step(step: ConversationStep) -> void:
	var left = $VBoxContainer/Container/PortraitLeft
	var right = $VBoxContainer/Container/PortraitRight
	var label = $VBoxContainer/ColorRect/RichTextLabel
	var next = $VBoxContainer/ColorRect/NextButton
	
	label.text = ""
	label.visible_ratio = 0.0
	next.visible = false
	
	if (step.side == ConversationStep.TextureSide.LEFT and 
		step.texture != null):
		if (step.texture != left.texture):
			await slide_left_out()
		left.texture = step.texture
		await slide_left_in()
	if (step.side == ConversationStep.TextureSide.RIGHT and 
		step.texture != null):
		if (step.texture != right.texture):
			await slide_right_out()
		right.texture = step.texture
		await slide_right_in()
	
	if step.side == ConversationStep.TextureSide.LEFT:
		await focus_left()
	if step.side == ConversationStep.TextureSide.RIGHT:
		await focus_right()
	
	label.text = step.message
	await create_tween().tween_property(label, "visible_ratio", 1.0, 1.0).finished
	
	if step.time != 0:
		await get_tree().create_timer(step.time).timeout
	else:
		next.visible = true
		await next.pressed
	
	if step.side == ConversationStep.TextureSide.LEFT:
		await unfocus_left()
	if step.side == ConversationStep.TextureSide.RIGHT:
		await unfocus_right()

func show_conversation(conv: Conversation) -> void:
	var left = $VBoxContainer/Container/PortraitLeft
	var right = $VBoxContainer/Container/PortraitRight
	var label = $VBoxContainer/ColorRect/RichTextLabel
	var rect = $VBoxContainer/ColorRect
	
	left.position.x = LEFT_OFFSCREEN_X
	left.texture = null
	left.set_instance_shader_parameter("lightness", 0.5)
	right.position.x = RIGHT_OFFSCREEN_X
	right.texture = null
	right.set_instance_shader_parameter("lightness", 0.5)
	label.text = ""
	label.visible_ratio = 0.0
	rect.visible = true
	
	var left_signal: Signal
	var right_signal: Signal
	var right_done = [false]
	if conversation.left_texture != null:
		left.texture = conversation.left_texture
		left_signal = slide_left_in()
	if conversation.right_texture != null:
		right.texture = conversation.right_texture
		right_signal = slide_right_in()
		right_signal.connect(func (): right_done[0] = true)
	if (left_signal):
		await left_signal
	if (right_signal) and not right_done[0]:
		await right_signal
	
	for step in conv.steps:
		await show_step(step)
	
	slide_left_out()
	await slide_right_out()
	
	label.text = ""
	label.visible_ratio = 0.0
	rect.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	await show_conversation(conversation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
