# strategy_jitter.gd
class_name StrategyJitter
extends RoutingStrategy

## Jitter Routing Strategy: Holds parameters for jitter movement.

@export var amplitude: float = 120.0
@export var frequency: float = 0.02
@export var damping_near_target: float = 50.0
@export var velocity_mode: int = 0 # 0 for CONSTANT_FORWARD_SPEED, 1 for CONSTANT_TRAVEL_SPEED

func get_next_waypoint(_pos: Vector2, target: Vector2) -> Vector2:
	return target

