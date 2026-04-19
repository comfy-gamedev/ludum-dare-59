extends Node2D
signal initiate_middle_to_right_transition


@onready var battle_grid: BattleGrid = $BattleGrid
@onready var turn_button: Button = %TurnButton
@onready var selection_box: Line2D = %SelectionBox
@onready var box_parent = $IndicatorBoxesParent

var player_mana: int

var _selected_actor: EntityBody
var _player_input_enabled: bool = true
var _box_scene = preload("res://objects/ui/indicator.tscn")

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

func _process(delta: float) -> void:
	pass

func perform_turn() -> void:
	turn_button.disabled = true
	_player_input_enabled = false
	var entities: Array[EntityBody] = battle_grid.get_entities()
	for team in [BattleGrid.Team.PLAYER, BattleGrid.Team.ENEMY]:
		for ent in entities:
			if ent.team == team:
				ent.clear_plan_visuals()
				await ent.execute_turn_async()
	
	var terrain_tiles = battle_grid.get_terrains()
	for terr in terrain_tiles:
		await terr.perform_turn()
	turn_button.disabled = false
	_player_input_enabled = true
	
	reset_turn_state()


func reset_turn_state() -> void:
	player_mana = 3


func _on_battle_grid_cell_clicked(grid_pos: Vector2i, left: bool) -> void:
	if not _player_input_enabled:
		return
	
	if _selected_actor:
		if left:
			if _selected_actor.state == EntityBody.EntityState.PLANNING_MOVE and _selected_actor.cell_in_range(grid_pos):
				_selected_actor.plan_move(grid_pos, _selected_actor.facing_vector)
				_selected_actor.plan_attack(grid_pos, _selected_actor.facing_vector)
				_selected_actor.state = EntityBody.EntityState.PLANNING_AIM
			elif _selected_actor.state == EntityBody.EntityState.PLANNING_AIM:
				var last_order = _selected_actor.orders.back()
				if last_order:
					last_order.target_dir = get_global_mouse_position() - battle_grid.get_cell_center(last_order.target_pos)
				_selected_actor.on_deselected()
				_selected_actor = null
				selection_box.hide()
	else:
		var occupant = battle_grid.get_occupant(grid_pos)
		var tile_terrains = battle_grid.get_terrain(grid_pos)
		if occupant is EntityBody and !tile_terrains.any(func(x): return x.signal_blocking):
			if left:
				_selected_actor = occupant
				_selected_actor.on_selected()
				selection_box.position = _selected_actor.position
				selection_box.show()
			else:
				occupant.clear_moves()


func _on_turn_button_pressed() -> void:
	perform_turn()
	selection_box.hide()


func _on_parallax_background_segment_transition_complete():
	print("Terrain segment transition complete!")
