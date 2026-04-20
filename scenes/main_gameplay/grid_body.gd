extends Node2D
class_name GridBody

signal moving(is_moving: bool)

@export var grid_position: Vector2i: set = set_grid_position
@export var facing_vector: Vector2i = Vector2i.ZERO

var battle_grid: BattleGrid

var _tween: Tween

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
	if grid_position == new_pos:
		return
	grid_position = new_pos
	if is_inside_tree():
		if _tween:
			_tween.custom_step(999.0)
			_tween = null
		moving.emit(true)
		_tween = create_tween()
		_tween.tween_property(self, "position", battle_grid.get_cell_center(grid_position), 0.2)
		await _tween.finished
		_tween = null
		moving.emit(false)
