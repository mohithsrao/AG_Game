# routing_component.gd
class_name RoutingComponent
extends Node

## Executes pathing strategies to calculate target waypoints for minions.

@export var strategy: RoutingStrategy

func set_strategy(new_strategy: RoutingStrategy) -> void:
	strategy = new_strategy

func get_waypoint(pos: Vector2, target: Vector2) -> Vector2:
	if is_instance_valid(strategy):
		return strategy.get_next_waypoint(pos, target)
	return target


