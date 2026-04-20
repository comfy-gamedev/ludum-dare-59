extends Panel

signal go_button_pressed()

@export var main_gameplay: MainGameplay

@onready var turn_button: Button = %TurnButton

func _on_turn_button_pressed() -> void:
	go_button_pressed.emit()
