extends Node2D
class_name GridTerrain

@export var grid_position: Vector2i: set = set_grid_position
@export var team: BattleGrid.Team = BattleGrid.Team.PLAYER
@export var signal_blocking = false
@export var lifetime = 1
@export var transformation_target : PackedScene = null

var battle_grid: BattleGrid

func _enter_tree() -> void:
	var p = get_parent()
	while p:
		if p is BattleGrid:
			battle_grid = p
			break
		p = p.get_parent()
	assert(battle_grid)
	battle_grid.add_terrain(self)
	position = battle_grid.get_cell_center(grid_position)

func _exit_tree() -> void:
	assert(battle_grid)
	battle_grid.remove_terrain(self)

func perform_turn() -> void:
	lifetime -= 1
	if lifetime < 1:
		queue_free()
		if transformation_target:
			var new_node = transformation_target.instantiate()
			new_node.grid_position = grid_position
			get_parent().add_child(new_node)

func set_grid_position(new_pos: Vector2i) -> void:
	grid_position = new_pos
	if is_inside_tree():
		var tween = create_tween()
		tween.tween_property(self, "position", battle_grid.get_cell_center(grid_position), 0.2)
		await tween.finished
