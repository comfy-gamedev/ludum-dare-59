extends GridBody
class_name EntityBody


@export var max_health: int = 3
@export var health: int = 3
@export var move_speed: int = 3
@export var team: BattleGrid.Team = BattleGrid.Team.PLAYER

var abilities: Array[EntityAbility]
var orders: Array[EntityOrder]

@onready var plan_line: Line2D = $PlanLine

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

func clear_moves() -> void:
	orders = []
	_update_plan_visuals()

func _update_plan_visuals() -> void:
	plan_line.clear_points()
	plan_line.add_point(Vector2.ZERO)
	for order in orders:
		if order.type == EntityOrder.OrderType.MOVEMENT:
			plan_line.add_point(battle_grid.get_cell_center(order.target_pos) - position)
