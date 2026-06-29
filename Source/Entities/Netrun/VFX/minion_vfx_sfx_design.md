# Minion VFX/SFX Pathing & Steering Design Specification

This document details the visual and auditory feedback systems for network minions as their pathing and steering are decoupled into a reusable component (`SteeringComponent`) under **BACKLOG-001**.

---

## 1. Analysis of Current Setup

### Current Code & Architecture:
- **`minion.gd`**: Currently calculates movement directly in `_physics_process` by polling `routing_component.get_velocity()`. It handles alignment of its sprite rotation to the movement angle:
  ```gdscript
  if velocity.length_squared() > 1.0 and is_instance_valid(sprite_2d):
      sprite_2d.rotation = velocity.angle()
  ```
- **`strategy_jitter.gd`**: Implements custom routing math, offsetting movement perpendicular to the target via a sine wave:
  ```gdscript
  var jitter_offset: float = sin(Time.get_ticks_msec() * frequency) * amplitude
  return (target_dir * speed) + (perpendicular_dir * jitter_offset)
  ```

### Decoupling to a `SteeringComponent`:
When we move these formulas to a reusable `SteeringComponent` node, the component will handle velocity calculation and rotation. Crucially, the VFX/SFX systems must listen to this component's signals or state variables (`current_steering_force`, `jitter_offset_value`, `is_boosting`, `active_strategy_type`) to drive visual shaders and audio synthesizers dynamically.

---

## 2. Cyberpunk Jitter & Noise Visual Representation

To convey a hacker theme, "imperfect" jitter routing (such as VPN Tunneling or Proxy Bounces) should be stylized as high-tech visual glitches.

### A. Glitchy Line2D Trail Renderer
Minions leave trails representing network paths. Under jitter, these paths fragment:
- **Implementation**: A `Line2D` node attached to the minion.
- **Shader Effect**: A scrolling texture shader that maps glowing grid patterns or 0s/1s along the trail.
- **Jitter Scaling**:
  - **Low Jitter**: A continuous, solid glowing cyber-trail.
  - **High Jitter**: The shader uses a 1D noise texture to dissolve/erode sections of the trail (alpha erosion), creating a fragmented, packetized look.
  - **Amplitude Drift**: The width of the trail fluctuates dynamically with the magnitude of the perpendicular jitter offset.

### B. Chromatic Aberration & Color Shifting
As the minion undergoes sudden jitter deviations:
- **Shader Effect**: A CanvasItem shader on the Minion's `Sprite2D` that separates red, green, and blue texture coordinates based on speed and lateral acceleration.
- **Visual Outcome**: When jumping laterally due to high-amplitude jitter, the sprite splits color channels (a neon red/blue fringe). This gives the illusion that the data packet is vibrating or de-cohering during hops.

### C. Scanline Glitch Overlay
- **Shader Effect**: A screen-space or sprite-local glitch shader.
- **Mechanism**: Periodically offsets horizontal bands of the sprite texture using a noise generator.
- **Parameter Mapping**:
  - `glitch_intensity` maps directly to the absolute value of the jitter offset.
  - `glitch_frequency` maps to the routing strategy's frequency.

### D. Velocity-Dependent Sprite Shearing
Instead of standard sprite squash/stretch, use digital shearing (skewing):
- **Effect**: Skew the sprite's vertices along the velocity vector.
- **Godot Shader Code Example**:
  ```glsl
  shader_type canvas_item;
  uniform float shear_strength = 0.1;
  void vertex() {
      // Skew sprite horizontally based on vertical movement
      VERTEX.x += VERTEX.y * shear_strength;
  }
  ```

---

## 3. Packet Type Aesthetics & Pathing Visuals

Different network ports spawn minions with unique cyber-aesthetics:

| Port / Packet Type | Color Palette | Trail Visuals | Special VFX Features |
| :--- | :--- | :--- | :--- |
| **Port 80: HTTP Packet** (Swarm, unshielded) | Neon Cyan (`#00FFFF`), Warning Yellow (`#FFCC00`) | Solid, thin, ultra-glowing laser vector trail. | Spawns tiny pixel-sparks on path adjustments. Glitches and explodes into binary `0`s and `1`s on death. |
| **Port 443: HTTPS Packet** (Shielded, secure) | Cyber Jade (`#39FF14`), Deep Cobalt (`#0047AB`) | Double-helix braided trail representing encryption keys. | Enclosed in a hexagonal vector shield. Shield absorbs damage with a liquid-ripple distortion. |
| **Port 22: SSH Packet** (Stealth, encrypted) | Obsidian Purple (`#301934`), Hot Magenta (`#FF007F`) | Dotted, fading tunnel paths. | Semi-transparent after-image/ghosting trails. Emits tiny purple spark particles when evading boss scanners. |

---

## 4. Dynamic Audio Design & Pitch Modulation

Since Neon Netrun utilizes synthetic sounds, minion movement should be supported by procedural audio modulation rather than static files.

### A. Engine Hum Synthesizer
- **Source**: A looping synth drone (composed of triangle and sawtooth waves).
- **Speed Modulation**: Bind the pitch of the hum to `velocity.length()`.
  - Normal Speed (120 units): Low-end hum (~100 Hz).
  - CHMOD Boost (240 units): Glides up to a high-pitched digital whine (~350 Hz).
- **Jitter Modulation**: Bind the lateral jitter offset to stereo panning.
  - As the minion shifts left, pan the hum left; as it shifts right, pan it right.
  - At high frequency (0.02), this creates a rapid panning effect that psychoacoustically communicates "network noise" or packet jitter.

### B. Syscall Audio Triggers
- **CHMOD Speed Boost (`sudo chmod +x`)**: A rapid retro synth sweep rising in pitch (overclocking sound), followed by a high-frequency filter sweep.
- **PING DDoS Detonation (`ping -f`)**: A heavy digital bass drop (EMP sub-bass) combined with a high-pitched chip-noise burst.

### C. Steering Clicks & Transitions
- **Pathing Correction Click**: A brief, low-volume high-frequency synth tick (resembling a relays click or terminal execution sound) whenever the routing component computes a direction change of more than 45 degrees.

---

## 5. VFX/SFX Requirements for Steering & Transitions

### 1. Routing Strategy Switch (e.g., Direct -> VPN / Jitter)
- **VFX**: Trigger an expanding cyber-grid ring (`GPUParticles2D` ring emission with flat square particles) from the minion's origin.
- **SFX**: Play a brief dual-tone electronic chirp (`sfx_handshake.wav`), signifying routing handshakes.

### 2. Inertial Ejection on Sharp Steering
- **VFX**: When steering force exceeds a specific threshold (sharp turning), emit flat square particles opposite to the turn vector, representing packet buffer bleed-off.
- **SFX**: A pitch-down dip in the core motor hum, indicating a momentary loss of forward momentum.

### 3. CHMOD Speed Boost Transition
- **Start**:
  - **VFX**: A chromatic flash covering the minion, sprite scales forward (stretching), leaving a persistent bright neon cyan trail.
  - **SFX**: A synthesizer pitch riser.
- **End**:
  - **VFX**: A small visual puff of digital code-smoke (0/1 characters) dispersing outward.
  - **SFX**: A fading spin-down whine.
