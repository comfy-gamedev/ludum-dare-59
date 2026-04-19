extends GridBody
class_name EntityBody

enum EntityState {
	DESELECTED,
	PLANNING_MENU,
	PLANNING_MOVE,
	PLANNING_AIM
}

@export var max_health: int = 3
@export var health: int = 3
@export var move_speed: int = 3
@export var team: BattleGrid.Team = BattleGrid.Team.PLAYER
@export_file("*.tres") var auto_attack_path: String = "res://scenes/main_gameplay/entity_abilities/basic_attack.tres"
@export_file("*tres") var abilities_paths: Array[String]

var auto_attack: EntityAbility
var abilities: Array[EntityAbility]
var orders: Array[EntityOrder]
var state: EntityState = EntityState.DESELECTED: set = _set_state
var max_movement := 2
var turn_end_previews: Array[Node2D]
var last_mouse_over_grid: Vector2i = Vector2i(-1, -1)
var preview_line: Line2D

@onready var plan_line: Line2D = $PlanLine
@onready var weapon_area = $WeaponArea
@onready var weapon_collision = $WeaponArea/Area2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	auto_attack = load(auto_attack_path)
	for path in abilities_paths:
		abilities.append(load(path))

func _process(delta: float) -> void:
	if state == EntityState.PLANNING_AIM and not turn_end_previews.is_empty():
		var preview = turn_end_previews.back()
		var preview_area = preview.get_node("WeaponArea")
		var dir = get_global_mouse_position() - preview.position
		preview_area.rotation = atan2(-dir.x, dir.y)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_mouse_pos := get_global_mouse_position() - position + battle_grid.CELL_SIZE/2
		var local_mouse_grid_pos := Vector2(floor(local_mouse_pos.x/32), floor(local_mouse_pos.y/32))
		if state == EntityState.PLANNING_MOVE and cell_in_range(local_mouse_grid_pos + Vector2(grid_position)):
			if not preview_line:
				preview_line = Line2D.new()
				preview_line.z_index = 1
				add_child(preview_line)
			preview_line.clear_points()
			preview_line.add_point(Vector2.ZERO)
			preview_line.add_point(local_mouse_grid_pos * battle_grid.CELL_SIZE)
		elif preview_line:
			preview_line.clear_points()

func execute_turn_async() -> void:
	while not orders.is_empty() and orders[0].can_perform(self):
		await orders[0].execute_async(self)
		orders.remove_at(0)
	
	_update_plan_visuals()

func plan_move(to_pos: Vector2i, to_dir: Vector2i) -> void:
	var order = EntityOrder.new()
	order.type = EntityOrder.OrderType.MOVEMENT
	order.target_pos = to_pos
	order.target_dir = to_dir
	orders.append(order)
	_update_plan_visuals()

func plan_attack(to_pos: Vector2i, to_dir: Vector2) -> void:
	var order = EntityOrder.new()
	order.type = EntityOrder.OrderType.ABILITY
	order.ability = auto_attack
	order.target_pos = to_pos
	order.target_dir = to_dir
	orders.append(order)
	_update_plan_visuals()

func clear_moves() -> void:
	orders = []
	_update_plan_visuals()

func get_entities_in_range() -> Array[EntityBody]:
	var a: Array[EntityBody]
	for area in weapon_collision.get_overlapping_areas():
		var p = area.get_parent()
		if p is EntityBody:
			a.append(p)
	return a

func cell_in_range(cell_pos: Vector2i) -> bool:
	return grid_position.distance_to(cell_pos) <= max_movement

func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, max_health)
	if health <= 0:
		_on_death()

func create_turn_end_preview(location: Vector2, aim_dir: Vector2) -> void:
	var preview = Node2D.new()
	var preview_sprite: Sprite2D = sprite.duplicate()
	var preview_weapon_area: Node2D = weapon_area.duplicate()
	var collision_area: Area2D = preview_weapon_area.get_node("Area2D")
	preview.position = location
	preview_sprite.modulate = Color8(255, 255, 255, 100)
	preview_weapon_area.rotation = atan2(-aim_dir.x, aim_dir.y)
	preview_weapon_area.visible = true
	collision_area.monitorable = true
	preview.add_child(preview_sprite)
	preview.add_child(preview_weapon_area)
	get_parent().add_child(preview)
	turn_end_previews.append(preview)

func clear_plan_visuals() -> void:
	if plan_line:
		plan_line.clear_points()
		plan_line.add_point(Vector2.ZERO)
	while not turn_end_previews.is_empty():
		var back_preview = turn_end_previews.pop_back()
		back_preview.queue_free()

func _set_state(value: EntityState) -> void:
	state = value
	match value:
		EntityState.PLANNING_MOVE:
			battle_grid.show_movement_range(grid_position, max_movement)
		_:
			battle_grid.hide_movement_range()

func _on_death() -> void:
	print("Mr. Stark, I don't feel so good.")

func _update_plan_visuals() -> void:
	clear_plan_visuals()
	for order in orders:
		var target_position = battle_grid.get_cell_center(order.target_pos)
		match order.type:
			EntityOrder.OrderType.MOVEMENT:
				if plan_line != null:
					plan_line.add_point(target_position - position)
			EntityOrder.OrderType.ABILITY:
				create_turn_end_preview(target_position, order.target_dir)

func on_selected():
	_set_state(EntityState.PLANNING_MOVE)

func on_deselected():
	_set_state(EntityState.DESELECTED)
