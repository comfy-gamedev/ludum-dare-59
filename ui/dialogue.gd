extends Control

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

func is_left_focused() -> bool:
	return $VBoxContainer/Container/PortraitLeft.custom_minimum_size.x == FOCUSED_WIDTH

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

func is_right_focused() -> bool:
	return $VBoxContainer/Container/PortraitRight.custom_minimum_size.x == FOCUSED_WIDTH

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

var left_character: Character
var right_character: Character

func show_step(step: ConversationStep, stay_focused: bool) -> void:
	var left = $VBoxContainer/Container/PortraitLeft
	var right = $VBoxContainer/Container/PortraitRight
	var label = %Label
	var next = %NextButton
	
	label.text = ""
	label.visible_ratio = 0.0
	next.visible = false
	
	if (step.side == ConversationStep.TextureSide.LEFT and 
		step.character != null):
		if (step.character.texture != left.texture):
			await slide_left_out()
		left_character = step.character
		left.texture = left_character.texture
		await slide_left_in()
	if (step.side == ConversationStep.TextureSide.RIGHT and 
		step.character != null):
		if (step.character.texture != right.texture):
			await slide_right_out()
		right_character = step.character
		right.texture = right_character.texture
		await slide_right_in()
	
	if (step.side == ConversationStep.TextureSide.LEFT and
		not is_left_focused()):
		await focus_left()
	if (step.side == ConversationStep.TextureSide.RIGHT and
		not is_right_focused()):
		await focus_right()
	
	var sfx: AudioStream
	if step.side == ConversationStep.TextureSide.LEFT:
		sfx = left_character.talk_sfx
	else:
		sfx = right_character.talk_sfx
	
	label.text = step.message
	for i in range(1, step.message.length() + 1):
		if skip_dialogue == true:
			break
		
		if i % 2 == 0:
			MusicMan.sfx(sfx, null, 1, randf_range(0.99, 1.1))
		var visible_ratio = float(i) / step.message.length()
		label.visible_ratio = visible_ratio
		await get_tree().create_timer(0.0335).timeout
	
	if skip_dialogue == false:
		if step.time != 0:
			await get_tree().create_timer(step.time).timeout
		else:
			next.visible = true
			await next.pressed
	
	if not stay_focused:
		if step.side == ConversationStep.TextureSide.LEFT:
			await unfocus_left()
		if step.side == ConversationStep.TextureSide.RIGHT:
			await unfocus_right()

func show_conversation(conv: Conversation) -> void:
	$".".visible = true
	skip_dialogue = false
	
	var left = $VBoxContainer/Container/PortraitLeft
	var right = $VBoxContainer/Container/PortraitRight
	var label = %Label
	
	left.position.x = LEFT_OFFSCREEN_X
	left.texture = null
	left.set_instance_shader_parameter("lightness", 0.5)
	right.position.x = RIGHT_OFFSCREEN_X
	right.texture = null
	right.set_instance_shader_parameter("lightness", 0.5)
	label.text = ""
	label.visible_ratio = 0.0
	
	var left_signal: Signal
	var right_signal: Signal
	var right_done = [false]
	if conv.left_character != null:
		left_character = conv.left_character
		left.texture = left_character.texture
		left_signal = slide_left_in()
	if conv.right_character != null:
		right_character = conv.right_character
		right.texture = right_character.texture
		right_signal = slide_right_in()
		right_signal.connect(func (): right_done[0] = true)
	if (left_signal):
		await left_signal
	if (right_signal) and not right_done[0]:
		await right_signal
	
	for i in range(conv.steps.size()):
		if skip_dialogue == true:
			break
		
		var step = conv.steps[i]
		var stay_focused = false
		if i < conv.steps.size() - 1:
			var next_step = conv.steps[i + 1]
			stay_focused = (
				step.side == next_step.side and
				step.character == next_step.character
			)
		await show_step(step, stay_focused)
	
	slide_left_out()
	await slide_right_out()
	
	label.text = ""
	label.visible_ratio = 0.0
	$".".visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".visible = false
	#show_conversation(preload("res://ui/conversations/level1_intro.tres"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var skip_dialogue: bool = false
func _on_skip_button_pressed() -> void:
	skip_dialogue = true
