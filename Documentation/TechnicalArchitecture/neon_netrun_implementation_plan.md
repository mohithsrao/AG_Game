# Implementation Plan: Neon Netrun Core Prototype

This plan details the technical steps to build the core gameplay prototype of **"Neon Netrun"**, testing the inverted swarm control, Active Gateways, Syscall tactics, Network Jitter pathing, and Boss stuns.

## Proposed Changes

### Component 1: Level Grid & Spawners
- **File**: `Source/Entities/Netrun/Spawners/port_spawner.tscn`
- **File**: `Source/Entities/Netrun/Spawners/port_spawner.gd`
  - Implement active spawner template.
  - Implement `set_focus(value)` function to toggle overclocking.
  - Emit alert signals to the Boss.

### Component 2: Minions (Trojans, DDoS Packets)
- **File**: `Source/Entities/Netrun/Minions/minion_base.gd`
  - Implement `NavigationAgent2D` target pathing.
  - Implement physics movement formula applying sine-wave jitter offsets based on VPN/Direct configurations.
- **File**: `Source/Entities/Netrun/Minions/minion_trojan.gd`
  - Manage contact detection with Boss to spawn 4 Spyware triangles.
- **File**: `Source/Entities/Netrun/Minions/minion_ddos.gd`
  - Apply charge-based stun triggers on Boss Core.

### Component 3: Boss Core (Matrix AI)
- **File**: `Source/Entities/Netrun/Boss/boss_core.tscn`
- **File**: `Source/Entities/Netrun/Boss/boss_core.gd`
  - Implement Boss AI FSM (`ACTIVE`, `BUFFER_OVERFLOW`, `SYSTEM_PURGE`).
  - Implement `SYSTEM_PURGE` tweens expanding the Area2D field to clear minions.
  - Handle damage reception and stun triggers.

### Component 4: Event Decoupler
- **File**: `Source/Entities/Netrun/netrun_events.gd` (Autoload)
  - Declare signal definitions for gateway alerts, syscall triggers, and stun events.

---

## Verification Plan

### Automated Test Setup
- Write test scripts in `Source/Entities/Netrun/tests/test_netrun.gd` to test:
  1. DDoS packets triggering Boss stun state transitions.
  2. Trojan cube splitting logic.
  3. Spawner focus rate multiplier.
