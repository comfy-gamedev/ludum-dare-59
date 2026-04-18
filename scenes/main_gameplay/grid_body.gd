extends Node2D
class_name GridBody

@export var grid_position: Vector2i: set = set_grid_position
@export var facing_vector: Vector2i = Vector2.ZERO

var battle_grid: BattleGrid

func _enter_tree() -> void:
	var p = get_parent()
	while p:
		if p is BattleGrid:
			battle_grid = p
			break
		p = p.get_parent()
	assert(battle_grid)
	battle_grid.add_body(self)
	position = battle_grid.get_cell_center(grid_position)

func _exit_tree() -> void:
	assert(battle_grid)
	battle_grid.remove_body(self)

func set_grid_position(new_pos: Vector2i) -> void:
	grid_position = new_pos
	if is_inside_tree():
		var tween = create_tween()
		tween.tween_property(self, "position", battle_grid.get_cell_center(grid_position), 0.2)
		await tween.finished
