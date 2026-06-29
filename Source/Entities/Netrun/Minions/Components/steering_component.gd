# steering_component.gd
class_name SteeringComponent
extends Node

## Reusable steering component to compute velocity and movement offsets.

enum NoiseStyle {
	SINE,
	GLITCH_SAWTOOTH,
	RANDOM_WALK,
	SQUARE_WAVE
}

enum VelocityMode {
	CONSTANT_FORWARD_SPEED,
	CONSTANT_TRAVEL_SPEED
}

@export var amplitude: float = 0.0
@export var frequency: float = 0.02
@export var phase_offset: float = 0.0
@export var damping_near_target: float = 50.0
@export var noise_style: NoiseStyle = NoiseStyle.SINE
@export var velocity_mode: VelocityMode = VelocityMode.CONSTANT_FORWARD_SPEED

func _ready() -> void:
	# Randomize phase offset on spawn to prevent synchronized wiggling
	phase_offset = randf_range(0.0, 2.0 * PI)

func calculate_velocity(pos: Vector2, waypoint: Vector2, base_speed: float, _delta: float) -> Vector2:
	if pos.distance_to(waypoint) < 10.0:
		return pos.direction_to(waypoint) * base_speed
		
	var target_dir: Vector2 = pos.direction_to(waypoint)
	
	if amplitude <= 0.0:
		return target_dir * base_speed
		
	var perpendicular_dir: Vector2 = Vector2(-target_dir.y, target_dir.x)
	
	# Determine base wave value in range [-1.0, 1.0]
	var current_time: float = float(Time.get_ticks_msec())
	var t: float = (current_time * frequency) + phase_offset
	var wave: float = 0.0
	
	match noise_style:
		NoiseStyle.SINE:
			wave = sin(t)
		NoiseStyle.GLITCH_SAWTOOTH:
			# Sawtooth wave in range [-1.0, 1.0]
			var normalized_t: float = t / (2.0 * PI)
			wave = 2.0 * (normalized_t - floor(normalized_t + 0.5))
		NoiseStyle.RANDOM_WALK:
			# Pseudo-random Perlin-like 1D noise
			wave = (sin(t) + 0.5 * sin(2.3 * t) + 0.25 * sin(4.7 * t)) / 1.75
		NoiseStyle.SQUARE_WAVE:
			wave = sign(sin(t))
			if wave == 0.0:
				wave = 1.0
				
	var jitter_offset: float = wave * amplitude
	
	# Damping near target
	var dist: float = pos.distance_to(waypoint)
	if dist < damping_near_target and damping_near_target > 0.0:
		var factor: float = dist / damping_near_target
		jitter_offset *= factor
		
	var target_vel: Vector2 = Vector2.ZERO
	if velocity_mode == VelocityMode.CONSTANT_FORWARD_SPEED:
		target_vel = (target_dir * base_speed) + (perpendicular_dir * jitter_offset)
	else:
		var combined: Vector2 = (target_dir * base_speed) + (perpendicular_dir * jitter_offset)
		target_vel = combined.normalized() * base_speed
		
	return target_vel
