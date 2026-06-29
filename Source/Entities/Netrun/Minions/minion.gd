# minion.gd
extends CharacterBody2D

## Unified minion script configured via MinionData and composition-first child component nodes.

const MinionManager = preload("res://Entities/Netrun/Minions/minion_manager.gd")

const HUM_PATH: String = "res://Entities/Netrun/Shared/Assets/Audio/minion_hum.tres"
const CLICK_PATH: String = "res://Entities/Netrun/Shared/Assets/Audio/minion_click.tres"

@export var minion_data: MinionData

@onready var routing_component: RoutingComponent = $RoutingComponent
@onready var steering_component: SteeringComponent = $SteeringComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var shield_component: ShieldComponent = $ShieldComponent
@onready var stealth_component: StealthComponent = $StealthComponent
@onready var sprite_2d: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

var speed_multiplier: float = 1.0
var has_firewall_immunity: bool = false

# VFX & SFX Fields
var trail_line: Line2D
var max_trail_points: int = 15
var base_trail_width: float = 3.0

var shader_mat: ShaderMaterial

var hum_player: AudioStreamPlayer2D
var click_player: AudioStreamPlayer2D
var last_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if minion_data:
		health_component.max_health = minion_data.base_health
		health_component.current_health = minion_data.base_health
		routing_component.set_strategy(minion_data.routing_strategy)
		
		# Configure SteeringComponent based on routing strategy parameters
		var strat = minion_data.routing_strategy
		if strat and is_instance_valid(steering_component):
			if "amplitude" in strat:
				steering_component.amplitude = strat.amplitude
			if "frequency" in strat:
				steering_component.frequency = strat.frequency
			if "damping_near_target" in strat:
				steering_component.damping_near_target = strat.damping_near_target
			if "velocity_mode" in strat:
				steering_component.velocity_mode = strat.velocity_mode
	
	health_component.died.connect(_on_died)
	
	# Register with manager
	var manager = get_tree().get_first_node_in_group("minion_managers")
	if manager and manager.has_method("register_minion"):
		manager.register_minion(self)
		
	# Initialize VFX/SFX systems
	_init_trail()
	_setup_shader()
	_setup_audio()
	
	_update_minion_sprite()

func _physics_process(delta: float) -> void:
	if not minion_data or not is_instance_valid(steering_component) or not is_instance_valid(routing_component):
		return
		
	var target_pos: Vector2 = get_target_position()
	var waypoint: Vector2 = routing_component.get_waypoint(global_position, target_pos)
	var target_velocity: Vector2 = steering_component.calculate_velocity(
		global_position,
		waypoint,
		minion_data.base_speed * speed_multiplier,
		delta
	)
	velocity = target_velocity
	move_and_slide()
	
	# Align sprite rotation to movement angle
	if velocity.length_squared() > 1.0 and is_instance_valid(sprite_2d):
		sprite_2d.rotation = velocity.angle()
		
	# Update VFX/SFX
	_update_trail(delta)
	_update_shader_params(delta)
	_update_audio(delta)

func get_target_position() -> Vector2:
	var boss: Node2D = get_tree().get_first_node_in_group("boss") as Node2D
	return boss.global_position if boss else global_position

func take_damage(amount: float) -> void:
	if has_firewall_immunity and amount > 10.0: # Firewall deals high damage
		return
		
	if is_instance_valid(shield_component) and shield_component.absorb_damage():
		_update_minion_sprite() # Swap sprite when shield breaks
		return
		
	if is_instance_valid(health_component):
		print_debug(self, "Has taken damage : ", amount)
		health_component.take_damage(amount)

func apply_syscall_effect(syscall: NetrunTypes.SyscallType) -> void:
	match syscall:
		NetrunTypes.SyscallType.CHMOD_SPEED_BOOST:
			speed_multiplier = 2.0
			has_firewall_immunity = true
			await get_tree().create_timer(2.0).timeout
			speed_multiplier = 1.0
			has_firewall_immunity = false
		NetrunTypes.SyscallType.PING_DDoS_DETONATE:
			if minion_data and (minion_data.minion_name == "HTTP Packet" or minion_data.minion_name == "DDoS Packet"):
				detonate_payload()

func detonate_payload() -> void:
	var boss: Node2D = get_tree().get_first_node_in_group("boss") as Node2D
	if boss and boss.has_method("apply_ddos_hit") and minion_data:
		boss.apply_ddos_hit(int(minion_data.ddos_value))
	_on_died()

func _update_minion_sprite() -> void:
	if not is_instance_valid(sprite_2d) or not minion_data:
		return
		
	var region: Rect2 = Rect2(10, 45, 85, 70)
	match minion_data.minion_name:
		"HTTP Packet", "DDoS Packet":
			region = Rect2(10, 45, 85, 70)
		"HTTPS Packet", "Trojan Horse":
			if is_instance_valid(shield_component) and shield_component.is_shielded:
				region = Rect2(190, 195, 85, 70)
			else:
				region = Rect2(190, 45, 85, 70)
		"SSH Packet", "Logic Bomb":
			region = Rect2(280, 45, 85, 70)
			
	sprite_2d.region_rect = region
	_update_shader_uv_bounds()

func _on_died() -> void:
	var manager: Node = get_tree().get_first_node_in_group("minion_managers")
	if manager and manager.has_method("unregister_minion"):
		manager.unregister_minion(self)
	queue_free()

# --- VFX / SFX HELPER METHODS ---

