# e:/Godot/Projects/AntiGravityWorkspace/AG_Game/Source/Entities/Player/tests/test_player.gd
extends GutTest

## Automated tests for the Player double-jump mechanics.

var player_scene: PackedScene = load("res://Source/Entities/Player/player.tscn")
var _player: Player = null

func before_each() -> void:
	# Stub character body and jump component for unit testing
	_player = Player.new()
	var jump_comp = JumpComponent.new()
	jump_comp.name = "JumpComponent"
	_player.add_child(jump_comp)
	_player._ready()
	add_child_autoqfree(_player)

func test_initial_charges_on_ready() -> void:
	assert_eq(_player.jump_component.max_double_jumps, 1, "Should have 1 default double jump charge.")

func test_reset_charges_on_floor() -> void:
	_player.jump_component.double_jump_charges = 0
	_player.state = "InAir"
	
	# Simulate floor landing
	_player.state = "OnFloor"
	_player.jump_component.reset_charges()
	
	assert_eq(_player.jump_component.double_jump_charges, 1, "Charges should reset to maximum on landing.")

func test_double_jump_reduces_charges() -> void:
	_player.jump_component.reset_charges()
	assert_eq(_player.jump_component.double_jump_charges, 1)
	
	var velocity = _player.jump_component.execute_double_jump()
	assert_lt(velocity, 0.0, "Jump velocity should be negative (upwards).")
	assert_eq(_player.jump_component.double_jump_charges, 0, "Double jump should consume 1 charge.")

func test_cannot_double_jump_without_charges() -> void:
	_player.jump_component.double_jump_charges = 0
	var velocity = _player.jump_component.execute_double_jump()
	assert_eq(velocity, 0.0, "Velocity should be 0 since double jump cannot execute.")
