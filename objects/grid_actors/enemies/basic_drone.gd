extends EntityBody

@export var damage = 1

var train_target = null
#var mugshot: Texture2D = null

func _ready() -> void:
	mugshot = load("res://assets/textures/characters/drone_small.png")
	super._ready()
	
	train_target = [
		$"../../Engine",
		$"../../FlatBed",
		$"../../Caboose",
	].pick_random()

func start_turn() -> void:
	var order = EntityOrder.new()
	order.ability = $AttackAbility
	order.params = {
		train_target = train_target
	}
	
	orders = [order]
