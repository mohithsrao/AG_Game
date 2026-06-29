# test_port_spawner.gd
extends GutTest

const PortSpawnerScript = preload("../port_spawner.gd")

func test_default_values() -> void:
	var spawner = autofree(PortSpawnerScript.new())
	assert_eq(spawner.port_type, PortSpawnerScript.PortType.HTTP, "Default port type should be HTTP")
	assert_eq(spawner.base_spawn_time, 2.0, "Default base spawn time should be 2.0")
	assert_eq(spawner.is_focused, false, "Should not be focused by default")
	assert_eq(spawner.focus_spawn_multiplier, 2.0, "Default focus spawn multiplier should be 2.0")

func test_set_focus_doubles_bandwidth() -> void:
	var spawner = PortSpawnerScript.new()
	# Add child because ready() adds the Timer
	add_child_autofree(spawner)
	
	spawner.set_focus(true)
	assert_true(spawner.is_focused, "Spawner should be in focused state")
	assert_eq(spawner.spawn_timer.wait_time, 1.0, "Timer wait_time should be halved during focus (2.0 / 2.0)")
	
	spawner.set_focus(false)
	assert_false(spawner.is_focused, "Spawner should not be in focused state")
	assert_eq(spawner.spawn_timer.wait_time, 2.0, "Timer wait_time should reset back to base spawn time")

func test_focus_emits_alert_signal() -> void:
	var spawner = PortSpawnerScript.new()
	add_child_autofree(spawner)
	spawner.global_position = Vector2(100, 200)
	
	watch_signals(NetrunEvents)
	spawner.set_focus(true)
	
	assert_signal_emitted(NetrunEvents, "gateway_focus_alert", "Overclock focus should trigger global alert signal")
	assert_signal_emitted_with_parameters(
		NetrunEvents, 
		"gateway_focus_alert", 
		[Vector2(100, 200)], 
		0
	)
