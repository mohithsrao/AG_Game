# tests_steering.gd
extends GutTest

const SteeringComponentScript = preload("../Components/steering_component.gd")

func test_direct_path_when_amplitude_is_zero() -> void:
	var steering = SteeringComponentScript.new()
	add_child_autofree(steering)
	steering.amplitude = 0.0
	
	var pos = Vector2(0, 0)
	var waypoint = Vector2(100, 0)
	var base_speed = 120.0
	
	var velocity = steering.calculate_velocity(pos, waypoint, base_speed, 0.016)
	
	assert_eq(velocity, Vector2(base_speed, 0), "Velocity should be directed straight to waypoint when amplitude is zero")

func test_jitter_sine_wave_calculation() -> void:
	var steering = SteeringComponentScript.new()
	add_child_autofree(steering)
	steering.amplitude = 50.0
	steering.frequency = 1.0
	steering.damping_near_target = 0.0 # disable damping
	steering.noise_style = steering.NoiseStyle.SINE
	steering.velocity_mode = steering.VelocityMode.CONSTANT_FORWARD_SPEED
	steering.phase_offset = 0.0
	
	var pos = Vector2(0, 0)
	var waypoint = Vector2(100, 0) # target_dir is (1, 0), perp_dir is (0, 1)
	var base_speed = 100.0
	
	var velocity = steering.calculate_velocity(pos, waypoint, base_speed, 0.016)
	
	var current_time = float(Time.get_ticks_msec())
	var expected_jitter = sin(current_time) * 50.0
	
	assert_almost_eq(velocity.x, 100.0, 0.001, "Forward velocity should match base speed")
	assert_almost_eq(velocity.y, expected_jitter, 0.001, "Perpendicular velocity should match calculated sine jitter")

func test_phase_offsets() -> void:
	var steering = SteeringComponentScript.new()
	add_child_autofree(steering)
	
	assert_true(steering.phase_offset >= 0.0 and steering.phase_offset <= 2.0 * PI, "Phase offset should be initialized in range [0, 2*PI]")

func test_velocity_normalization_constant_forward_speed() -> void:
	var steering = SteeringComponentScript.new()
	add_child_autofree(steering)
	steering.amplitude = 100.0
	steering.frequency = 0.02
	steering.damping_near_target = 0.0
	steering.velocity_mode = steering.VelocityMode.CONSTANT_FORWARD_SPEED
	
	var pos = Vector2(0, 0)
	var waypoint = Vector2(500, 0)
	var base_speed = 100.0
	
	var velocity = steering.calculate_velocity(pos, waypoint, base_speed, 0.016)
	
	assert_almost_eq(velocity.x, base_speed, 0.001, "Forward velocity component should be exactly base_speed")

func test_velocity_normalization_constant_travel_speed() -> void:
	var steering = SteeringComponentScript.new()
	add_child_autofree(steering)
	steering.amplitude = 100.0
	steering.frequency = 0.02
	steering.damping_near_target = 0.0
	steering.velocity_mode = steering.VelocityMode.CONSTANT_TRAVEL_SPEED
	
	var pos = Vector2(0, 0)
	var waypoint = Vector2(500, 0)
	var base_speed = 100.0
	
	var velocity = steering.calculate_velocity(pos, waypoint, base_speed, 0.016)
	
	assert_almost_eq(velocity.length(), base_speed, 0.001, "Overall velocity magnitude should be normalized to base_speed")

func test_proximity_damping() -> void:
	var steering = SteeringComponentScript.new()
	add_child_autofree(steering)
	steering.amplitude = 100.0
	steering.frequency = 0.0
	steering.damping_near_target = 100.0
	steering.velocity_mode = steering.VelocityMode.CONSTANT_FORWARD_SPEED
	steering.phase_offset = PI / 2.0 # sin(PI/2) = 1.0
	
	var base_speed = 100.0
	
	# Case 1: far from target (dist = 200 > 100 damping threshold). No damping.
	var pos_far = Vector2(0, 0)
	var waypoint_far = Vector2(200, 0)
	var vel_far = steering.calculate_velocity(pos_far, waypoint_far, base_speed, 0.016)
	assert_almost_eq(vel_far.y, 100.0, 0.001, "At distance > damping threshold, jitter should be at max amplitude")
	
	# Case 2: close to target (dist = 50 < 100 damping threshold). Jitter should be damped by factor dist/damping = 50/100 = 0.5.
	var pos_close = Vector2(150, 0)
	var vel_close = steering.calculate_velocity(pos_close, waypoint_far, base_speed, 0.016)
	assert_almost_eq(vel_close.y, 50.0, 0.001, "At distance < damping threshold, jitter amplitude should scale down linearly")
	
	# Case 3: very close (dist < 10.0). Should return direct path to target.
	var pos_very_close = Vector2(195, 0)
	var vel_very_close = steering.calculate_velocity(pos_very_close, waypoint_far, base_speed, 0.016)
	assert_eq(vel_very_close, Vector2(base_speed, 0), "At distance < 10.0, should return direct path without perpendicular jitter")

func test_noise_styles() -> void:
	var steering = SteeringComponentScript.new()
	add_child_autofree(steering)
	steering.amplitude = 10.0
	steering.frequency = 0.0
	steering.damping_near_target = 0.0
	steering.velocity_mode = steering.VelocityMode.CONSTANT_FORWARD_SPEED
	
	var pos = Vector2(0, 0)
	var waypoint = Vector2(100, 0)
	var base_speed = 100.0
	
	# Test Square Wave
	steering.noise_style = steering.NoiseStyle.SQUARE_WAVE
	steering.phase_offset = PI / 2.0 # sin(PI/2) = 1.0 -> sign is 1.0
	var vel_square = steering.calculate_velocity(pos, waypoint, base_speed, 0.016)
	assert_almost_eq(vel_square.y, 10.0, 0.001, "Square wave value should be sign of sin")
	
	# Test Glitch Sawtooth
	steering.noise_style = steering.NoiseStyle.GLITCH_SAWTOOTH
	steering.phase_offset = PI / 2.0 # t = PI/2 -> normalized_t = 0.25 -> wave = 2.0 * (0.25 - 0) = 0.5
	var vel_sawtooth = steering.calculate_velocity(pos, waypoint, base_speed, 0.016)
	assert_almost_eq(vel_sawtooth.y, 5.0, 0.001, "Sawtooth wave should match math formula output")
