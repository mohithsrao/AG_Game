# test_minion.gd
extends GutTest

const MinionScript = preload("../minion.gd")
const RoutingComponentScript = preload("../Components/routing_component.gd")
const HealthComponentScript = preload("../../Shared/Components/health_component.gd")
const ShieldComponentScript = preload("../Components/shield_component.gd")
const StealthComponentScript = preload("../Components/stealth_component.gd")

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
	
	add_child_autofree(minion)
	return minion

func test_default_values() -> void:
	var minion = _create_composed_minion()
	assert_eq(minion.speed_multiplier, 1.0, "Default speed multiplier should be 1.0")
	assert_eq(minion.has_firewall_immunity, false, "Should not have firewall immunity by default")

func test_take_damage_without_shield() -> void:
	var minion = _create_composed_minion()
	minion.health_component.max_health = 20.0
	minion.health_component.current_health = 20.0
	minion.take_damage(4.0)
	assert_eq(minion.health_component.current_health, 16.0, "Health should decrease by damage amount")

func test_take_damage_with_shield() -> void:
	var minion = _create_composed_minion()
	minion.health_component.max_health = 20.0
	minion.health_component.current_health = 20.0
	minion.shield_component.is_shielded = true
	minion.take_damage(4.0)
	assert_eq(minion.health_component.current_health, 20.0, "Shield should absorb damage fully")
	assert_eq(minion.shield_component.is_shielded, false, "Shield should be depleted after absorbing damage")

func test_destroy_frees_node() -> void:
	var minion = _create_composed_minion()
	minion._on_died()
	assert_true(minion.is_queued_for_deletion(), "Minion should be queued for deletion")
