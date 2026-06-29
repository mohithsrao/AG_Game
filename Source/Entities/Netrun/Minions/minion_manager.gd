# minion_manager.gd
extends Node

## Orchestrates group behaviors and propagates syscall commands to registered minions.

var registered_minions: Array[Node2D] = []

func _ready() -> void:
	add_to_group("minion_managers")
	NetrunEvents.syscall_triggered.connect(_on_syscall_triggered)

func register_minion(minion: Node2D) -> void:
	if not registered_minions.has(minion):
		registered_minions.append(minion)

func unregister_minion(minion: Node2D) -> void:
	registered_minions.erase(minion)

func _on_syscall_triggered(syscall: NetrunTypes.SyscallType) -> void:
	var minions_copy: Array[Node2D] = registered_minions.duplicate()
	for minion in minions_copy:
		if is_instance_valid(minion) and minion.has_method("apply_syscall_effect"):
			minion.apply_syscall_effect(syscall)
