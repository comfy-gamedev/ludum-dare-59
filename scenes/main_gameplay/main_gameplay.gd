extends Node2D

@onready var actor: GridBody = $BattleGrid/actor

func _on_battle_grid_cell_clicked(grid_pos: Vector2i) -> void:
	actor.grid_position = grid_pos
