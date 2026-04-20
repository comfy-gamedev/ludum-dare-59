extends Node2D

signal process(delta: float)

func _process(delta: float) -> void:
	process.emit(delta)
