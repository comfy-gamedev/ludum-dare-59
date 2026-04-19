extends Node2D
class_name BattleGrid

const CLICK_PRIMARY = MOUSE_BUTTON_LEFT
const CLICK_SECONDARY = MOUSE_BUTTON_RIGHT

signal cell_clicked(grid_pos: Vector2i, click_button: int)

const GRID_DIM = Vector2i(16, 13)
const CELL_SIZE = Vector2(32, 32)

enum Team {
	PLAYER,
	ENEMY,
}

var _grid_bodies: Array[GridBody]
var _grid_terrain: Array[GridTerrain]
var showing_movement_range := false
var movement_center_point: Vector2i
var movement_radius: int

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index in [CLICK_PRIMARY, CLICK_SECONDARY]:
				cell_clicked.emit(Vector2i(event.global_position / CELL_SIZE), event.button_index)

func _draw() -> void:
	for x in GRID_DIM.x:
		for y in GRID_DIM.y:
			var p = Vector2(x, y)
			draw_rect(Rect2(p * CELL_SIZE, CELL_SIZE), Color.RED, false, 2.0)
			if showing_movement_range and movement_center_point.distance_to(p) <= movement_radius:
				draw_rect(Rect2(p * CELL_SIZE, CELL_SIZE), Color8(0, 255, 0, 100), true)

func add_body(body: GridBody) -> void:
	assert(body not in _grid_bodies)
	_grid_bodies.append(body)

func remove_body(body: GridBody) -> void:
	assert(body in _grid_bodies)
	_grid_bodies.erase(body)

func add_terrain(terrain: GridTerrain) -> void:
	assert(terrain not in _grid_terrain)
	_grid_terrain.append(terrain)

func remove_terrain(terrain: GridTerrain) -> void:
	assert(terrain in _grid_terrain)
	_grid_terrain.erase(terrain)

func show_movement_range(center: Vector2i, radius: int) -> void:
	movement_center_point = center
	movement_radius = radius
	showing_movement_range = true
	queue_redraw()

func hide_movement_range() -> void:
	showing_movement_range = false
	queue_redraw()

func get_bodies() -> Array[GridBody]:
	return _grid_bodies.duplicate()

func get_entities() -> Array[EntityBody]:
	var a: Array[EntityBody]
	for body in _grid_bodies:
		if body is EntityBody:
			a.append(body)
	return a

func get_terrains() -> Array[GridTerrain]:
	return _grid_terrain.duplicate()

func get_cell_center(pos: Vector2i) -> Vector2:
	return (Vector2(pos) + Vector2(0.5, 0.5)) * CELL_SIZE

func get_cell_rect(pos: Vector2i) -> Rect2:
	return Rect2(Vector2(pos) * CELL_SIZE, CELL_SIZE)

func get_occupant(pos: Vector2i) -> GridBody:
	for b in _grid_bodies:
		if b.grid_position == pos:
			return b
	return null

func get_terrain(pos: Vector2i) -> Array[GridTerrain]:
	var tiles : Array[GridTerrain] = []
	for b in _grid_terrain:
		if b.grid_position == pos:
			tiles.append(b)
	return tiles

func is_in_bounds(coord: Vector2i) -> bool:
	if coord.x >= 0 && coord.x <= GRID_DIM.x && coord.y >= 0 && coord.x <= GRID_DIM.y:
		return true
	return false
