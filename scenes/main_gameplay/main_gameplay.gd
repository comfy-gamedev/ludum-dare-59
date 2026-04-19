extends Node2D
class_name MainGameplay

signal initiate_middle_to_right_transition()

signal player_signal_points_changed()

signal _ui_input(what: int, params: Dictionary)

const UI_GRID_CLICKED = 0
const UI_START_TURN_CLICKED = 1

@onready var battle_grid: BattleGrid = $BattleGrid
@onready var turn_button: Button = %TurnButton
@onready var selection_box: Line2D = %SelectionBox
@onready var box_parent = $IndicatorBoxesParent
@onready var command_menu: CommandMenu = %CommandMenu

var player_signal_points: int:
	set(v):
		player_signal_points = v
		player_signal_points_changed.emit()

var _selected_actor: EntityBody
var _box_scene = preload("res://objects/ui/indicator.tscn")
var _warning_scene = preload("res://objects/grid_terrain/warning.tscn")

func _ready() -> void:
	selection_box.hide()
	
	var current_box : Node2D
	for i in battle_grid.GRID_DIM.x:
		for j in battle_grid.GRID_DIM.y:
			current_box = _box_scene.instantiate()
			current_box.position = Vector2(16 + (i * 32), 16 + (j * 32))
			box_parent.add_child(current_box)
	
	initiate_middle_to_right_transition.emit()
	
	reset_turn_state()
	
	turn_input()

func turn_input() -> void:
	await get_tree().process_frame
	
	turn_button.disabled = false
	
	var ui_input = await _ui_input
	var ui_event: int = ui_input[0]
	var ui_params: Dictionary = ui_input[1]
	
	match ui_event:
		UI_GRID_CLICKED:
			var grid_pos: Vector2i = ui_params.grid_pos
			var click_button: int = ui_params.click_button
			
			turn_button.disabled = true
			
			var occupant = battle_grid.get_occupant(grid_pos)
			var tile_terrains = battle_grid.get_terrain(grid_pos)
			
			if occupant is EntityBody and !tile_terrains.any(func(x): return x.signal_blocking):
				if click_button == BattleGrid.CLICK_PRIMARY:
					_selected_actor = occupant
					_selected_actor.on_selected()
					
					selection_box.position = _selected_actor.position
					selection_box.show()
					
					command_menu.popup(_selected_actor)
					
					var cmd = await command_menu.command_chosen
					match cmd:
						CommandMenu.Command.NONE:
							turn_input()
							return
						CommandMenu.Command.MOVE:
							var move_clicked = await battle_grid.cell_clicked
							var move_grid_pos = move_clicked[0]
							var move_click_button = move_clicked[1]
							if move_click_button == BattleGrid.CLICK_SECONDARY:
								turn_input()
								return
							
							_selected_actor.plan_move(move_grid_pos, _selected_actor.facing_vector)
							_selected_actor.plan_attack(move_grid_pos, _selected_actor.facing_vector)
							_selected_actor.state = EntityBody.EntityState.PLANNING_AIM
							
							move_clicked = await battle_grid.cell_clicked
							move_grid_pos = move_clicked[0]
							move_click_button = move_clicked[1]
							
							var last_order = _selected_actor.orders.back()
							if last_order:
								last_order.target_dir = get_global_mouse_position() - battle_grid.get_cell_center(last_order.target_pos)
							
							_selected_actor.on_deselected()
							_selected_actor = null
							
							selection_box.hide()
							
							player_signal_points -= 1
							
							turn_input()
							return
						CommandMenu.Command.SPECIAL:
							print("unimplemented")
							turn_input()
							return
						CommandMenu.Command.BURST:
							print("unimplemented")
							turn_input()
							return
		UI_START_TURN_CLICKED:
			selection_box.hide()
			await perform_turn()
			turn_input()
			return
	
	turn_input()
	return

func perform_turn() -> void:
	var entities: Array[EntityBody] = battle_grid.get_entities()
	for team in [BattleGrid.Team.PLAYER, BattleGrid.Team.ENEMY]:
		for ent in entities:
			if ent.team == team:
				ent.clear_plan_visuals()
				await ent.execute_turn_async()
	
	var terrain_tiles = battle_grid.get_terrains()
	for terr in terrain_tiles:
		await terr.perform_turn()
	
	reset_turn_state()
	spawn_clouds()


func reset_turn_state() -> void:
	player_signal_points = 3

func _on_battle_grid_cell_clicked(grid_pos: Vector2i, click_button: int) -> void:
	_ui_input.emit(UI_GRID_CLICKED, {grid_pos = grid_pos, click_button = click_button})


func _on_turn_button_pressed() -> void:
	_ui_input.emit(UI_START_TURN_CLICKED, {})


func _on_parallax_background_segment_transition_complete():
	print("Terrain segment transition complete!")

func spawn_clouds(num = 2, radii = 4):
	for i in num:
		var center = randi_range(0, (battle_grid.GRID_DIM.x - 2) * (battle_grid.GRID_DIM.y - 2))
		var center_coord := Vector2i(1 + (center / (battle_grid.GRID_DIM.x - 2)), 1 + (center % (battle_grid.GRID_DIM.x - 2)))
		var current_coord := center_coord
		var dirs = [Vector2i(1, -1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, 1)]
		
		var warning_node : GridTerrain
		warning_node = _warning_scene.instantiate()
		warning_node.set_grid_position(current_coord)
		battle_grid.add_child(warning_node)
		for radius in range(1, radii):
			current_coord = center_coord + Vector2i(0, radius)
			for dir in dirs:
				while true:
					if battle_grid.is_in_bounds(current_coord) && (radius < radii - 1 || randi() % 2):
						warning_node = _warning_scene.instantiate()
						warning_node.set_grid_position(current_coord)
						battle_grid.add_child(warning_node)
					current_coord += dir
					if current_coord.x == center_coord.x || current_coord.y == center_coord.y:
						break
