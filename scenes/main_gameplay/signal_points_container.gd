extends VBoxContainer

@export var main_gameplay: MainGameplay

func _ready() -> void:
	_on_main_gameplay_player_signal_points_changed()



func _on_main_gameplay_player_signal_points_changed() -> void:
	for i in 3:
		get_child(i).visible = i < main_gameplay.player_signal_points
