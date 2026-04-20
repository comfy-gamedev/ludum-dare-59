extends Panel

signal go_button_pressed()

@export var main_gameplay: MainGameplay

@onready var turn_button: Button = %TurnButton
@onready var train_health_bar: NinePatchRect = $TrainHealthBarBack/TrainHealthBar

var health_bar_max_size: float

func _ready() -> void:
	health_bar_max_size = train_health_bar.size.y

func _on_turn_button_pressed() -> void:
	go_button_pressed.emit()

func set_train_hp_bar(progress: float) -> void:
	train_health_bar.size = Vector2(train_health_bar.size.x, health_bar_max_size * progress)
	train_health_bar.position = Vector2(1, 1 + health_bar_max_size * (1 - progress))
