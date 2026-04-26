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
	
	Globals.engine_health_changed.connect(func(progress: float): set_train_hp_bar(engine_health_bar, progress))
	Globals.flatbead_health_changed.connect(func(progress: float): set_train_hp_bar(flatbead_health_bar, progress))
	Globals.caboose_health_changed.connect(func(progress: float): set_train_hp_bar(caboose_health_bar, progress))

func _on_turn_button_pressed() -> void:
	go_button_pressed.emit()

func set_train_hp_bar(bar: NinePatchRect, progress: float) -> void:
	var new_bar_size_y: float = health_bar_max_size * progress
	if new_bar_size_y < 4:
		bar.hide()
		return
	
	bar.show()
	bar.size = Vector2(bar.size.x, health_bar_max_size * progress)
	bar.position = Vector2(1, 1 + health_bar_max_size * (1 - progress))
