extends Control

@export var conversation: Conversation

func show_step(step: ConversationStep) -> void:
	var left_rect = $VBoxContainer/HBoxContainer/RectLeft
	var left_tex = $VBoxContainer/HBoxContainer/RectLeft/PortraitLeft
	var center_rect = $VBoxContainer/HBoxContainer/RectCenter
	var right_rect = $VBoxContainer/HBoxContainer/RectRight
	var right_tex = $VBoxContainer/HBoxContainer/RectRight/PortraitRight
	var label = $VBoxContainer/HBoxContainer/RectCenter/MarginContainer/RichTextLabel
	
	label.text = ""
	label.visible_ratio = 0.0
	
	if step.side == ConversationStep.TextureSide.LEFT:
		left_rect.visible = true
		if step.texture != null:
			left_tex.texture = step.texture
	else:
		right_rect.visible = true
		if step.texture != null:
			right_tex.texture = step.texture
	
	center_rect.visible = true
	label.text = step.message
	await create_tween().tween_property(label, "visible_ratio", 1.0, 0.5).finished
	
	if step.time != 0:
		await get_tree().create_timer(step.time).timeout
	else:
		await get_tree().create_timer(1.0).timeout
		
	left_rect.visible = false
	right_rect.visible = false
	center_rect.visible = false

func show_conversation(conv: Conversation) -> void:
	var left_tex = $VBoxContainer/HBoxContainer/RectLeft/PortraitLeft
	var right_tex = $VBoxContainer/HBoxContainer/RectRight/PortraitRight
	
	if conversation.left_texture != null:
		left_tex.texture = conversation.left_texture
	
	if conversation.right_texture != null:
		right_tex.texture = conversation.right_texture
	
	for step in conv.steps:
		await show_step(step)
		await get_tree().create_timer(1.0).timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	while true:
		await show_conversation(conversation)
	await get_tree().create_timer(5.0).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
