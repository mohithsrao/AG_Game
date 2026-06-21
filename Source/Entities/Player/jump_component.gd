# e:/Godot/Projects/AntiGravityWorkspace/AG_Game/Source/Entities/Player/jump_component.gd
class_name JumpComponent
extends Node

## Component governing jump physics and charge configurations.

signal double_jumped

@export var jump_height: float = 400.0
@export var max_double_jumps: int = 1

var double_jump_charges: int = 0

func get_jump_velocity() -> float:
	# v = sqrt(2 * g * h)
	return -sqrt(2.0 * 980.0 * jump_height)

func can_double_jump() -> bool:
	return double_jump_charges > 0

func execute_double_jump() -> float:
	if can_double_jump():
		double_jump_charges -= 1
		double_jumped.emit()
		return get_jump_velocity()
	return 0.0

func reset_charges() -> void:
	double_jump_charges = max_double_jumps
