# shield_component.gd
class_name ShieldComponent
extends Node

## Handles defensive barriers for HTTPS spawned minions.
## Absorbs the first damage source, deactivating the shield.

@export var is_shielded: bool = false

func absorb_damage() -> bool:
	if is_shielded:
		is_shielded = false
		# Emit shield break VFX / SFX logic could go here
		return true
	return false
