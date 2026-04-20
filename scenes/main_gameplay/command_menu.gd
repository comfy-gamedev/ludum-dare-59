extends PanelContainer
class_name CommandMenu

signal command_chosen(command: Command, ability: EntityAbility)

enum Command {
	NONE,
	ABILITY,
	BURST,
}

@export var battle_grid: BattleGrid

@onready var ability_buttons: Array[Button]
@onready var burst_button: Button = %BurstButton

func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if not get_viewport_rect().has_point(event.global_position):
				command_chosen.emit(Command.NONE, null)
				get_viewport().set_input_as_handled()


func popup(entity: EntityBody, grid_pos: Vector2i) -> void:
	position = battle_grid.get_cell_center(grid_pos)
	burst_button.disabled = entity.orders.is_empty()
	
	for b in ability_buttons:
		b.queue_free()
	ability_buttons.clear()
	
	for ability in entity.abilities:
		var but = burst_button.duplicate(0)
		but.text = ability.display_name()
		but.pressed.connect(_on_ability_button_pressed.bind(ability))
		but.disabled = false
		burst_button.add_sibling(but)
		but.get_parent().move_child(but, burst_button.get_index())
		ability_buttons.append(but)
	
	show()


func _on_ability_button_pressed(ability: EntityAbility) -> void:
	command_chosen.emit(Command.ABILITY, ability)
	hide()

func _on_burst_button_pressed() -> void:
	command_chosen.emit(Command.BURST, null)
	hide()
