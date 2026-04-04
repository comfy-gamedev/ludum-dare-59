extends LimboState

func _enter() -> void:
	agent.draw.connect(_on_agent_draw)

func _exit() -> void:
	agent.draw.disconnect(_on_agent_draw)

func _on_agent_draw() -> void:
	var points = PackedVector2Array()
	for i in 50:
		points.append(Vector2(randf_range(-32, 32), randf_range(-32, 32)))
	agent.draw_polyline(points, Color.RED, 2.0, false)
