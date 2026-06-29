# minion.gd
extends CharacterBody2D

## Unified minion script configured via MinionData and composition-first child component nodes.

const MinionData = preload("res://Entities/Netrun/Shared/Resources/minion_data.gd")
const RoutingComponent = preload("res://Entities/Netrun/Minions/Components/routing_component.gd")
const HealthComponent = preload("res://Entities/Netrun/Shared/Components/health_component.gd")
const ShieldComponent = preload("res://Entities/Netrun/Minions/Components/shield_component.gd")
const StealthComponent = preload("res://Entities/Netrun/Minions/Components/stealth_component.gd")
const MinionManager = preload("res://Entities/Netrun/Minions/minion_manager.gd")

@export var minion_data: Resource # MinionData resource

@onready var routing_component = $RoutingComponent
@onready var health_component = $HealthComponent
@onready var shield_component = $ShieldComponent
@onready var stealth_component = $StealthComponent
@onready var sprite_2d = get_node_or_null("Sprite2D")

var speed_multiplier: float = 1.0
var has_firewall_immunity: bool = false

func _ready() -> void:
	if minion_data:
		health_component.max_health = minion_data.base_health
		health_component.current_health = minion_data.base_health
		routing_component.set_strategy(minion_data.routing_strategy)
	
	health_component.died.connect(_on_died)
	
	# Register with manager
	var manager = get_tree().get_first_node_in_group("minion_managers")
	if manager and manager.has_method("register_minion"):
		manager.register_minion(self)
		
	_update_minion_sprite()

func _physics_process(delta: float) -> void:
	if not minion_data:
		return
		
	var target_pos: Vector2 = get_target_position()
	var target_velocity: Vector2 = routing_component.get_velocity(
		global_position,
		target_pos,
		minion_data.base_speed * speed_multiplier,
		delta
	)
	velocity = target_velocity
	move_and_slide()
	
	# Align sprite rotation to movement angle
	if velocity.length_squared() > 1.0 and is_instance_valid(sprite_2d):
		sprite_2d.rotation = velocity.angle()

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
		print_debug(self, "Has taken damamge : " + str(amount))
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
		
	var region := Rect2(10, 45, 85, 70)
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

func _on_died() -> void:
	var manager = get_tree().get_first_node_in_group("minion_managers")
	if manager and manager.has_method("unregister_minion"):
		manager.unregister_minion(self)
	queue_free()
