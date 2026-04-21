extends Node2D
class_name MainGameplay

signal initiate_middle_to_right_transition()
signal initiate_middle_to_left_transition()
signal initiate_left_to_middle_transition()
signal initiate_right_to_middle_transition()
signal initiate_train_intro()
signal initiate_train_death()

signal player_signal_points_changed()

signal _turn_movement_done()

signal _ui_input(what: int, params: Dictionary)
signal turn_end

const UI_GRID_CLICKED = 0
const UI_START_TURN_CLICKED = 1

static var current: MainGameplay

@onready var battle_grid: BattleGrid = $BattleGrid
@onready var selection_box: Line2D = %SelectionBox
@onready var box_parent = $IndicatorBoxesParent
@onready var command_menu: CommandMenu = %CommandMenu
@onready var right_panel: Panel = $CanvasLayer/RightPanel
@onready var selection_panel: Panel = $CanvasLayer/SelectionPanel

@onready var dialogue = %Dialogue
@onready var sf_dialogue: SFDialogue = %SfDialogue

var level_1_intro_conversation = preload("res://ui/conversations/level1_intro.tres")
var level_1_outro_conversation = preload("res://ui/conversations/level1_complete.tres")
var level_2_intro_conversation = preload("res://ui/conversations/level2_intro.tres")
var level_2_outro_conversation = preload("res://ui/conversations/level2_complete.tres")

@onready var shadow = $BattleGrid/Shadow/ColorRect
@onready var crossing_panel: CrossingPanel = $CanvasLayer/CrossingPanel

var basic_drone_scene = preload("res://objects/grid_actors/enemies/basic_drone.tscn")
var slash_drone_scene = preload("res://objects/grid_actors/enemies/slash_drone.tscn")

var gunner_mech_scene = preload("res://scenes/main_gameplay/mechs/gunner_mech.tscn")
var shield_mech_scene = preload("res://scenes/main_gameplay/mechs/shield_mech.tscn")
var support_mech_scene = preload("res://scenes/main_gameplay/mechs/support_mech.tscn")
var sword_mech_scene = preload("res://scenes/main_gameplay/mechs/sword_mech.tscn")

var current_terrain_segment_state = Globals.TerrainSegmentStates.MIDDLE

var player_signal_points: int:
	set(v):
		player_signal_points = v
		player_signal_points_changed.emit()

var _selected_actor: EntityBody
var _box_scene = preload("res://objects/ui/indicator.tscn")
var _warning_scene = preload("res://objects/grid_terrain/warning.tscn")

var turn_counter = 0
var turn_goal = 20
var current_wave = 0
var scene_tranition_queue: Signal
var incoming_segment = Globals.TerrainSegmentStates.NONE

func _ready() -> void:
	current = self
	
	MusicMan.music(preload("res://assets/music/transmissionTheory.ogg"))
	
	selection_box.hide()
	
	var current_box : Node2D
	for i in battle_grid.GRID_DIM.x:
		for j in battle_grid.GRID_DIM.y:
			current_box = _box_scene.instantiate()
			current_box.position = Vector2(16 + (i * 32), 16 + (j * 32))
			current_box.grid_pos = Vector2i(i, j)
			box_parent.add_child(current_box)
	
	#initiate_middle_to_right_transition.emit()
	#initiate_middle_to_left_transition.emit()
	#initiate_left_to_middle_transition.emit()
	#on_train_death()
	initiate_level()
	Globals.init_train($Engine, $FlatBed, $Caboose)
	
	reset_turn_state()
	
	turn_input()

