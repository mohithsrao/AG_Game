# strategy_direct.gd
class_name StrategyDirect
extends RoutingStrategy

## Direct Routing Strategy: Moves the minion in a straight line directly to the target.

func get_next_waypoint(_pos: Vector2, target: Vector2) -> Vector2:
	return target


