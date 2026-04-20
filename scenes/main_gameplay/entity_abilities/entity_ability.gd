@abstract
extends Node2D
class_name EntityAbility

@abstract func display_name() -> String

@abstract func input_async(entity: EntityBody, battle_grid: BattleGrid) -> EntityOrder

@abstract func execute_async(entity: EntityBody, params: Dictionary) -> void

@abstract func update_preview(entity: EntityBody, params: Dictionary) -> void

@abstract func on_cancel(entity: EntityBody) -> void
