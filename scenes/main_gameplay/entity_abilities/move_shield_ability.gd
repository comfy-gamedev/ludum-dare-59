extends EntityAbility
class_name ShieldAbility

@export var damage: int = 1
@onready var attack_area = $WeaponArea/Area2D
@onready var weapon_area = $WeaponArea
@onready var attack_animation_player: AnimationPlayer = $AttackAnimationPlayer

func _ready() -> void:
	weapon_area.show()

func display_name() -> String:
	return "MoveGuard"

func input_async(entity: EntityBody, battle_grid: BattleGrid) -> EntityOrder:
	entity.state = EntityBody.EntityState.PLANNING_MOVE
	attack_area.monitorable = true
	
	var move_clicked = await battle_grid.cell_clicked
	var move_grid_pos = move_clicked[0]
	var move_click_button = move_clicked[1]
	while move_click_button == BattleGrid.CLICK_PRIMARY and not entity.cell_in_range(move_grid_pos):
		move_clicked = await battle_grid.cell_clicked
		move_grid_pos = move_clicked[0]
		move_click_button = move_clicked[1]
	
	if move_click_button == BattleGrid.CLICK_SECONDARY:
		return null
	
	var preview = entity.create_preview_visuals()
	var preview_area = self.duplicate(0)
	preview_area.visible = true
	preview.add_child(preview_area)
	
	preview.position = entity.battle_grid.get_cell_center(move_grid_pos)
	
	preview.process.connect(func (_delta):
		var dir = preview.get_global_mouse_position() - preview.position
		preview_area.rotation = atan2(dir.y, dir.x)
	)
	
	entity.state = EntityBody.EntityState.PLANNING_AIM
	var dir_click = await battle_grid.cell_clicked
	
	if dir_click[1] == BattleGrid.CLICK_SECONDARY:
		return null
	
	var target_dir = get_global_mouse_position() - battle_grid.get_cell_center(move_grid_pos)
	
	entity.clear_plan_visuals()
	
	var order = EntityOrder.new()
	order.ability = self
	order.params = { target_pos = move_grid_pos, target_dir = target_dir }
	
	attack_area.monitorable = false
	return order

func execute_movement_async(entity: EntityBody, params: Dictionary) -> void:
	entity.clear_plan_visuals()
	await entity.set_grid_position(params.target_pos)

func execute_async(entity: EntityBody, params: Dictionary) -> void:
	rotation = atan2(params.target_dir.y, params.target_dir.x)
	
	attack_animation_player.play(&"shoot")
	
	var tween = create_tween()
	tween.tween_property(entity.sprite, "offset", params.target_dir.normalized() * 3, 0.04)
	tween.tween_property(entity.sprite, "offset", Vector2.ZERO, 0.16)
	await tween.finished
	
	for tile_area in get_node("WeaponArea/Area2D").get_overlapping_areas():
		var coord = tile_area.get_parent().grid_pos
		var occupant = entity.battle_grid.get_occupant(coord)
		if occupant:
			occupant.take_damage(damage)

func update_preview(entity: EntityBody, params: Dictionary) -> void:
	entity.plan_line.add_point(Vector2(params.target_pos - entity.grid_position) * entity.battle_grid.CELL_SIZE)
	
	var preview = entity.create_preview_visuals()
	var preview_area = self.duplicate(0)
	preview_area.visible = true
	preview.add_child(preview_area)
	
	preview.position = entity.battle_grid.get_cell_center(params.target_pos)
	preview_area.rotation = atan2(params.target_dir.y, params.target_dir.x)

func on_cancel(entity: EntityBody) -> void:
	entity._update_plan_visuals()
