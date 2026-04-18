extends GridBody
class_name EntityBody

@export var max_health: int = 3
@export var health: int = 3
@export var move_speed: int = 3
@export var team: BattleGrid.Team = BattleGrid.Team.PLAYER
@export_file("*.tres") var auto_attack_path: String = "res://scenes/main_gameplay/entity_abilities/basic_attack.tres"
@export_file("*tres") var abilities_paths: Array[String]

var auto_attack: EntityAbility
var abilities: Array[EntityAbility]
var orders: Array[EntityOrder]
var aiming := false
var max_movement := 2

@onready var plan_line: Line2D = $PlanLine
@onready var weapon_area = $WeaponArea
@onready var weapon_collision = $WeaponArea/Area2D

func _ready() -> void:
	auto_attack = load(auto_attack_path)
	for path in abilities_paths:
		abilities.append(load(path))

func _process(delta: float) -> void:
	if aiming:
		var dir = get_global_mouse_position() - position
		weapon_area.rotation = atan2(-dir.x, dir.y)

func execute_turn_async() -> void:
	if not orders.is_empty() and orders[0].can_perform(self):
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

func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, max_health)
	if health <= 0:
		_on_death()

func _on_death() -> void:
	print("Mr. Stark, I don't feel so good.")

func _update_plan_visuals() -> void:
	plan_line.clear_points()
	plan_line.add_point(Vector2.ZERO)
	for order in orders:
		if order.type == EntityOrder.OrderType.MOVEMENT:
			plan_line.add_point(battle_grid.get_cell_center(order.target_pos) - position)

func on_selected():
	aiming = true

func on_deselected():
	aiming = false
