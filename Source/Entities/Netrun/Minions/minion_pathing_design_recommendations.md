# Minion Pathing & Steering: Decoupling and Jitter Design Recommendations
**Role:** Game Director, Godot AI Council
**Backlog Task:** BACKLOG-001 (Decouple minion movement pathing)

---

## 1. Analysis of Current Implementation

### Minion Movement & Composition
The minion (`minion.gd`) uses a composition-first approach:
- Core behaviors are delegated to child nodes: `RoutingComponent`, `HealthComponent`, `ShieldComponent`, and `StealthComponent`.
- In `_physics_process`, the minion queries `RoutingComponent.get_velocity` to determine its velocity, then executes `move_and_slide()`.
- Rotation is aligned to velocity: `sprite_2d.rotation = velocity.angle()`.

This is a clean, extensible setup. However, the pathing logic itself is still tightly coupled to the movement loop's velocity calculation, and the strategies themselves are defined as separate Resource scripts (`StrategyDirect` and `StrategyJitter`).

### Critique of `StrategyJitter` (`strategy_jitter.gd`)
```gdscript
var jitter_offset: float = sin(Time.get_ticks_msec() * frequency) * amplitude
return (target_dir * speed) + (perpendicular_dir * jitter_offset)
```
1. **The "Synchronized Sway" Issue**: 
   Since `Time.get_ticks_msec()` returns the wall-clock time of the engine, every minion using `StrategyJitter` will evaluate the exact same sine value at any given frame. If multiple Jitter minions are spawned, they will wave left and right in perfect synchronization. Instead of appearing as chaotic network "noise" or a dispersed swarm, they will look like a synchronized marching band.
2. **Velocity Inflation / Speed Fluctuation**:
   The velocity vector is computed as a direct sum of forward and perpendicular vectors: `(target_dir * speed) + (perpendicular_dir * jitter_offset)`.
   - The magnitude of this velocity is $\sqrt{\text{speed}^2 + \text{jitter\_offset}^2}$.
   - With the default configuration (`amplitude = 120.0`, `base_speed = 120.0`), the peak speed reaches $\sqrt{120^2 + 120^2} \approx 170.0$ (a **41.4% speed boost**).
   - While this makes the packets speed up dynamically as they swing outward, it makes it extremely difficult for designers to balance arrival times, travel latency, and turret leads.

---

## 2. Gameplay Design Impact of Jitter Pathing

Jitter routing represents cyber packet transmission noise or active evasion. It introduces several critical gameplay dynamics:

- **Evasion vs. Target Tracking**: Lateral movement makes it harder for defense systems (like manual targeting or projectile turrets with transit times) to lock onto or hit the packet. High-amplitude jitter makes packets elusive but slower to make forward progress if velocity magnitude is normalized.
- **Spatial Coverage & Trap Triggering**: A packet swaying side-to-side covers a wider physical corridor. This can be used strategically to sweep and clear area hazards (like security mines or scanning beams) to pave a safe way for subsequent straight-line packets.
- **Swarm Dispersal (AoE Mitigation)**: Introducing unique phases or frequencies to individual packets causes them to spread out. If a turret fires an explosive area-of-effect blast, a dispersed wave of jittery packets will suffer far fewer casualties than a tight line of direct-path packets.

---

## 3. Recommended Designer-Exposed Properties

To allow game designers to easily tune and customize routing styles, the `RoutingComponent` or the individual `RoutingStrategy` resources should expose:

1. **`amplitude` (float)**: The maximum lateral distance the packet deviates from the central path.
2. **`frequency` (float)**: How quickly the packet oscillates back and forth.
3. **`phase_offset` (float)**: An offset added to the time argument. By randomizing this on spawn (`randf_range(0, 2 * PI)`), packets will wiggle independently rather than in lockstep.
4. **`noise_style` (Enum)**:
   - `SINE`: Smooth, rolling oscillation (standard jitter).
   - `GLITCH_SAWTOOTH`: Sharp, sudden zig-zag movements (simulates aggressive packet correction).
   - `RANDOM_WALK` / `PERLIN`: Unpredictable, chaotic drift (simulates natural signal degradation).
   - `SQUARE_WAVE`: Rapid lane-shifting behavior (simulates jumping between routing channels).
5. **`damping_near_target` (float)**: A distance threshold below which the lateral offset scales down to zero. This ensures packets cleanly hit the target (the Boss/core) instead of oscillating wildly around it at the end of their path.
6. **`velocity_mode` (Enum)**:
   - `CONSTANT_FORWARD_SPEED`: Keeps forward velocity equal to `base_speed`. Travel time is identical to direct routing, but physical velocity increases during wiggles.
   - `CONSTANT_TRAVEL_SPEED`: Normalizes the combined vector so the packet moves at exactly `base_speed` overall. Travel time to the destination is longer.

---

## 4. Packet Archetypes & Gameplay Feel

To create a rich, tactile cyberpunk experience, different network packets should behave and look distinct:

| Packet Type | Speed | Steering Style & Aggressiveness | Pathing Strategy | Visual Cues & VFX |
| :--- | :--- | :--- | :--- | :--- |
| **HTTP** *(Standard)* | Medium | Direct, rigid alignment. Low maneuverability. | `StrategyDirect` | Clear, solid, narrow green trails. Consistent, predictable movement. |
| **HTTPS** *(Shielded)* | Slow | Heavy, sluggish steering. High inertia. | `StrategyDirect` with wide, gentle swerves to intercept turret shots. | Thick, glowing blue shield bubble. Heavy, sputtering blue engine flares and wide trails. |
| **SSH** *(Stealth)* | Fast | Twitchy, erratic, high-aggression turns. | `StrategyJitter` (High frequency, low-medium amplitude, glitched sawtooth/noise style). | Flickering/translucent sprite, purple holographic trails, pixelated "ghost" images left behind. |

---

## 5. Architectural & Mechanical Benefits of Decoupling

Decoupling the movement calculations from the `Minion` entity using the Strategy Pattern provides significant engineering and design benefits:

- **Drag-and-Drop Strategy Configuration**: Designers can create custom routing profiles as `.tres` resources (e.g., `strategy_sine_evasive.tres`, `strategy_zig_zag.tres`) and assign them directly to `MinionData` in the inspector without touching any code.
- **Dynamic Runtime Swapping**: Minions can dynamically change their pathing strategy based on gameplay events. For instance:
  - An **SSH packet** could use `StrategyStealth` (silent, slow, direct) until detected, then instantly switch to `StrategyJitter` (fast, erratic, evasive) to escape.
  - A packet hit by an EMP could switch to an `ErraticGlitch` strategy representing corrupted routing.
- **Enhanced Testability**: Math-heavy movement strategies can be unit-tested in isolation (via GUT) without needing to spawn a full `CharacterBody2D` or run physics steps, preventing regressions in pathing math.
