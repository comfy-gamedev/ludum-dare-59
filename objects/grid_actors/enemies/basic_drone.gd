extends EntityBody

var target = Vector2i(7, 7)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func execute_turn_async() -> void:
	var x_sign = sign(target.x - grid_position.x)
	if not battle_grid.get_occupant(grid_position + Vector2i(x_sign, 0)):
		grid_position += Vector2i(x_sign, 0)
	
	var y_sign = sign(target.y - grid_position.y)
	if not battle_grid.get_occupant(grid_position + Vector2i(y_sign, 0)):
		grid_position += Vector2i(0, y_sign)

func _on_death() -> void:
	print("BLAMO")
	queue_free()
