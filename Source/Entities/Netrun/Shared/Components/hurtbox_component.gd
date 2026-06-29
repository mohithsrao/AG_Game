# hurtbox_component.gd
class_name HurtboxComponent
extends Area2D

## Collision area representing the damage-dealing zone of an entity.
## Applies damage to HitboxComponents upon overlap.

@export var damage_amount: float = 10.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		(area as HitboxComponent).take_damage(damage_amount)