func turn_input() -> void:
	await get_tree().process_frame
	
	#turn_button.disabled = false
	
	var ui_input = await _ui_input
	var ui_event: int = ui_input[0]
	var ui_params: Dictionary = ui_input[1]
	
	match ui_event:
		UI_GRID_CLICKED:
			var grid_pos: Vector2i = ui_params.grid_pos
			var click_button: int = ui_params.click_button
			
			#turn_button.disabled = true
			
			var occupant = battle_grid.get_occupant(grid_pos)
			var tile_terrains = battle_grid.get_terrain(grid_pos)
			var is_future_order = false
			
			# If no occupant found, check for planning previews
			if not occupant:
				for ent in battle_grid.get_entities():
					if ent.turn_done and ent.turn_end_grid_pos == grid_pos:
						is_future_order = true
						occupant = ent
			
			if not occupant is EntityBody or tile_terrains.any(func(x): return x.signal_blocking):
				if _selected_actor:
					_selected_actor.on_deselected()
					selection_panel.set_selected_entity(null)
					selection_box.hide()
			else:
				if click_button == BattleGrid.CLICK_PRIMARY:
					_selected_actor = occupant
					var is_player_unit = _selected_actor.team == BattleGrid.Team.PLAYER
					
					if is_player_unit and _selected_actor.turn_done and not is_future_order:
						# TODO: only orders places this turn should be refundable
						player_signal_points += 1 + _selected_actor.future_orders.size()
						_selected_actor.clear_orders()
					
					_selected_actor.on_selected()
					selection_panel.set_selected_entity(_selected_actor)
					
					selection_box.position = battle_grid.get_cell_center(grid_pos)
					selection_box.show()
					
					if not is_player_unit or player_signal_points <= 0:
						turn_input()
						return
					
					command_menu.popup(_selected_actor, grid_pos)
					
					var cmd = await command_menu.command_chosen
					match cmd[0]:
						CommandMenu.Command.NONE:
							_selected_actor.on_deselected()
							selection_panel.set_selected_entity(null)
							selection_box.hide()
							
							turn_input()
							return
						CommandMenu.Command.ABILITY:
							var ability: EntityAbility = cmd[1]
							assert(ability)
							
							@warning_ignore("redundant_await")
							var order = await ability.input_async(_selected_actor, battle_grid)
							
							if order:
								player_signal_points -= 1
								var turn_index = 0
								if is_future_order:
									turn_index = _selected_actor.future_orders.size() + 1
								_selected_actor.plan_order(order, turn_index)
								_selected_actor.turn_done = true
							else:
								await ability.on_cancel(_selected_actor)
							
							_selected_actor.on_deselected()
							selection_panel.set_selected_entity(null)
							selection_box.hide()
							
							turn_input()
							return
						CommandMenu.Command.BURST:
							await perform_next_turn_for(_selected_actor)
							
							turn_input()
							return
		UI_START_TURN_CLICKED:
			selection_box.hide()
			await perform_turn()
			turn_input()
			return
	
	turn_input()
	return

func perform_next_turn_for(ent: EntityBody) -> void:
	ent.clear_plan_visuals()
	ent.start_turn()
	
	await ent.execute_turn_movement_async()
	
	if is_instance_valid(ent):
		await ent.execute_turn_async()
	

func perform_turn() -> void:
	var entities: Array[EntityBody] = battle_grid.get_entities()
	
	for team in [BattleGrid.Team.PLAYER, BattleGrid.Team.ENEMY]:
		for ent in entities:
			if ent.team == team:
				ent.clear_plan_visuals()
				ent.start_turn()
	
	battle_grid.enable_crossings()
	
	var turn_move_dones: Dictionary[EntityBody, bool]
	
	for team in [BattleGrid.Team.PLAYER, BattleGrid.Team.ENEMY]:
		for ent in entities:
			if ent.team == team:
				(func ():
					await ent.execute_turn_movement_async()
					turn_move_dones[ent] = true
					if turn_move_dones.size() == entities.size():
						_turn_movement_done.emit()
				).call_deferred()
	
	await _turn_movement_done
	
	battle_grid.disable_crossings()
	
	for team in [BattleGrid.Team.PLAYER, BattleGrid.Team.ENEMY]:
		for ent in entities:
			if is_instance_valid(ent):
				if ent.team == team:
					await ent.execute_turn_async()
	
	var terrain_tiles = battle_grid.get_terrains()
	for terr in terrain_tiles:
		await terr.perform_turn()
	
	var bodies: Array[GridBody] = battle_grid.get_bodies(true)
	for body in bodies:
		body.execute_turn_async()
	
	reset_turn_state()
	#spawn_clouds()
	turn_end.emit()

func reset_turn_state() -> void:
	player_signal_points = 3
	_selected_actor = null

func _on_battle_grid_cell_clicked(grid_pos: Vector2i, click_button: int) -> void:
	_ui_input.emit(UI_GRID_CLICKED, {grid_pos = grid_pos, click_button = click_button})


func _on_parallax_background_segment_transition_complete():
	right_panel.turn_button.disabled = false
	right_panel.turn_button.text = "GO"
	print("Terrain segment transition complete!")
	#on_train_death()

func spawn_clouds(num = 2, radii = 4):
	for i in num:
		var center = randi_range(0, (battle_grid.GRID_DIM.x - 2) * (battle_grid.GRID_DIM.y - 2))
		var center_coord := Vector2i(1 + (center / (battle_grid.GRID_DIM.x - 2)), 1 + (center % (battle_grid.GRID_DIM.y - 2)))
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

