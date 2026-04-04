extends LimboState


func _setup() -> void:
	add_event_handler("collision", _on_collision)

func _on_collision(cargo = null) -> bool:
	if randi_range(0, 3) == 0:
		dispatch(EVENT_FINISHED)
	return false
