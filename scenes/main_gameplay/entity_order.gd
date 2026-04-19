extends RefCounted
class_name EntityOrder

enum OrderType {
	MOVEMENT,
	ABILITY,
}

@export var type: OrderType
@export var target_pos: Vector2i
@export var target_dir: Vector2

var ability: EntityAbility

func can_perform(_entity: EntityBody) -> bool:
	return true

func execute_async(entity: EntityBody) -> void:
	match type:
		OrderType.MOVEMENT:
			await entity.set_grid_position(target_pos)
		OrderType.ABILITY:
			await ability.execute_async(entity)
