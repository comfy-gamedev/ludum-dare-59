extends Panel

signal go_button_pressed()

@export var main_gameplay: MainGameplay

@onready var turn_button: Button = %TurnButton
@onready var engine_health_bar: NinePatchRect = $TrainHealthContainer/EngineHealthBarBack/EngineHealthBar
@onready var flatbead_health_bar: NinePatchRect = $TrainHealthContainer/FlatbeadHealthBarBack/FlatbeadHealthBar
@onready var caboose_health_bar: NinePatchRect = $TrainHealthContainer/CabooseHealthBarBack/CabooseHealthBar

var health_bar_max_size: float

func _ready() -> void:
	health_bar_max_size = engine_health_bar.size.y
	
	Globals.engine_health_changed.connect(set_engine_hp_bar)
	Globals.flatbead_health_changed.connect(set_flatbead_hp_bar)
	Globals.caboose_health_changed.connect(set_caboose_hp_bar)

func _on_turn_button_pressed() -> void:
	go_button_pressed.emit()

func set_engine_hp_bar(progress: float) -> void:
	engine_health_bar.size = Vector2(engine_health_bar.size.x, health_bar_max_size * progress)
	engine_health_bar.position = Vector2(1, 1 + health_bar_max_size * (1 - progress))

func set_flatbead_hp_bar(progress: float) -> void:
	flatbead_health_bar.size = Vector2(flatbead_health_bar.size.x, health_bar_max_size * progress)
	flatbead_health_bar.position = Vector2(1, 1 + health_bar_max_size * (1 - progress))

func set_caboose_hp_bar(progress: float) -> void:
	caboose_health_bar.size = Vector2(caboose_health_bar.size.x, health_bar_max_size * progress)
	caboose_health_bar.position = Vector2(1, 1 + health_bar_max_size * (1 - progress))