func _init_trail() -> void:
	trail_line = Line2D.new()
	trail_line.top_level = true
	trail_line.z_index = z_index - 1
	
	# Configure based on packet type
	var grad: Gradient = Gradient.new()
	var color_start: Color = Color.html("#00FFFF") # Default Neon Cyan
	base_trail_width = 3.0
	max_trail_points = 15
	
	if minion_data:
		match minion_data.minion_name:
			"HTTP Packet", "DDoS Packet":
				color_start = Color.html("#00FFFF") # Neon Cyan
				base_trail_width = 2.0
				max_trail_points = 10
			"HTTPS Packet", "Trojan Horse":
				color_start = Color.html("#39FF14") # Cyber Jade
				base_trail_width = 5.0
				max_trail_points = 20
			"SSH Packet", "Logic Bomb":
				color_start = Color.html("#FF007F") # Hot Magenta
				base_trail_width = 3.0
				max_trail_points = 12
				
	var color_end: Color = Color(color_start.r, color_start.g, color_start.b, 0.0)
	grad.set_color(0, color_start)
	grad.set_color(1, color_end)
	
	trail_line.gradient = grad
	trail_line.width = base_trail_width
	trail_line.antialiased = true
	
	add_child(trail_line)

func _update_trail(_delta: float) -> void:
	if not is_instance_valid(trail_line) or not minion_data:
		return
		
	# Calculate lateral speed component
	var target_pos: Vector2 = get_target_position()
	var target_dir: Vector2 = global_position.direction_to(target_pos)
	var perp_dir: Vector2 = Vector2(-target_dir.y, target_dir.x)
	var lateral_speed: float = velocity.dot(perp_dir)
	var lateral_factor: float = abs(lateral_speed) / (minion_data.base_speed * speed_multiplier) if minion_data.base_speed > 0.0 else 0.0
	
	# Drift width based on lateral factor (amplitude drift)
	trail_line.width = base_trail_width * (1.0 + lateral_factor * 1.5)
	
	# Add point
	trail_line.add_point(global_position)
	
	# Keep trail size in bounds
	while trail_line.points.size() > max_trail_points:
		trail_line.remove_point(0)

func _setup_shader() -> void:
	if not is_instance_valid(sprite_2d):
		return
	
	var shader: Shader = load("res://Entities/Netrun/Shared/Assets/Shaders/minion_glitch.gdshader") as Shader
	if shader:
		shader_mat = ShaderMaterial.new()
		shader_mat.shader = shader
		sprite_2d.material = shader_mat
		_update_shader_uv_bounds()

func _update_shader_uv_bounds() -> void:
	if not is_instance_valid(sprite_2d) or not is_instance_valid(shader_mat) or not sprite_2d.texture:
		return
	
	var tex_size: Vector2 = sprite_2d.texture.get_size()
	var region: Rect2 = sprite_2d.region_rect
	var uv_min: Vector2 = region.position / tex_size
	var uv_max: Vector2 = (region.position + region.size) / tex_size
	
	shader_mat.set_shader_parameter("uv_min", uv_min)
	shader_mat.set_shader_parameter("uv_max", uv_max)

func _update_shader_params(_delta: float) -> void:
	if not is_instance_valid(shader_mat) or not minion_data:
		return
	
	# Determine lateral speed component
	var target_pos: Vector2 = get_target_position()
	var target_dir: Vector2 = global_position.direction_to(target_pos)
	var perp_dir: Vector2 = Vector2(-target_dir.y, target_dir.x)
	var lateral_speed: float = velocity.dot(perp_dir)
	var lateral_factor: float = abs(lateral_speed) / (minion_data.base_speed * speed_multiplier) if minion_data.base_speed > 0.0 else 0.0
	
	# Chromatic Aberration maps to lateral jitter movement speed
	var max_aberration: float = 10.0 # max pixels offset
	var aberration: float = clamp(lateral_factor * max_aberration, 0.0, max_aberration)
	shader_mat.set_shader_parameter("chromatic_aberration", aberration)
	
	# Scanline glitch intensity maps to lateral deviation
	var intensity: float = clamp(lateral_factor * 0.8, 0.0, 0.8)
	shader_mat.set_shader_parameter("glitch_intensity", intensity)
	
	var freq: float = 10.0
	if is_instance_valid(steering_component):
		freq = steering_component.frequency * 500.0
	shader_mat.set_shader_parameter("glitch_frequency", freq)

func _setup_audio() -> void:
	hum_player = AudioStreamPlayer2D.new()
	hum_player.stream = load(HUM_PATH)
	hum_player.autoplay = true
	hum_player.max_distance = 600.0
	hum_player.attenuation = 1.5
	hum_player.volume_db = -12.0
	add_child(hum_player)
	
	click_player = AudioStreamPlayer2D.new()
	click_player.stream = load(CLICK_PATH)
	click_player.max_distance = 600.0
	click_player.attenuation = 1.5
	click_player.volume_db = -6.0
	add_child(click_player)

func _update_audio(delta: float) -> void:
	if not is_instance_valid(hum_player) or not minion_data:
		return
		
	var speed: float = velocity.length()
	var target_pitch: float = 1.0
	if speed > 10.0:
		target_pitch = 1.0 + (speed - 120.0) / 120.0 * 2.5
		target_pitch = clamp(target_pitch, 0.8, 3.5)
	else:
		target_pitch = 0.8
		
	hum_player.pitch_scale = lerp(hum_player.pitch_scale, target_pitch, 10.0 * delta)
	
	# Play click sound on direction corrections > 45 degrees
	var current_dir: Vector2 = velocity.normalized()
	if current_dir != Vector2.ZERO and last_direction != Vector2.ZERO:
		var angle_diff: float = abs(current_dir.angle_to(last_direction))
		if angle_diff > deg_to_rad(45.0):
			if is_instance_valid(click_player) and not click_player.playing:
				click_player.play()
	last_direction = current_dir
