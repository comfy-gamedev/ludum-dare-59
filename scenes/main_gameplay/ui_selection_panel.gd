extends Panel


@onready var mugshot_panel: PanelContainer = $MugshotPanel
@onready var mugshot: TextureRect = $MugshotPanel/Mugshot
@onready var health_bar: TextureProgressBar = $StatsPanel/MarginContainer/StatsList/HealthContainer/HealthProgressBar
@onready var health_label: Label = $StatsPanel/MarginContainer/StatsList/HealthContainer/HealthProgressBar/MarginContainer/HealthLabel
@onready var move_label: Label = $StatsPanel/MarginContainer/StatsList/MoveLabel

var selected_entity: EntityBody
var mouse_duck_rect: Rect2
var original_position: Vector2

func _ready() -> void:
	original_position = position
	mouse_duck_rect = Rect2(global_position - Vector2(0, 50), Vector2(160, size.y + 50))

func _process(delta: float) -> void:
	if visible:
		if mouse_duck_rect.has_point(get_global_mouse_position()):
			position = original_position + Vector2(0, size.y)
		else:
			position = original_position

func set_selected_entity(ent: EntityBody) -> void:
	if not ent:
		selected_entity = null
		hide()
	elif selected_entity != ent:
		selected_entity = ent
		
		health_bar.max_value = ent.max_health
		health_bar.value = ent.health
		health_label.text = "%d/%d" % [ent.health, ent.max_health]
		move_label.text = "Movement %d" % ent.move_speed
		
		if selected_entity.mugshot:
			var panel_size := ent.mugshot.get_size()
			mugshot.texture = ent.mugshot
			mugshot_panel.size = panel_size
			mugshot_panel.position = Vector2(mugshot_panel.position.x, 44 - panel_size.y)
			mugshot.show()
		else:
			mugshot.hide()
			mugshot_panel.size = Vector2(120, 120)
			mugshot_panel.position = Vector2(mugshot_panel.position.x, -76)
		
		show()
