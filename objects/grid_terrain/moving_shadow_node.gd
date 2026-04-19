extends GridTerrain

@onready var spawn_area = $Area2D

@export var dir = Vector2i(3, 0)

func perform_turn() -> void:
	lifetime -= 1
	if lifetime < 1:
		queue_free()
	
	var tiles = spawn_area.get_overlapping_areas()
	for i in tiles:
		var new_node = transformation_target.instantiate()
		new_node.grid_position = i.get_parent().grid_pos
		get_parent().add_child(new_node)
	
	grid_position += dir
