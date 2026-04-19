extends Node2D

@onready var indicator_box = $SelectionBox

@export var grid_pos : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	indicator_box.visible = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	indicator_box.visible = false
