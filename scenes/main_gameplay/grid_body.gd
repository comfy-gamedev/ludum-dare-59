extends Node2D
class_name GridBody

@export var grid_position: Vector2i: set = set_grid_position
@export var team: BattleGrid.Team = BattleGrid.Team.PLAYER
@export var facing_vector: Vector2 = Vector2.ZERO

var battle_grid: BattleGrid
var _planned_moves: Array[Vector2i]

@onready var plan_line: Line2D = $PlanLine

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

func perform_turn() -> void:
	var pm = _planned_moves
	_planned_moves = []
	_update_plan_line()
	for p in pm:
		await set_grid_position(p)

func plan_move(to_pos: Vector2i) -> void:
	_planned_moves.append(to_pos)
	_update_plan_line()

func clear_moves() -> void:
	_planned_moves = []
	_update_plan_line()

func set_grid_position(new_pos: Vector2i) -> void:
	grid_position = new_pos
	if is_inside_tree():
		var tween = create_tween()
		tween.tween_property(self, "position", battle_grid.get_cell_center(grid_position), 0.2)
		await tween.finished

func _update_plan_line() -> void:
	plan_line.clear_points()
	plan_line.add_point(Vector2.ZERO)
	for p: Vector2i in _planned_moves:
		plan_line.add_point(battle_grid.get_cell_center(p) - position)
