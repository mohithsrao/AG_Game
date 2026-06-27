# strategy_jitter.gd
class_name StrategyJitter
extends RoutingStrategy

## Jitter Routing Strategy: Applies a sine wave offset perpendicular to the target path.

@export var amplitude: float = 120.0
@export var frequency: float = 0.02

func get_next_velocity(pos: Vector2, target: Vector2, speed: float, _delta: float) -> Vector2:
	if pos.distance_to(target) < 10.0:
		return pos.direction_to(target) * speed
		
	var target_dir: Vector2 = pos.direction_to(target)
	var perpendicular_dir: Vector2 = Vector2(-target_dir.y, target_dir.x)
	
	# Apply sine wave jitter to create packet noise movement
	var jitter_offset: float = sin(Time.get_ticks_msec() * frequency) * amplitude
	return (target_dir * speed) + (perpendicular_dir * jitter_offset)
