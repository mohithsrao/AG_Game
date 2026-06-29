# Product Backlog: Neon Netrun Polish & Refactoring

This backlog holds the items that require planning, design, and incremental execution by the AI Council.

## High Priority (Active Planning)
- **BACKLOG-001 [Refactoring]**: Decouple minion movement pathing. Move the custom Jitter Pathing formulas out of the base minion script and into a reusable `SteeringComponent` node.
- **BACKLOG-002 [Bug Fix]**: Adjust Port Spawner "Gateway Focus" heat signature triggering. The AV Scanner laser isn't always homing correctly onto focused gateways.
- **BACKLOG-003 [VFX Polish]**: Trigger custom Screen Glitch VFX (`glitch_vfx.tres`) on the Digital Core when it transitions to the `BUFFER_OVERFLOW` (stunned) state.

## Medium Priority (Backlog)
- **BACKLOG-004 [Scene Polish]**: Ensure Minion variations (`Trojan`, `Spyware`, `DDoS`) are fully split into separate inherited scene files (`minion_trojan.tscn`, etc.) rather than sharing a single scene configuration.
- **BACKLOG-005 [SFX Polish]**: Integrate custom SFX streams (`sfx_anti_virus_beam.wav`, `sfx_buffer_overflow.wav`) via `AudioStreamPlayer2D` components.
- **BACKLOG-006 [UI Polish]**: Format Syscall buttons on the UI HUD to display dynamic cooldown sweeps and disable states correctly.

## Low Priority (Backlog)
- **BACKLOG-007 [E2E Testing]**: Implement end-to-end integration tests using GUT to verify the player winning loop (Digital Core destroyed triggers level success UI).
