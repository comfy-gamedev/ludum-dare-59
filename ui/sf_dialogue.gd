extends Control

@export var conversation: Conversation

func show_step(step: ConversationStep) -> void:
	var left_rect = $VBoxContainer/HBoxContainer/RectLeft
	var left_tex = $VBoxContainer/HBoxContainer/RectLeft/PortraitLeft
	var center_rect = $VBoxContainer/HBoxContainer/RectCenter
	var right_rect = $VBoxContainer/HBoxContainer/RectRight
	var right_tex = $VBoxContainer/HBoxContainer/RectRight/PortraitRight
	var label = $VBoxContainer/HBoxContainer/RectCenter/RichTextLabel
	
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

var commander: CharacterDialogue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	while true:
		await show_conversation(conversation)
	await get_tree().create_timer(5.0).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



class CharacterDialogue:
	var texture: Texture2D
	var normal_attack: Array[String] = []
	var special_ability: Array[String] = []
	var kill_streak: Array[String] = []
	var damage_taken: Array[String] = []
	var killed: Array[String] = []
	var train_damaged: Array[String] = []
	var entering_blackout: Array[String] = []
	var in_blackout: Array[String] = []
	var exitting_blackout: Array[String] = []
	var progress: Array[String] = []
	var special_event: Array[String] = []

func create_commander() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/constance_small.png")
	cd.killed = ["We're going off the rails!"]
	cd.train_damaged = ["Need some help here!"]
	cd.entering_blackout = ["Losing signal for a sec."]
	cd.exitting_blackout = ["We're back! What happened?"]
	cd.progress = ["Full speed ahead!"]
	cd.special_event = ["Something's happening, stay alert."]
	return cd

func create_marksman() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/charlie_small.png")
	cd.normal_attack = ["Taking aim.", "Firing!"]
	cd.special_ability = ["Firing my laser!"]
	cd.kill_streak = ["Another one bites the dust!"]
	cd.damage_taken = ["Gotta be more careful."]
	cd.killed = ["I'm going down!"]
	cd.train_damaged = ["Dodge!!!"]
	cd.entering_blackout = ["Going dark."]
	cd.in_blackout = ["Can't see a thing in here."]
	cd.exitting_blackout = ["I'm back."]
	cd.progress = ["Setting a new record!"]
	cd.special_event = ["I see something ahead."]
	return cd

func create_swordsman() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/sloane_small.png")
	cd.normal_attack = ["Eat steel!", "Hiyah!"]
	cd.special_ability = ["I'll cut 'em down!", "I'm here to Bill and I'm here to Kill, and I'm all out of Bills!"]
	cd.kill_streak = ["Livin' on the edge!"]
	cd.damage_taken = ["Argggg!", "F-Word! That hurt!"]
	cd.killed = ["Hehhh... Not fast enough..."]
	cd.train_damaged = ["That must've hurt."]
	cd.entering_blackout = ["Not gonna be much help in here."]
	cd.in_blackout = ["Can't see nothing!"]
	cd.exitting_blackout = ["I CAN SEE!!!", "Not getting away from me now!"]
	cd.progress = ["Hackin' my way down town!"]
	cd.special_event = ["Looks like something's happenin' boss."]
	return cd
	
func create_defender() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/demi_small.png")
	cd.normal_attack = ["Take that!"]
	cd.special_ability = ["Outta my way!", "Stay behind me!"]
	cd.kill_streak = ["How did that happen?"]
	cd.damage_taken = ["Tanking damage."]
	cd.killed = ["I'm tired boss."]
	cd.train_damaged = ["Sorry, that one got by me!"]
	cd.entering_blackout = ["Gonna be hard to block in here!", "Watch your flank!"]
	cd.in_blackout = ["Where is everybody???"]
	cd.exitting_blackout = ["I can see 'em now!"]
	cd.progress = ["Pushin' through!"]
	cd.special_event = ["Looks like more is coming."]
	return cd

func create_healer() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/piper_small.png")
	cd.normal_attack = ["Oops! Sorry!"]
	cd.special_ability = ["I got you."]
	cd.kill_streak = ["Dang it Jim, I'm a healer not a fighter!"]
	cd.damage_taken = ["Help!"]
	cd.killed = ["Ahhhhhhh!!!"]
	cd.train_damaged = ["I'll be right there!"]
	cd.entering_blackout = ["It's gonna be hard to heal in here."]
	cd.in_blackout = ["Can't help in here."]
	cd.exitting_blackout = ["Anybody hurt?"]
	cd.progress = ["I'm keeping up!"]
	cd.special_event = ["What's happening now???"]
	return cd
