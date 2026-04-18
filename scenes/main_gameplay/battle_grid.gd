extends Node2D
class_name BattleGrid

signal cell_clicked(grid_pos: Vector2i)

const GRID_DIM = Vector2i(20, 14)
const CELL_SIZE = Vector2(32, 32)

enum Team {
	PLAYER,
	ENEMY,
}

var _grid_bodies: Array[GridBody]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			cell_clicked.emit(Vector2i(event.global_position / CELL_SIZE))

func _draw() -> void:
	for x in GRID_DIM.x:
		for y in GRID_DIM.y:
			var p = Vector2(x, y)
			draw_rect(Rect2(p * CELL_SIZE, CELL_SIZE), Color.RED, false, 2.0)

func add_body(body: GridBody) -> void:
	assert(body not in _grid_bodies)
	_grid_bodies.append(body)

func remove_body(body: GridBody) -> void:
	assert(body in _grid_bodies)
	_grid_bodies.erase(body)

func get_bodies() -> Array[GridBody]:
	return _grid_bodies.duplicate()

func get_cell_center(pos: Vector2i) -> Vector2:
	return (Vector2(pos) + Vector2(0.5, 0.5)) * CELL_SIZE

func get_cell_rect(pos: Vector2i) -> Rect2:
	return Rect2(Vector2(pos) * CELL_SIZE, CELL_SIZE)

func get_occupant(pos: Vector2i) -> GridBody:
	for b in _grid_bodies:
		if b.grid_position == pos:
			return b
	return null
