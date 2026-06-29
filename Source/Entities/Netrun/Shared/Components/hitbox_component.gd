# hitbox_component.gd
class_name HitboxComponent
extends Area2D

## Collision area representing the damageable zone of an entity.
## Forwards damage events to the associated HealthComponent.

@export var health_component: HealthComponent

func take_damage(amount: float) -> void:
	if is_instance_valid(health_component):
		health_component.take_damage(amount)
