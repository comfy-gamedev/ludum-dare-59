extends Panel
class_name CrossingPanel

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sprites: Array[Sprite2D] = [
	$Control/Sprite2D,
	$Control/Sprite2D2,
]
@onready var explosion_vfx: Array[CPUParticles2D] = [
	%ExplosionVFX,
	%ExplosionVFX2,
]

func _ready() -> void:
	visible = false

func play(e1: EntityBody, e2: EntityBody) -> EntityBody:
	sprites[0].texture = e1.crossing_sprite
	sprites[1].texture = e2.crossing_sprite
	
	visible = true
	
	animation_player.play("go")
	await animation_player.animation_finished
	
	var ents = [e1, e2]
	var winner = randi_range(0, 1)
	
	explosion_vfx[1 - winner].emitting = true
	print(explosion_vfx[1 - winner])
	
	animation_player.play("close")
	await animation_player.animation_finished
	print(explosion_vfx[1 - winner].emitting)
	
	explosion_vfx[1 - winner].emitting = false
	
	visible = false
	
	return ents[winner]
