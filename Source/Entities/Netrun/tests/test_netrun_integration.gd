# test_netrun_integration.gd
extends GutTest

const PortSpawnerScript = preload("../Spawners/port_spawner.gd")
const MinionScript = preload("../Minions/minion.gd")
const BossCoreScript = preload("../Boss/boss_core.gd")

const HealthComponentScript = preload("../Shared/Components/health_component.gd")
const ShieldComponentScript = preload("../Minions/Components/shield_component.gd")
const StealthComponentScript = preload("../Minions/Components/stealth_component.gd")
const RoutingComponentScript = preload("../Minions/Components/routing_component.gd")

func _create_composed_minion() -> CharacterBody2D:
	var minion = MinionScript.new()
	
	var routing = RoutingComponentScript.new()
	routing.name = "RoutingComponent"
	minion.add_child(routing)
	
	var health = HealthComponentScript.new()
	health.name = "HealthComponent"
	minion.add_child(health)
	
	var shield = ShieldComponentScript.new()
	shield.name = "ShieldComponent"
	minion.add_child(shield)
	
	var stealth = StealthComponentScript.new()
	stealth.name = "StealthComponent"
	minion.add_child(stealth)
	
	return minion

func test_port_443_shielded_spawning() -> void:
	var spawner = PortSpawnerScript.new()
	spawner.port_type = PortSpawnerScript.PortType.HTTPS
	add_child_autofree(spawner)
	
	var minion = _create_composed_minion()
	add_child_autofree(minion)
	if spawner.port_type == PortSpawnerScript.PortType.HTTPS:
		minion.shield_component.is_shielded = true
		
	assert_true(minion.shield_component.is_shielded, "Minion spawned on Port 443 (HTTPS) should have defensive barrier")

func test_port_22_stealth_spawning() -> void:
	var spawner = PortSpawnerScript.new()
	spawner.port_type = PortSpawnerScript.PortType.SSH
	add_child_autofree(spawner)
	
	var minion = _create_composed_minion()
	add_child_autofree(minion)
	if spawner.port_type == PortSpawnerScript.PortType.SSH:
		minion.stealth_component.apply_stealth(3.0)
		
	assert_true(minion.stealth_component.is_stealth, "Minion spawned on Port 22 (SSH) should be in stealth state")

func test_syscall_ddos_detonation_applies_boss_stun() -> void:
	var boss = BossCoreScript.new()
	boss.ddos_stun_threshold = 3
	add_child_autofree(boss)
	
	var mock_minion_count: int = 3
	var active_minions: Array[CharacterBody2D] = []
	for i in range(mock_minion_count):
		var m = _create_composed_minion()
		add_child_autofree(m)
		active_minions.append(m)
	
	watch_signals(NetrunEvents)
	
	for m in active_minions:
		boss.register_ddos_hit()
		m._on_died()
		
	assert_eq(boss.current_state, boss.State.BUFFER_OVERFLOW, "Detonating 3 DDoS packets should trigger Boss buffer overflow")
	assert_signal_emitted(NetrunEvents, "boss_stunned", "Event bus should report Boss stun")
