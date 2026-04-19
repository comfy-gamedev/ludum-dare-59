extends EntityAbility
class_name AttackAbility

@export var damage: int = 1

func execute_async(entity: EntityBody) -> void:
	var attacked: Array[EntityBody]
	for ent in entity.get_entities_in_range():
		if not ent in attacked:
			ent.take_damage(damage)
			attacked.append(ent)
