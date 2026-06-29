# routing_strategy.gd
class_name RoutingStrategy
extends Resource

## Abstract base class for custom minion routing behaviors.

func get_next_waypoint(_pos: Vector2, target: Vector2) -> Vector2:
	return target


