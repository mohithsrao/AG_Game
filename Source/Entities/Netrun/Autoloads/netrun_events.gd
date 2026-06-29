# netrun_events.gd
extends Node

## Globally registered Autoload event bus for decoupling UI, inputs, and gameplay systems.

# Emitted when a manual tactical command (Syscall) is triggered from UI
signal syscall_triggered(syscall: NetrunTypes.SyscallType)

# Emitted when an Active Gateway is overclocked by the player
signal gateway_focus_alert(focus_position: Vector2)

# Emitted when the Boss Core accumulates enough DDoS hits to stun
signal boss_stunned

# Emitted when the Boss Core recovers from a Buffer Overflow stun
signal boss_recovered
