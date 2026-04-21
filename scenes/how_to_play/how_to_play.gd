extends PanelContainer

@onready var back_button := $VBoxContainer/BackButton
@onready var left_button := $VBoxContainer/HBoxContainer/LeftButton
@onready var right_button := $VBoxContainer/HBoxContainer/RightButton
@onready var tex_rect := $VBoxContainer/CenterContainer/MarginContainer/TextureRect
@onready var text_label := $VBoxContainer/MarginContainer/RichTextLabel


var pages = [
	{
		image = null,
		text = "Click on a unit to select it."
	},
	{
		image = null,
		text = "Choose an action from the menu. All of your units move and use their special move at once. Be careful of friendly fire!"
	},
	{
		image = null,
		text = "Each move spends Signal Points(SP). Don't worry if you want to redo something. Just click the unit at the start and you can redo the unit's move."
	},
	{
		image = null,
		text = "The '!' indicators show next turn you will lose signal in that square. If any of your units are in a square that has lost signal, you will not be able to command them until the signal has been restored!"
	},
	{
		image = null,
		text = "If you can't get out of the no signal zone in time, you can queue up commands for following turns and your unit will follow those commands even if they've lost signal."
	},
	{
		image = null,
		text = "To do this, just click the ghost of your unit at the end of it's path and issue your command."
	},
	{
		image = null,
		text = "Your goal is to defeat all enemies while protecting the train near the bottom of the screen. Your attacks will do friendly fire, so watch out for that!"
	},
	{
		image = null,
		text = "Keep you eye on the train car health levels at the right of the screen. There's three of them, each for a section of the train. You lose Signal Points if the train cars are destroyed. You lose the game if the engine is destroyed."
	},
]

var current_page_index = 0

func _ready() -> void:
	text_label.text = pages[current_page_index].text

func update_page(index: int) -> void:
	current_page_index = index
	text_label.text = pages[index].text

func _on_left_button_pressed() -> void:
	update_page(clampi(current_page_index - 1, 0, pages.size() - 1))

func _on_right_button_pressed() -> void:
	update_page(clampi(current_page_index + 1, 0, pages.size() - 1))

func _on_back_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main_menu/main_menu.tscn")
