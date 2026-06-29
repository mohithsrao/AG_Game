# routing_strategy.gd
class_name RoutingStrategy
extends Resource

## Abstract base class for custom minion routing behaviors.

func get_next_velocity(pos: Vector2, target: Vector2, speed: float, delta: float) -> Vector2:
	return Vector2.ZERO
