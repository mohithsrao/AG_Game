# routing_component.gd
extends Node

## Executes pathing strategies to calculate velocity vectors for minions.

const RoutingStrategy = preload("res://Entities/Netrun/Shared/Resources/routing_strategy.gd")

@export var strategy: Resource # RoutingStrategy resource

func set_strategy(new_strategy: Resource) -> void:
	strategy = new_strategy

func get_velocity(pos: Vector2, target: Vector2, speed: float, delta: float) -> Vector2:
	if is_instance_valid(strategy) and strategy.has_method("get_next_velocity"):
		return strategy.get_next_velocity(pos, target, speed, delta)
	return pos.direction_to(target) * speed
