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

func create_character_dialogue_step(character: Character, dialogue: Dialogue) -> ConversationStep:
	var c = characters[character]
	if not c.dialogues.has(dialogue):
		return
	var ds = c.dialogues[dialogue]
	if ds.size() == 0:
		return
	var d = ds.pick_random()
	
	var step = ConversationStep.new()
	step.side = ConversationStep.TextureSide.LEFT
	step.texture = c.texture
	step.message = d
	step.time = 1.0
	return step

func show_character_dialogue(character: Character, dialogue: Dialogue) -> void:
	var step = create_character_dialogue_step(character, dialogue)
	if step == null:
		return
	var conv = Conversation.new()
	conv.steps.push_back(step)
	await show_conversation(conv)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for character in Character.values():
		for dialogue in Dialogue.values():
			await show_character_dialogue(character, dialogue)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var characters: Dictionary[Character, CharacterDialogue] = {
		Character.COMMANDER: create_commander(),
		Character.MARKSMAN: create_marksman(),
		Character.SWORDSMAN: create_swordsman(),
		Character.DEFENDER: create_defender(),
		Character.HEALER: create_healer()
	}

enum Character {
	COMMANDER,
	MARKSMAN,
	SWORDSMAN,
	DEFENDER,
	HEALER
}
enum Dialogue {
	NORMAL_ATTACK,
	SPECIAL_ABILITY,
	KILL_STREAK,
	DAMAGE_TAKEN,
	KILLED,
	TRAIN_DAMAGED,
	ENTERING_BLACKOUT,
	IN_BLACKOUT,
	EXITTING_BLACKOUT,
	PROGRESS,
	SPECIAL_EVENT
}

class CharacterDialogue:
	var texture: Texture2D
	var dialogues: Dictionary = {}

func create_commander() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/constance_small.png")
	cd.dialogues[Dialogue.KILLED] = ["We're going off the rails!"]
	cd.dialogues[Dialogue.TRAIN_DAMAGED] = ["Need some help here!"]
	cd.dialogues[Dialogue.ENTERING_BLACKOUT] = ["Losing signal for a sec."]
	cd.dialogues[Dialogue.EXITTING_BLACKOUT] = ["We're back! What happened?"]
	cd.dialogues[Dialogue.PROGRESS] = ["Full speed ahead!"]
	cd.dialogues[Dialogue.SPECIAL_EVENT] = ["Something's happening, stay alert."]
	return cd

func create_marksman() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/charlie_small.png")
	cd.dialogues[Dialogue.NORMAL_ATTACK] = ["Taking aim.", "Firing!"]
	cd.dialogues[Dialogue.SPECIAL_ABILITY] = ["Firing my laser!"]
	cd.dialogues[Dialogue.KILL_STREAK] = ["Another one bites the dust!"]
	cd.dialogues[Dialogue.DAMAGE_TAKEN] = ["Gotta be more careful."]
	cd.dialogues[Dialogue.KILLED] = ["I'm going down!"]
	cd.dialogues[Dialogue.TRAIN_DAMAGED] = ["Dodge!!!"]
	cd.dialogues[Dialogue.ENTERING_BLACKOUT] = ["Going dark."]
	cd.dialogues[Dialogue.IN_BLACKOUT] = ["Can't see a thing in here."]
	cd.dialogues[Dialogue.EXITTING_BLACKOUT] = ["I'm back."]
	cd.dialogues[Dialogue.PROGRESS] = ["Setting a new record!"]
	cd.dialogues[Dialogue.SPECIAL_EVENT] = ["I see something ahead."]
	return cd

func create_swordsman() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/sloane_small.png")
	cd.dialogues[Dialogue.NORMAL_ATTACK] = ["Eat steel!", "Hiyah!"]
	cd.dialogues[Dialogue.SPECIAL_ABILITY] = ["I'll cut 'em down!", "I'm here to Bill and I'm here to Kill, and I'm all out of Bills!"]
	cd.dialogues[Dialogue.KILL_STREAK] = ["Livin' on the edge!"]
	cd.dialogues[Dialogue.DAMAGE_TAKEN] = ["Argggg!", "F-Word! That hurt!"]
	cd.dialogues[Dialogue.KILLED] = ["Hehhh... Not fast enough..."]
	cd.dialogues[Dialogue.TRAIN_DAMAGED] = ["That must've hurt."]
	cd.dialogues[Dialogue.ENTERING_BLACKOUT] = ["Not gonna be much help in here."]
	cd.dialogues[Dialogue.IN_BLACKOUT] = ["Can't see nothing!"]
	cd.dialogues[Dialogue.EXITTING_BLACKOUT] = ["I CAN SEE!!!", "Not getting away from me now!"]
	cd.dialogues[Dialogue.PROGRESS] = ["Hackin' my way down town!"]
	cd.dialogues[Dialogue.SPECIAL_EVENT] = ["Looks like something's happenin' boss."]
	return cd
	
func create_defender() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/demi_small.png")
	cd.dialogues[Dialogue.NORMAL_ATTACK] = ["Take that!"]
	cd.dialogues[Dialogue.SPECIAL_ABILITY] = ["Outta my way!", "Stay behind me!"]
	cd.dialogues[Dialogue.KILL_STREAK] = ["How did that happen?"]
	cd.dialogues[Dialogue.DAMAGE_TAKEN] = ["Tanking damage."]
	cd.dialogues[Dialogue.KILLED] = ["I'm tired boss."]
	cd.dialogues[Dialogue.TRAIN_DAMAGED] = ["Sorry, that one got by me!"]
	cd.dialogues[Dialogue.ENTERING_BLACKOUT] = ["Gonna be hard to block in here!", "Watch your flank!"]
	cd.dialogues[Dialogue.IN_BLACKOUT] = ["Where is everybody???"]
	cd.dialogues[Dialogue.EXITTING_BLACKOUT] = ["I can see 'em now!"]
	cd.dialogues[Dialogue.PROGRESS] = ["Pushin' through!"]
	cd.dialogues[Dialogue.SPECIAL_EVENT] = ["Looks like more is coming."]
	return cd

func create_healer() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.texture = preload("res://assets/textures/characters/piper_small.png")
	cd.dialogues[Dialogue.NORMAL_ATTACK] = ["Oops! Sorry!"]
	cd.dialogues[Dialogue.SPECIAL_ABILITY] = ["I got you."]
	cd.dialogues[Dialogue.KILL_STREAK] = ["Dang it Jim, I'm a healer not a fighter!"]
	cd.dialogues[Dialogue.DAMAGE_TAKEN] = ["Help!"]
	cd.dialogues[Dialogue.KILLED] = ["Ahhhhhhh!!!"]
	cd.dialogues[Dialogue.TRAIN_DAMAGED] = ["I'll be right there!"]
	cd.dialogues[Dialogue.ENTERING_BLACKOUT] = ["It's gonna be hard to heal in here."]
	cd.dialogues[Dialogue.IN_BLACKOUT] = ["Can't help in here."]
	cd.dialogues[Dialogue.EXITTING_BLACKOUT] = ["Anybody hurt?"]
	cd.dialogues[Dialogue.PROGRESS] = ["I'm keeping up!"]
	cd.dialogues[Dialogue.SPECIAL_EVENT] = ["What's happening now???"]
	return cd
