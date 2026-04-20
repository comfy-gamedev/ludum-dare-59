extends GridBody

@export var max_health: int = 1
@export var health: int = 1
@export var move_speed: int = 3
@export var team: BattleGrid.Team = BattleGrid.Team.ENEMY
@export var damage = 1

var train_target = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match randi_range(0, 2):
		0:
			train_target = $"../../Engine"
		1:
			train_target = $"../../FlatBed"
		2:
			train_target = $"../../Caboose"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func execute_turn_async() -> void:
	var target = train_target.get_tiles().reduce(func(x, a): return x if abs(x - grid_position) < abs(a - grid_position) else a)
	var x_sign = sign(target.x - grid_position.x)
	if not battle_grid.get_occupant(grid_position + Vector2i(x_sign, 0)):
		grid_position += Vector2i(x_sign, 0)
	else:
		battle_grid.get_occupant(grid_position + Vector2i(x_sign, 0)).take_damage(damage)
		#take_damage(damage)
	
	var y_sign = sign(target.y - grid_position.y)
	if not battle_grid.get_occupant(grid_position + Vector2i(0, y_sign)):
		grid_position += Vector2i(0, y_sign)
	else:
		battle_grid.get_occupant(grid_position + Vector2i(0, y_sign)).take_damage(damage)
		#take_damage(damage)

func _on_death() -> void:
	print("BLAMO")
	queue_free()

func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, max_health)
	if health <= 0:
		_on_death()
