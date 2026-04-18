extends Node2D
class_name GridBody

var battle_grid: BattleGrid

@export var grid_position: Vector2i: set = set_grid_position

func _enter_tree() -> void:
	var p = get_parent()
	while p:
		if p is BattleGrid:
			battle_grid = p
			break
	assert(battle_grid)
	battle_grid.add_body(self)
	position = battle_grid.get_cell_center(grid_position)

func _exit_tree() -> void:
	assert(battle_grid)
	battle_grid.remove_body(self)

func _process(delta: float) -> void:
	pass

func set_grid_position(new_pos: Vector2i) -> void:
	grid_position = new_pos
	if is_inside_tree():
		create_tween().tween_property(self, "position", battle_grid.get_cell_center(grid_position), 0.2)
