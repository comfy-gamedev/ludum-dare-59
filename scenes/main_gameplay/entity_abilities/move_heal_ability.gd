extends EntityAbility
class_name HealAbility

@export var heal_amount: int = 2
@onready var attack_area = $WeaponArea/Area2D
@onready var weapon_area = $WeaponArea
@onready var weapon_sprite = $WeaponSprite2D
@onready var attack_animation_player: AnimationPlayer = $AttackAnimationPlayer

var healable_tiles: Array[Vector2i] = [
	Vector2i.ZERO,
	Vector2i.RIGHT,
	Vector2i(2, 0),
	Vector2i.DOWN,
	Vector2i(0, 2),
	Vector2i.LEFT,
	Vector2i(-2, 0),
	Vector2i.UP,
	Vector2i(0, -2)
]

func _ready() -> void:
	weapon_area.show()
	weapon_sprite.hide()
	attack_animation_player.animation_finished.connect(func(_anim: StringName):
		weapon_area.show()
		weapon_sprite.hide()
		hide()
	)

func display_name() -> String:
	return "MoveHeal"

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
	preview.add_child(preview_area)
	
	preview.position = entity.battle_grid.get_cell_center(move_grid_pos)
	battle_grid.highlight_cells(healable_tiles, move_grid_pos)
	
	var _on_mouse_over_cell_changed = func(grid_pos: Vector2i) -> void:
		var local_grid_pos := Vector2(grid_pos - move_grid_pos)
		if healable_tiles.has(local_grid_pos):
			preview_area.show()
			preview_area.position = local_grid_pos * battle_grid.CELL_SIZE
		else:
			preview_area.hide()
	battle_grid.mouse_over_cell_changed.connect(_on_mouse_over_cell_changed)
	
	entity.state = EntityBody.EntityState.PLANNING_AOE
	var aoe_click = await battle_grid.cell_clicked
	while move_click_button == BattleGrid.CLICK_PRIMARY and not healable_tiles.has(aoe_click[0] - move_grid_pos):
		aoe_click = await battle_grid.cell_clicked
	
	battle_grid.mouse_over_cell_changed.disconnect(_on_mouse_over_cell_changed)
	battle_grid.clear_highlights()
	
	if aoe_click[1] == BattleGrid.CLICK_SECONDARY:
		return null
	
	entity.clear_plan_visuals()
	
	var order = EntityOrder.new()
	order.ability = self
	order.params = { target_pos = move_grid_pos, aoe_pos = aoe_click[0] }
	
	attack_area.monitorable = false
	return order

func execute_movement_async(entity: EntityBody, params: Dictionary) -> void:
	entity.clear_plan_visuals()
	await entity.set_grid_position(params.target_pos)

func execute_async(entity: EntityBody, params: Dictionary) -> void:
	MainGameplay.current.sf_dialogue.show_character_dialogue(entity.character, SFDialogue.Dialogue.NORMAL_ATTACK)
	
	position = Vector2(params.aoe_pos - params.target_pos) * entity.battle_grid.CELL_SIZE
	
	weapon_area.hide()
	weapon_sprite.show()
	show()
	attack_animation_player.play(&"heal")
	MusicMan.sfx(preload("res://assets/sfx/healEffect.wav")).volume_db = linear_to_db(0.8)
	
	var tween = create_tween()
	if params.aoe_pos == params.target_pos:
		tween.tween_property(entity.sprite, "offset", Vector2.LEFT, 0.1)
		tween.tween_property(entity.sprite, "offset", Vector2.RIGHT, 0.1)
		tween.tween_property(entity.sprite, "offset", Vector2.ZERO, 0.1)
	else:
		tween.tween_property(entity.sprite, "offset", Vector2(params.aoe_pos - params.target_pos).normalized() * 3, 0.04)
		tween.tween_property(entity.sprite, "offset", Vector2.ZERO, 0.16)
	
	await tween.finished
	
	for tile_area in attack_area.get_overlapping_areas():
		var coord = tile_area.get_parent().grid_pos
		var occupant = entity.battle_grid.get_occupant(coord)
		if occupant:
			occupant.heal(heal_amount)

func update_preview(entity: EntityBody, params: Dictionary) -> void:
	entity.plan_line.add_point(Vector2(params.target_pos - entity.grid_position) * entity.battle_grid.CELL_SIZE)
	
	var preview = entity.create_preview_visuals()
	var preview_area = self.duplicate(0)
	preview_area.visible = true
	preview.add_child(preview_area)
	
	preview.position = entity.battle_grid.get_cell_center(params.target_pos)
	preview_area.position = Vector2(params.aoe_pos - params.target_pos) * entity.battle_grid.CELL_SIZE

func on_cancel(entity: EntityBody) -> void:
	entity._update_plan_visuals()
