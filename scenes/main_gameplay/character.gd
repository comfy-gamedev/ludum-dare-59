extends BouncingCharacterBody2D

const SPEED = 300.0
const COLLISION = &"collision"

@onready var hsm: LimboHSM = $LimboHSM
@onready var normal_state: LimboState = $LimboHSM/NormalState
@onready var crazy_state: LimboState = $LimboHSM/CrazyState

func _ready() -> void:
	velocity = Vector2.ONE * SPEED
	hsm.add_transition(normal_state, crazy_state, normal_state.EVENT_FINISHED)
	hsm.add_transition(crazy_state, normal_state, COLLISION)
	hsm.initialize(self)
	hsm.set_active(true)

func _physics_process(_delta: float) -> void:
	move_and_bounce()

# Called when move_and_bounce() collides with something.
# Return true to stop further motion processing.
func _on_bounce(_col: KinematicCollision2D) -> bool:
	return false

# Called when colliding with something for any reason.
func _collision(_other: PhysicsBody2D) -> void:
	hsm.dispatch(COLLISION)
	Globals.player_health -= 1


func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	print("_on_limbo_hsm_active_state_changed(%s, %s)" % [current, previous])
