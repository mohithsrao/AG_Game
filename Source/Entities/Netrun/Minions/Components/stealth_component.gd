# stealth_component.gd
class_name StealthComponent
extends Node

## Handles scanner untraceability and transparency modulation for SSH spawned minions.

@export var target_sprite: CanvasItem

var is_stealth: bool = false
var stealth_timer: float = 0.0

func apply_stealth(duration: float) -> void:
	is_stealth = true
	stealth_timer = duration
	if is_instance_valid(target_sprite):
		target_sprite.modulate.a = 0.3

func _process(delta: float) -> void:
	if is_stealth:
		stealth_timer -= delta
		if stealth_timer <= 0.0:
			is_stealth = false
			if is_instance_valid(target_sprite):
				target_sprite.modulate.a = 1.0
