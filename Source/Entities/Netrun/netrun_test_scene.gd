# netrun_test_scene.gd
extends Node2D

## Interactive test controller to drive portals, boss cores, and minion behaviors in the arena.

@onready var port_80_spawner = $Port80Spawner
@onready var port_443_spawner = $Port443Spawner
@onready var port_22_spawner = $Port22Spawner
@onready var boss_core = $BossCore

func _ready() -> void:
	print("Netrun Test Scene Loaded!")
	print("Interactive Controls:")
	print("  [1] Trigger CHMOD Speed Boost Syscall")
	print("  [2] Trigger PING DDoS Detonate Syscall")
	print("  [Q] Toggle Overclock on Port 80 Spawner (HTTP)")
	print("  [W] Toggle Overclock on Port 443 Spawner (HTTPS)")
	print("  [E] Toggle Overclock on Port 22 Spawner (SSH)")
	print("  [A] Apply 20 damage to Port 80 Spawner")
	print("  [S] Apply 50 damage to Boss Core")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				print("Input: Syscall -> CHMOD_SPEED_BOOST")
				NetrunEvents.syscall_triggered.emit(NetrunTypes.SyscallType.CHMOD_SPEED_BOOST)
			KEY_2:
				print("Input: Syscall -> PING_DDoS_DETONATE")
				NetrunEvents.syscall_triggered.emit(NetrunTypes.SyscallType.PING_DDoS_DETONATE)
			KEY_Q:
				if is_instance_valid(port_80_spawner):
					port_80_spawner.set_focus(!port_80_spawner.is_focused)
					print("Port 80 Focus: ", port_80_spawner.is_focused)
			KEY_W:
				if is_instance_valid(port_443_spawner):
					port_443_spawner.set_focus(!port_443_spawner.is_focused)
					print("Port 443 Focus: ", port_443_spawner.is_focused)
			KEY_E:
				if is_instance_valid(port_22_spawner):
					port_22_spawner.set_focus(!port_22_spawner.is_focused)
					print("Port 22 Focus: ", port_22_spawner.is_focused)
			KEY_A:
				if is_instance_valid(port_80_spawner) and is_instance_valid(port_80_spawner.health_component):
					port_80_spawner.health_component.take_damage(20.0)
					print("Port 80 Spawner Health: ", port_80_spawner.health_component.current_health)
			KEY_S:
				if is_instance_valid(boss_core):
					boss_core.take_damage(50.0)
					print("Boss Core Health: ", boss_core.health)
