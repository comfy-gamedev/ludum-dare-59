extends EntityAbility
class_name BumpAttackAbility

@export var damage: int = 1
@onready var attack_area = $Area2D

func _ready() -> void:
	hide()

func display_name() -> String:
	return "BumpSlash"

func input_async(entity: EntityBody, battle_grid: BattleGrid) -> EntityOrder:
	assert(false, "unimplemented")
	return null

func execute_movement_async(entity: EntityBody, params: Dictionary) -> void:
	pass

func execute_async(entity: EntityBody, params: Dictionary) -> void:
	MainGameplay.current.sf_dialogue.show_character_dialogue(entity.character, SFDialogue.Dialogue.NORMAL_ATTACK)
	
	var train_target = params.train_target
	
	var target = train_target.get_tiles().reduce(func(x, a):
		return x if abs(x - entity.grid_position) < abs(a - entity.grid_position) else a)
	
	var x_sign = sign(target.x - entity.grid_position.x)
	if not entity.battle_grid.get_occupant(entity.grid_position + Vector2i(x_sign, 0)):
		entity.grid_position += Vector2i(x_sign, 0)
	else:
		entity.battle_grid.get_occupant(entity.grid_position + Vector2i(x_sign, 0)).take_damage(damage)
		#take_damage(damage)
	
	var y_sign = sign(target.y - entity.grid_position.y)
	if not entity.battle_grid.get_occupant(entity.grid_position + Vector2i(0, y_sign)):
		entity.grid_position += Vector2i(0, y_sign)
	else:
		entity.battle_grid.get_occupant(entity.grid_position + Vector2i(0, y_sign)).take_damage(damage)
		#take_damage(damage)


func update_preview(entity: EntityBody, params: Dictionary) -> void:
	pass

func on_cancel(entity: EntityBody) -> void:
	entity._update_plan_visuals()