func queue_terrain_segment_transition():
	match current_terrain_segment_state:
		Globals.TerrainSegmentStates.MIDDLE:
			var possible_transitions = [Globals.TerrainSegmentStates.LEFT, Globals.TerrainSegmentStates.RIGHT, Globals.TerrainSegmentStates.MIDDLE] # and tunnel eventually
			var random_transition = possible_transitions.pick_random()
			
			if random_transition == Globals.TerrainSegmentStates.LEFT:
				#initiate_middle_to_left_transition.emit()
				#set_current_terrain_segment(Globals.TerrainSegmentStates.LEFT)
				set_segment_queue(initiate_middle_to_left_transition, Globals.TerrainSegmentStates.LEFT)
				#current_terrain_segment_state = Globals.TerrainSegmentStates.LEFT
			elif random_transition == Globals.TerrainSegmentStates.RIGHT:
				#initiate_middle_to_right_transition.emit()
				#set_current_terrain_segment(Globals.TerrainSegmentStates.RIGHT)
				set_segment_queue(initiate_middle_to_right_transition, Globals.TerrainSegmentStates.RIGHT)
				#current_terrain_segment_state = Globals.TerrainSegmentStates.RIGHT
		
		Globals.TerrainSegmentStates.LEFT:
			var possible_transitions = [Globals.TerrainSegmentStates.LEFT, Globals.TerrainSegmentStates.MIDDLE]
			var random_transition = possible_transitions.pick_random()
			
			if random_transition == Globals.TerrainSegmentStates.MIDDLE:
				#initiate_left_to_middle_transition.emit()
				#current_terrain_segment_state = Globals.TerrainSegmentStates.MIDDLE
				#set_current_terrain_segment(Globals.TerrainSegmentStates.MIDDLE)
				set_segment_queue(initiate_left_to_middle_transition, Globals.TerrainSegmentStates.MIDDLE)
		
		Globals.TerrainSegmentStates.RIGHT:
			var possible_transitions = [Globals.TerrainSegmentStates.RIGHT, Globals.TerrainSegmentStates.MIDDLE]
			var random_transition = possible_transitions.pick_random()
			
			if random_transition == Globals.TerrainSegmentStates.MIDDLE:
				set_segment_queue(initiate_right_to_middle_transition, Globals.TerrainSegmentStates.MIDDLE)
				#initiate_right_to_middle_transition.emit()
				#set_current_terrain_segment(Globals.TerrainSegmentStates.MIDDLE)

func set_segment_queue(segment_signal: Signal, new_segment):
	scene_tranition_queue = segment_signal
	incoming_segment = new_segment

	if incoming_segment == Globals.TerrainSegmentStates.LEFT:
		print("mountains LEFT coming in one turn")
		queue_mountain_smoke_right()
	elif incoming_segment == Globals.TerrainSegmentStates.RIGHT:
		print("mountains RIGHT coming in one turn")
		queue_mountain_smoke_left()

func queue_mountain_smoke_left():
	var tiles = []
	for r in range(6):
		for c in range(13):
			tiles.append(Vector2i(r, c))
			
	for i in tiles:
		var new_warning_tile = _warning_scene.instantiate()
		new_warning_tile.grid_position = i
		battle_grid.add_child(new_warning_tile)

func queue_mountain_smoke_right():
	var tiles = []
	const starting_row = 12
	for r in range(4):
		for c in range(13):
			tiles.append(Vector2i(r + starting_row, c))
			
	for i in tiles:
		var new_warning_tile = _warning_scene.instantiate()
		new_warning_tile.grid_position = i
		battle_grid.add_child(new_warning_tile)

func initiate_terrain_segment_transition():
	scene_tranition_queue.emit()
	set_current_terrain_segment(incoming_segment)
	incoming_segment = Globals.TerrainSegmentStates.NONE

#func queue_segment_transition():
	#match Globals.TerrainSegmentStates:
		#match 

func set_current_terrain_segment(new_terrain_segment_state: Globals.TerrainSegmentStates):
	incoming_segment = Globals.TerrainSegmentStates.NONE
	current_terrain_segment_state = new_terrain_segment_state
	right_panel.turn_button.disabled = true
	right_panel.turn_button.text = "WAIT"
	print("Init new terrain segment transition")

