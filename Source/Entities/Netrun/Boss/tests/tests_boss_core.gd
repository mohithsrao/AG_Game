# test_boss_core.gd
extends GutTest

const BossCoreScript = preload("../boss_core.gd")

func test_default_values() -> void:
	var boss = autofree(BossCoreScript.new())
	assert_eq(boss.health, 1000.0, "Initial health should be max health")
	assert_eq(boss.current_state, BossCoreScript.State.ACTIVE, "Default state should be ACTIVE")
	assert_eq(boss.ddos_stun_threshold, 10, "Default DDoS hit stun threshold should be 10")

func test_take_damage_normal() -> void:
	var boss = autofree(BossCoreScript.new())
	boss.take_damage(100.0)
	assert_eq(boss.health, 900.0, "Boss should take 1x damage in ACTIVE state")

func test_take_damage_during_buffer_overflow() -> void:
	var boss = autofree(BossCoreScript.new())
	boss.current_state = BossCoreScript.State.BUFFER_OVERFLOW
	boss.take_damage(100.0)
	assert_eq(boss.health, 800.0, "Boss should take 2x damage in BUFFER_OVERFLOW state")

func test_ddos_accumulation_triggers_stun() -> void:
	var boss = autofree(BossCoreScript.new())
	watch_signals(NetrunEvents)
	
	# Send hits up to threshold - 1
	for i in range(boss.ddos_stun_threshold - 1):
		boss.register_ddos_hit()
		assert_eq(boss.current_state, BossCoreScript.State.ACTIVE, "Should remain ACTIVE before threshold")
	
	# The threshold hit should trigger stun
	boss.register_ddos_hit()
	assert_eq(boss.current_state, BossCoreScript.State.BUFFER_OVERFLOW, "Should transition to BUFFER_OVERFLOW on threshold hit")
	assert_signal_emitted(NetrunEvents, "boss_stunned", "Should emit boss_stunned event globally")

func test_stun_duration_and_recovery() -> void:
	var boss = BossCoreScript.new()
	add_child_autofree(boss)
	watch_signals(NetrunEvents)
	
	boss.trigger_buffer_overflow()
	assert_eq(boss.current_state, BossCoreScript.State.BUFFER_OVERFLOW)
	
	# Simulate 3 seconds
	boss._process(1.5)
	assert_eq(boss.current_state, BossCoreScript.State.BUFFER_OVERFLOW, "Should remain stunned before timeout")
	
	boss._process(1.5)
	assert_signal_emitted(NetrunEvents, "boss_recovered", "Should emit boss_recovered event globally")
	assert_eq(boss.current_state, BossCoreScript.State.ACTIVE, "Should return to ACTIVE state after purge sequence")
