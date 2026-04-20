extends EntityAbility
class_name ShootAttackAbility

@export var damage: int = 1
@onready var attack_area = $WeaponSprite2D/Area2D
@onready var weapon_sprite = $WeaponSprite2D

var attacking = false
var battle_grid = null
var tween

func _ready() -> void:
	return
	hide()

func display_name() -> String:
	return "ShootAttack"

func input_async(entity: EntityBody, battle_grid: BattleGrid) -> EntityOrder:
	assert(false, "unimplemented")
	return null

func execute_movement_async(entity: EntityBody, params: Dictionary) -> void:
	pass

func execute_async(entity: EntityBody, params: Dictionary) -> void:
	battle_grid = entity.battle_grid
	var train_target = params.train_target
	
	var target : Vector2i = train_target.get_tiles().reduce(func(x, a):
		return x if abs(x - entity.grid_position) < abs(a - entity.grid_position) else a)
	
	#fire
	attacking = true
	weapon_sprite.show()
	attack_area.show()
	tween = create_tween()
	tween.tween_property(weapon_sprite, "position", Vector2((target - entity.grid_position) * 32 * 2), 1.0)
	#tween.tween_property(weapon_sprite, "position", Vector2(target * 32), 1.0)
	await tween.finished
	
	attacking = true
	weapon_sprite.show()
	weapon_sprite.position = Vector2(0, 0)

func update_preview(entity: EntityBody, params: Dictionary) -> void:
	pass

func on_cancel(entity: EntityBody) -> void:
	entity._update_plan_visuals()



func _on_area_2d_area_entered(area: Area2D) -> void:
	if !attacking || !battle_grid:
		return
	
	var coord = area.get_parent().grid_pos
	var occupant = battle_grid.get_occupant(coord, true, false)
	if occupant:
		occupant.take_damage(damage)
		tween.custom_step(100000)
		
