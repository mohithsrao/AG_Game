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

func get_target_position() -> Vector2:
	var boss: Node2D = get_tree().get_first_node_in_group("boss") as Node2D
	return boss.global_position if boss else global_position

func take_damage(amount: float) -> void:
	if has_firewall_immunity and amount > 10.0: # Firewall deals high damage
		return
		
	if is_instance_valid(shield_component) and shield_component.absorb_damage():
		return
		
	if is_instance_valid(health_component):
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
			if minion_data and minion_data.minion_name == "DDoS Packet":
				detonate_payload()

func detonate_payload() -> void:
	var boss: Node2D = get_tree().get_first_node_in_group("boss") as Node2D
	if boss and boss.has_method("apply_ddos_hit") and minion_data:
		boss.apply_ddos_hit(int(minion_data.ddos_value))
	_on_died()

func _on_died() -> void:
	var manager = get_tree().get_first_node_in_group("minion_managers")
	if manager and manager.has_method("unregister_minion"):
		manager.unregister_minion(self)
	queue_free()
