extends EntityBody

@export var damage = 1

var train_target = null

func _ready() -> void:
	mugshot = load("res://assets/textures/characters/shooter_small.png")
	float_animation_player.play("float")
	
	match randi_range(0, 2):
		0:
			train_target = $"../../Engine"
		1:
			train_target = $"../../FlatBed"
		2:
			train_target = $"../../Caboose"

func start_turn() -> void:
	var order = EntityOrder.new()
	order.ability = $ShootAttackAbility
	order.params = {
		train_target = train_target
	}
	
	orders = [order]

func _on_death() -> void:
	print("ALAMO")
	clear_plan_visuals()
	queue_free()
