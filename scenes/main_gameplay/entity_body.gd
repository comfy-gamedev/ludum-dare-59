extends GridBody
class_name EntityBody

enum EntityState {
	DESELECTED,
	PLANNING_MENU,
	PLANNING_MOVE,
	PLANNING_AIM,
	PLANNING_AOE
}

@export var max_health: int = 3
@export var health: int = 3
@export var move_speed: int = 3
@export var team: BattleGrid.Team = BattleGrid.Team.PLAYER

var abilities: Array[EntityAbility]
var orders: Array
var future_orders: Array[Array]
var turn_done := false
var turn_end_grid_pos: Vector2i
var state: EntityState = EntityState.DESELECTED: set = _set_state
var turn_end_previews: Array[Node2D]
var last_mouse_over_grid: Vector2i = Vector2i(-1, -1)
var preview_line: Line2D

@onready var plan_line: Line2D = $PlanLine
@onready var sprite = $Sprite2D
@onready var float_animation_player: AnimationPlayer = $FloatAnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var healing_effect_sprite: AnimatedSprite2D = $HealingEffectSprite2D

func _ready() -> void:
	for c in get_children():
		if c is EntityAbility:
			abilities.append(c)
			c.visible = false
	float_animation_player.play("float")
	battle_grid.mouse_over_cell_changed.connect(_on_grid_mouse_move)

func _on_grid_mouse_move(mouse_grid_pos: Vector2i) -> void:
	if state == EntityState.PLANNING_MOVE and cell_in_range(mouse_grid_pos):
		if not preview_line:
			preview_line = plan_line.duplicate()
			add_child(preview_line)
		preview_line.clear_points()
		if turn_done:
			preview_line.add_point(Vector2(turn_end_grid_pos - grid_position) * battle_grid.CELL_SIZE)
		else:
			preview_line.add_point(Vector2.ZERO)
		preview_line.add_point(Vector2(mouse_grid_pos - grid_position) * battle_grid.CELL_SIZE)
	elif preview_line:
		preview_line.clear_points()

func execute_turn_async() -> void:
	while not orders.is_empty():
		await orders[0].ability.execute_async(self, orders[0].params)
		orders.remove_at(0)
	
	if not future_orders.is_empty():
		orders = future_orders.pop_front()
		turn_done = true
	else:
		turn_done = false
	
	_update_plan_visuals()

func plan_order(order: EntityOrder, turn_index: int = 0) -> void:
	if turn_index == 0:
		orders.append(order)
	else:
		var indexed_turn_orders = future_orders.get(turn_index - 1)
		if not indexed_turn_orders:
			future_orders.push_back([])
			indexed_turn_orders = future_orders.back()
		indexed_turn_orders.append(order)
	
	# If very last order, update turn_end_grid_pos
	if turn_index >= future_orders.size() and "target_pos" in order.params:
		turn_end_grid_pos = order.params.target_pos
	
	_update_plan_visuals()

func clear_orders() -> void:
	orders.clear()
	future_orders.clear()
	turn_end_grid_pos = grid_position
	_update_plan_visuals()

func cell_in_range(cell_pos: Vector2i) -> bool:
	var of_cell := grid_position
	if turn_done: of_cell = turn_end_grid_pos
	return of_cell.distance_to(cell_pos) <= move_speed

func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, max_health)
	if health <= 0:
		_on_death()
	elif effect_animation_player:
		effect_animation_player.play("hurt")

func heal(amount: int) -> void:
	health = clampi(health + amount, 0, max_health)
	
	if healing_effect_sprite:
		healing_effect_sprite.play()

func create_preview_visuals() -> Node2D:
	var preview = Node2D.new()
	preview.script = preload("uid://ba7rss64n18kc")
	var preview_sprite = sprite.duplicate()
	preview_sprite.position.y = 0
	preview_sprite.speed_scale = 0
	preview_sprite.modulate = Color8(255, 255, 255, 100)
	preview.add_child(preview_sprite)
	get_parent().add_child(preview)
	turn_end_previews.append(preview)
	return preview

func clear_plan_visuals() -> void:
	if plan_line:
		plan_line.clear_points()
		plan_line.add_point(Vector2.ZERO)
	while not turn_end_previews.is_empty():
		var back_preview = turn_end_previews.pop_back()
		if is_instance_valid(back_preview):
			back_preview.queue_free()

func _set_state(value: EntityState) -> void:
	state = value
	match value:
		EntityState.PLANNING_MOVE, EntityState.PLANNING_MENU:
			if turn_done:
				battle_grid.show_movement_range(turn_end_grid_pos, move_speed)
			else:
				battle_grid.show_movement_range(grid_position, move_speed)
		_:
			battle_grid.hide_movement_range()

func _on_death() -> void:
	print("Mr. Stark, I don't feel so good.")
	queue_free()

func _update_plan_visuals() -> void:
	clear_plan_visuals()
	var all_orders = orders.duplicate()
	for order_arr in future_orders:
		all_orders.append_array(order_arr)
	for order in all_orders:
		order.ability.update_preview(self, order.params)

func on_selected():
	_set_state(EntityState.PLANNING_MENU)

func on_deselected():
	_set_state(EntityState.DESELECTED)
