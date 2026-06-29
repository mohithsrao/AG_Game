# test_netrun_e2e.gd
extends GutTest

const BossCoreScript = preload("../Boss/boss_core.gd")
const MinionScript = preload("../Minions/minion.gd")
const PortSpawnerScript = preload("../Spawners/port_spawner.gd")

const HealthComponentScript = preload("../Shared/Components/health_component.gd")
const ShieldComponentScript = preload("../Minions/Components/shield_component.gd")
const StealthComponentScript = preload("../Minions/Components/stealth_component.gd")
const RoutingComponentScript = preload("../Minions/Components/routing_component.gd")
const SteeringComponentScript = preload("../Minions/Components/steering_component.gd")

func _create_composed_minion() -> CharacterBody2D:
	var minion = MinionScript.new()
	
	var routing = RoutingComponentScript.new()
	routing.name = "RoutingComponent"
	minion.add_child(routing)
	
	var steering = SteeringComponentScript.new()
	steering.name = "SteeringComponent"
	minion.add_child(steering)
	
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

func test_complete_battle_loop() -> void:
	# 1. Setup the arena with the Boss Core and Spawners
	var boss = BossCoreScript.new()
	boss.max_health = 100.0
	boss.health = 100.0
	boss.ddos_stun_threshold = 2
	add_child_autofree(boss)
	
	# 2. Setup spawners
	var spawner = PortSpawnerScript.new()
	spawner.port_type = PortSpawnerScript.PortType.HTTP
	add_child_autofree(spawner)
	
	# 3. Battle Phase: Spawner automates minions
	var minion_1: CharacterBody2D = _create_composed_minion()
	var minion_2: CharacterBody2D = _create_composed_minion()
	add_child_autofree(minion_1)
	add_child_autofree(minion_2)
	
	# 4. Minions navigate and hit the boss
	boss.register_ddos_hit() # minion 1 hit
	boss.take_damage(10.0)
	assert_eq(boss.health, 90.0, "Boss should take normal damage first")
	
	boss.register_ddos_hit() # minion 2 hit (reaches threshold of 2)
	assert_eq(boss.current_state, boss.State.BUFFER_OVERFLOW, "Boss should be stunned on threshold hit")
	
	# 5. Double damage while in stun state
	boss.take_damage(20.0)
	assert_eq(boss.health, 50.0, "Boss should take 2x damage during stun (20 * 2 = 40 damage)")
	
	# 6. Stun recovery triggers System Purge shockwave
	boss.recover_from_stun()
	assert_eq(boss.current_state, boss.State.ACTIVE, "Boss should return to ACTIVE state after recovering")
	
	# 7. Ultimate destruction of the Boss
	boss.take_damage(50.0) # normal damage takes down remaining 50 health
	assert_eq(boss.health, 0.0, "Boss health should be depleted")
	assert_true(boss.is_queued_for_deletion(), "Boss core should be queued for deletion")
