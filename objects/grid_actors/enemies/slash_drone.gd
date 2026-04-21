extends EntityBody

@export var damage = 1

func _ready() -> void:
	mugshot = load("res://assets/textures/characters/horse_small.png")
	super._ready()

func start_turn() -> void:
	var players = battle_grid.get_entities().filter(func (a): return a.team == BattleGrid.Team.PLAYER)
	players.sort_custom(func (a, b):
		var ad = Vector2(a.grid_position).distance_squared_to(Vector2(grid_position))
		var bd = Vector2(b.grid_position).distance_squared_to(Vector2(grid_position))
		return ad < bd
	)
	
	var target = players[0] if not players.is_empty() else null
	
	if target == null:
		print("you lose")
		return
	
	var move_speed_tmp = move_speed
	
	var target_pos = Vector2i(
		(Vector2(target.grid_position) - Vector2(grid_position))
		.limit_length(move_speed_tmp)
		.round()
		+ Vector2(grid_position))
	
	while target_pos != grid_position and battle_grid.get_occupant(target_pos) != null and move_speed_tmp > 0.0:
		move_speed_tmp = maxf(move_speed_tmp - 1.0, 0.0)
		target_pos = Vector2i(
			(Vector2(target.grid_position) - Vector2(grid_position))
			.limit_length(move_speed_tmp)
			.round()
			+ Vector2(grid_position))
	
	var target_dir = (Vector2(target.grid_position) - Vector2(grid_position)).normalized()
	
	var order = EntityOrder.new()
	order.ability = $AttackAbility
	order.params = {
		target_pos = target_pos,
		target_dir = target_dir,
	}
	
	orders = [order]
