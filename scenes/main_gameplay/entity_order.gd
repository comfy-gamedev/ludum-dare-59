extends RefCounted
class_name EntityOrder

enum OrderType {
	MOVEMENT,
	ACTION
}

signal order_done

@export var type: OrderType
@export var done := false

func execute(entity: EntityBody) -> void:
	done = true
	order_done.emit()