func _on_turn_end():
	turn_counter += 1
	if turn_counter > turn_goal:
		Globals.level += 1
		if Globals.level > 3:
			$CanvasLayer/WinCard.show()
			$CanvasLayer/BlankBanner.show()
			$CanvasLayer/HBoxContainer.show()
			return
		initiate_level()
		return
	_spawn_turn_stuff()
	
	if incoming_segment != Globals.TerrainSegmentStates.NONE:
		print("transition")
		initiate_terrain_segment_transition()
	else:
		queue_terrain_segment_transition()
	print("turn: %s" % turn_counter)
	print("wave: %s" % current_wave)
	print("level: %s" % Globals.level)

func _spawn_turn_stuff():
	if Globals.level > 0:
		spawn_clouds(2 + (Globals.level / 3), min(2 + Globals.level, 4))
	if turn_counter % 3 == 0:
		current_wave += 1
		init_new_wave()
	else:
		spawn_clouds(1, 3)

func on_train_death():
	right_panel.turn_button.disabled = true
	initiate_train_death.emit()

func _on_right_panel_go_button_pressed() -> void:
	_ui_input.emit(UI_START_TURN_CLICKED, {})

func initiate_level():
	turn_counter = 0
	current_wave = 0
	
	if Globals.level == 0:
		dialogue.show_conversation(level_1_intro_conversation)
	if Globals.level == 1:
		dialogue.show_conversation(level_2_intro_conversation)
		
	# do difficult based on level
	var sword_mech = battle_grid.get_node("SwordMech")
	if not sword_mech:
		sword_mech = sword_mech_scene.instantiate()
		battle_grid.add_child(sword_mech)
	var shield_mech = battle_grid.get_node("ShieldMech")
	if not shield_mech:
		shield_mech = shield_mech_scene.instantiate()
		battle_grid.add_child(shield_mech)
	var support_mech = battle_grid.get_node("SupportMech")
	if not support_mech:
		support_mech = support_mech_scene.instantiate()
		battle_grid.add_child(support_mech)
	var gunner_mech = battle_grid.get_node("GunnerMech")
	if not gunner_mech:
		gunner_mech = gunner_mech_scene.instantiate()
		battle_grid.add_child(gunner_mech)
	sword_mech.grid_position = Vector2i(9, 6)
	shield_mech.grid_position = Vector2i(6, 6)
	support_mech.grid_position = Vector2i(9, 9)
	gunner_mech.grid_position = Vector2i(6, 9)
	#print(battle_grid.get_node("SwordMech"))
	#spawn_drones()

func init_new_wave():
	for i in range(max(2, floor(current_wave * (0.67 + (Globals.level * .5) ) ))):
		#spawn_enemy_left()
		#spawn_enemy_right()
		#spawn_enemy_up()
		spawn_random_enemy()

func spawn_random_enemy():
	var enemy_scenes = [basic_drone_scene, slash_drone_scene]
	var sides = ["left", "up", "right"]
	var enemy_scene = enemy_scenes.pick_random()
	var side = sides.pick_random()
	
	match side:
		"left":
			var grid_x_pos = 0
			for i in range(10):
				var grid_y_pos = randi_range(0, 12)
				var spawn_location = Vector2i(grid_x_pos, grid_y_pos)
				
				if battle_grid.get_occupant(spawn_location) == null:
					spawn_enemy(spawn_location, enemy_scene)
					return
		"up":
			var grid_y_pos = 0
			for i in range(10):
				var grid_x_pos = randi_range(0, 15)
				var spawn_location = Vector2i(grid_x_pos, grid_y_pos)
				
				if battle_grid.get_occupant(spawn_location) == null:
					spawn_enemy(spawn_location, enemy_scene)
					return
		"right":
			var grid_x_pos = 15
			for i in range(10):
				var grid_y_pos = randi_range(0, 12)
				var spawn_location = Vector2i(grid_x_pos, grid_y_pos)
				if battle_grid.get_occupant(spawn_location) == null:
					spawn_enemy(spawn_location, enemy_scene)
					return

func spawn_enemy(grid_pos: Vector2i, enemy_scene: PackedScene):
	var new_enemy = enemy_scene.instantiate()
	new_enemy.grid_position = grid_pos
	battle_grid.add_child(new_enemy)

func _on_battle_grid_crossing(entity_a: EntityBody, entity_b: EntityBody) -> void:
	get_tree().paused = true
	if entity_a.team != BattleGrid.Team.PLAYER:
		var tmp = entity_a
		entity_a = entity_b
		entity_b = tmp
	var winner = await crossing_panel.play(entity_a, entity_b)
	if winner == entity_a:
		entity_b.take_damage(1)
	else:
		entity_a.take_damage(1)
	get_tree().paused = false


func _on_retry_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main_gameplay/main_gameplay.tscn")


func _on_main_menu_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main_menu/main_menu.tscn")
