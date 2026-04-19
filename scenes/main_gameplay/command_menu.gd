extends PanelContainer
class_name CommandMenu

signal command_chosen(command: Command)

enum Command {
	NONE,
	MOVE,
	SPECIAL,
	BURST,
}

@export var battle_grid: BattleGrid

@onready var move_button: Button = %MoveButton
@onready var special_button: Button = %SpecialButton
@onready var burst_button: Button = %BurstButton

func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if not get_viewport_rect().has_point(event.global_position):
				command_chosen.emit(Command.NONE)
				get_viewport().set_input_as_handled()


func popup(entity: EntityBody) -> void:
	position = battle_grid.get_cell_center(entity.grid_position)
	burst_button.disabled = entity.orders.is_empty()
	show()


func _on_move_button_pressed() -> void:
	command_chosen.emit(Command.MOVE)
	hide()


func _on_special_button_pressed() -> void:
	command_chosen.emit(Command.SPECIAL)
	hide()


func _on_burst_button_pressed() -> void:
	command_chosen.emit(Command.BURST)
	hide()
