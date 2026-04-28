extends Control
class_name SFDialogue

signal dialogue_finished()

var left_character: Character
var right_character: Character

var is_running_dialogue: bool = false

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
		if step.character != null:
			left_character = step.character
			left_tex.texture = left_character.texture
	else:
		right_rect.visible = true
		if step.character != null:
			right_character = step.character
			right_tex.texture = right_character.texture
	
	center_rect.visible = true
	
	var sfx: AudioStream
	if step.side == ConversationStep.TextureSide.LEFT:
		sfx = left_character.talk_sfx
	else:
		sfx = right_character.talk_sfx
	
	label.text = step.message
	for i in range(1, step.message.length() + 1):
		if i % 2 == 0:
			MusicMan.sfx(sfx, null, 1, randf_range(0.99, 1.1))
		var visible_ratio = float(i) / step.message.length()
		label.visible_ratio = visible_ratio
		await get_tree().create_timer(0.033).timeout
	
	if step.time != 0:
		await get_tree().create_timer(step.time).timeout
	else:
		await get_tree().create_timer(1.0).timeout
	
	left_rect.visible = false
	right_rect.visible = false
	center_rect.visible = false

func show_conversation(conv: Conversation) -> void:
	$".".visible = true
	
	var left_tex = $VBoxContainer/HBoxContainer/RectLeft/PortraitLeft
	var right_tex = $VBoxContainer/HBoxContainer/RectRight/PortraitRight
	
	if conv.left_character != null:
		left_character = conv.left_character
		left_tex.texture = conv.left_character.texture
	
	if conv.right_character != null:
		right_character = conv.right_character
		right_tex.texture = conv.right_character.texture
	
	for step in conv.steps:
		await show_step(step)
		await get_tree().create_timer(1.0).timeout
		
	$".".visible = false

func create_character_dialogue_step(character: CharacterEnum, dialogue: Dialogue) -> ConversationStep:
	if character == CharacterEnum.NONE:
		return
	
	var c = characters[character]
	if not c.dialogues.has(dialogue):
		return
	var ds = c.dialogues[dialogue]
	if ds.size() == 0:
		return
	var d = ds.pick_random()
	
	var step = ConversationStep.new()
	step.side = ConversationStep.TextureSide.LEFT
	step.character = c.character
	step.message = d
	step.time = 1.0
	return step

func show_character_dialogue(character: CharacterEnum, dialogue: Dialogue) -> void:
	print({ character = character, dialogue = dialogue })
	if character == CharacterEnum.NONE:
		return
	
	if randf() > DIALOGUE_CHANCES[dialogue]:
		return
	
	var step = create_character_dialogue_step(character, dialogue)
	if step == null:
		return
	
	if is_running_dialogue:
		await dialogue_finished
	
	is_running_dialogue = true
	
	var conv = Conversation.new()
	conv.steps.push_back(step)
	await show_conversation(conv)
	
	is_running_dialogue = false
	dialogue_finished.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".visible = false
	%RectLeft.visible = false
	%RectRight.visible = false

var characters: Dictionary[CharacterEnum, CharacterDialogue] = {
		CharacterEnum.COMMANDER: create_commander(),
		CharacterEnum.MARKSMAN: create_marksman(),
		CharacterEnum.SWORDSMAN: create_swordsman(),
		CharacterEnum.DEFENDER: create_defender(),
		CharacterEnum.HEALER: create_healer()
	}

enum CharacterEnum {
	NONE,
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
const DIALOGUE_CHANCES = {
	Dialogue.NORMAL_ATTACK: 0.1,
	Dialogue.SPECIAL_ABILITY: 0.5,
	Dialogue.KILL_STREAK: 0.5,
	Dialogue.DAMAGE_TAKEN: 0.3,
	Dialogue.KILLED: 1.0,
	Dialogue.TRAIN_DAMAGED: 0.5,
	Dialogue.ENTERING_BLACKOUT: 0.5,
	Dialogue.IN_BLACKOUT: 0.5,
	Dialogue.EXITTING_BLACKOUT: 0.5,
	Dialogue.PROGRESS: 0.5,
	Dialogue.SPECIAL_EVENT: 1.0,
}

class CharacterDialogue:
	var character: Character
	var dialogues: Dictionary = {}

func create_commander() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.character = preload("res://ui/characters/kailey_sf.tres")
	cd.dialogues[Dialogue.KILLED] = ["We're going off the rails!"]
	cd.dialogues[Dialogue.TRAIN_DAMAGED] = ["Need some help here!"]
	cd.dialogues[Dialogue.ENTERING_BLACKOUT] = ["Losing signal for a sec."]
	cd.dialogues[Dialogue.EXITTING_BLACKOUT] = ["We're back! What happened?"]
	cd.dialogues[Dialogue.PROGRESS] = ["Full speed ahead!"]
	cd.dialogues[Dialogue.SPECIAL_EVENT] = ["Something's happening, stay alert."]
	return cd

func create_marksman() -> CharacterDialogue:
	var cd = CharacterDialogue.new()
	cd.character = preload("res://ui/characters/maisie_sf.tres")
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
	cd.character = preload("res://ui/characters/sienna_sf.tres")
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
	cd.character = preload("res://ui/characters/diana_sf.tres")
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
	cd.character = preload("res://ui/characters/heidi_sf.tres")
	cd.dialogues[Dialogue.NORMAL_ATTACK] = ["Here, this should help!"] # ["Oops! Sorry!"]
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
