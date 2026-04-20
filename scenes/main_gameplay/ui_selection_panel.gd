extends Panel

const MUGSHOT_PADDING_LEFT: float = 4
const MUGSHOT_PADDING_RIGHT: float = 4
const MUGSHOT_PADDING_TOP: float = 6
const MUGSHOT_PADDING_BOTTOM: float = 5

@onready var mugshot_panel: PanelContainer = $MugshotPanel
@onready var mugshot: TextureRect = $MugshotPanel/Mugshot

var selected_entity: EntityBody

func set_selected_entity(ent: EntityBody) -> void:
	if not ent:
		selected_entity = null
		hide()
		mugshot_panel.hide()
	elif selected_entity != ent:
		selected_entity = ent
		
		
		
		if selected_entity.mugshot:
			var panel_size := ent.mugshot.get_size() + Vector2(MUGSHOT_PADDING_LEFT + MUGSHOT_PADDING_RIGHT, MUGSHOT_PADDING_TOP + MUGSHOT_PADDING_BOTTOM)
			mugshot.texture = ent.mugshot
			mugshot_panel.size = panel_size
			mugshot_panel.position = Vector2(mugshot_panel.position.x, 16 - panel_size.y)
			mugshot.position = Vector2(MUGSHOT_PADDING_LEFT, MUGSHOT_PADDING_TOP)
			mugshot_panel.show()
		else:
			mugshot_panel.hide()
		
		show()
