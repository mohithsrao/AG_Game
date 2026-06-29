# Manual Verification Checklist: Neon Netrun

This checklist covers aspects of **Neon Netrun** that cannot be fully automated through GUT tests, including game feel, visual animations, shader effects, and audio loudness.

---

## 1. Visuals & Shaders (VFX)

- [ ] **Glitch VFX (`glitch_vfx.tres`)**:
  - Verify that the glitch overlay shader triggers dynamically when the Boss Core enters the `BUFFER_OVERFLOW` (stun) state.
  - Verify screen-space texture distortions remain legible and do not cause player motion sickness.
- [ ] **Rotating Matrix Block**:
  - Check that the `MatrixSprite` inside `boss_core.tscn` rotates smoothly.
  - Verify that the rotation speed increases by at least 2.5x during `SYSTEM_PURGE` or scanning attacks.
- [ ] **Anti-Virus Scanner Beam**:
  - Verify that the rotating targeted laser beam casts a distinct red tracking outline on the grid.
  - Check that the laser traces a visible route preview 0.5 seconds before firing.
- [ ] **System Purge shockwave**:
  - Verify that the expansion of the `PurgeArea` has a clear neon ripple visual shader expanding outwards.
  - Check that code explosion particles (`code_explosion_particles.tres`) spray in vector style upon boss core destruction.

---

## 2. Audio & Loudness (SFX)

- [ ] **Anti-Virus Beam sound (`sfx_anti_virus_beam.wav`)**:
  - Check that the laser charge-up and firing sounds are spatialized (decrease in volume as the camera moves away from the Boss).
  - Verify loudness levels conform to game guidelines (-12 dB peak target).
- [ ] **Stun sound (`sfx_buffer_overflow.wav`)**:
  - Verify the low-frequency drone sound plays immediately upon the Boss entering the `BUFFER_OVERFLOW` state.
  - Confirm the audio cue resolves with a high-pitched restart tone upon recovery.
- [ ] **System Purge shockwave sound**:
  - Verify a heavy base "whoosh" sound is played during the minion deletion shockwave.
  - Ensure the sound registers clearly over background music.

---

## 3. Game Feel & Interaction

- [ ] **Drag and Drop Hack Configuration**:
  - Verify that dragging port cards from the inventory onto the grid snaps precisely to the grid intersection lines.
  - Confirm that invalid port placement (e.g., placing ports too close to the Boss Core) shows a flashing red grid warning.
- [ ] **Gateway Overclock / Focus**:
  - Verify that clicking an active gateway changes its visual state (adds a high-voltage glowing aura).
  - Confirm that the Boss Anti-Virus scanner immediately rotates and locks onto the focused gateway.
- [ ] **Low Jitter vs High Jitter Movement**:
  - Verify that minions with VPN Tunneling (high jitter) weave naturally and look like "bouncing data packets."
  - Verify that Direct Fiber minions move in straight lines with appropriate speed acceleration.

---

## 4. Game Loop Transitions

- [ ] **Preparation -> Battle transition**:
  - Check that clicking "Initiate Hack" transitions UI states cleanly without screen flickering.
  - Verify the grid-based HUD overlays disappear, and the active hacking console hud slides in.
- [ ] **Battle -> Upgrade Shop transition**:
  - Verify that defeating the Digital Core loads the Evolution Shop menu.
  - Check that the upgrade card selection is responsive to hover and click inputs.
