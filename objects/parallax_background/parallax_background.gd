extends Parallax2D

@onready var middle_straight_scene = preload("res://objects/terrains/middle_straight/middle_straight.tscn")

func _ready():
	var middle_straight = middle_straight_scene.instantiate()
	self.add_child(middle_straight)
