extends Node2D

@onready var battle_grid: BattleGrid = $BattleGrid
@onready var turn_button: Button = %TurnButton
@onready var selection_box: Line2D = %SelectionBox

var _selected_actor: GridBody
var _player_input_enabled: bool = true

func _ready() -> void:
	selection_box.hide()

func perform_turn() -> void:
	turn_button.disabled = true
	_player_input_enabled = false
	var actors = battle_grid.get_bodies()
	for team in [BattleGrid.Team.PLAYER, BattleGrid.Team.ENEMY]:
		for actor in actors:
			if actor.team == team:
				await actor.perform_turn()
	turn_button.disabled = false
	_player_input_enabled = true


func _on_battle_grid_cell_clicked(grid_pos: Vector2i, left: bool) -> void:
	if not _player_input_enabled:
		return
	
	var occupant = battle_grid.get_occupant(grid_pos)
	var tile_terrains = battle_grid.get_terrain(grid_pos)
	if occupant && !tile_terrains.any(func(x): return x.signal_blocking):
		if left:
			_selected_actor = occupant
			selection_box.position = _selected_actor.position
			selection_box.show()
		else:
			occupant.clear_moves()
	elif _selected_actor:
		if left:
			_selected_actor.plan_move(grid_pos)
		_selected_actor = null
		selection_box.hide()


func _on_turn_button_pressed() -> void:
	perform_turn()
	selection_box.hide()
