extends GridBody
class_name EntityBody

signal turn_done

@export var max_health: int = 3
@export var health: int = 3
@export var move_speed: int = 3

var move_set: Array[EntityAction]
var order_que: Array[EntityOrder]

func turn_logic() -> void:
	for order in order_que:
		order.execute(self)
		if not order.done: await order.order_done

func execute_turn() -> void:
	pre_turn()
	turn_logic()
	post_turn()
	turn_done.emit()

func pre_turn() -> void:
	# Run all relevant status effects
	pass

func post_turn() -> void:
	# Run all relevant status effects
	pass
