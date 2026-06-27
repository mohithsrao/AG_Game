# strategy_direct.gd
class_name StrategyDirect
extends RoutingStrategy

## Direct Routing Strategy: Moves the minion in a straight line directly to the target.

func get_next_velocity(pos: Vector2, target: Vector2, speed: float, _delta: float) -> Vector2:
	return pos.direction_to(target) * speed
