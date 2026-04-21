extends VBoxContainer

var main_gameplay: MainGameplay

func _ready() -> void:
	main_gameplay = owner.main_gameplay
	main_gameplay.player_signal_points_changed.connect(_on_main_gameplay_player_signal_points_changed)
	_on_main_gameplay_player_signal_points_changed()


func _on_main_gameplay_player_signal_points_changed() -> void:
	for i in 3:
		get_child(i).get_child(0).visible = i < main_gameplay.player_signal_points
