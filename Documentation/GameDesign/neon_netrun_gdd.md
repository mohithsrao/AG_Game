# Game Design Document (GDD): Neon Netrun

## 1. Feature & Concept Overview
**Neon Netrun** is an inverted swarm shooter roguelike with a Cyberpunk hacking theme. Instead of controlling a mobile hero character, the player acts as the intruder hacker composing spawn nodes on a grid level to swarm and destroy an AI-controlled Boss—the **Digital Core**—to progress to the next server node.

The game is designed with a vector/grid-based aesthetic that completely avoids character rigging constraints.

---

## 2. Core Game Mechanics

### 2.1 The Boss (Digital Core)
- **Visuals**: A giant, floating, rotating digital matrix block composed of glowing code segments.
- **Movement**: Automatically hovers across the grid level using dynamic vector pathing.
- **Attacks**:
  - **Firewall Sweeps**: Sweeping red laser barriers that deal heavy damage to minions passing through.
  - **Anti-Virus Scanners**: A rotating targeted laser beam that traces routes and destroys minions/spawners.
  - **Code-Deletion Projectiles**: Fires floating packets of zero/ones that delete player minions.
- **Boss State - Buffer Overflow**: If the Boss is hit by a specific threshold of DDoS packets within a short window, it suffers a *Buffer Overflow*—freezing its movement and weapon systems for 3 seconds and taking double damage.
- **Boss Counter-Play - System Purge**: Upon recovering from a Buffer Overflow stun, the Boss core triggers a *System Purge* wave—a circular shockwave expanding outwards that sweeps and deletes all current minions on screen. (Note: This mechanic unlocks in later server nodes to scale up the challenge).

### 2.2 Network Spawners (Active Gateways)
Instead of placing minions freely, the player hijacks specific network ports to spawn their attacks:
- **Port 80 (HTTP)**: High-speed, low-cost port. Ideal for swarming DDoS packets.
- **Port 443 (HTTPS)**: Shielded port. Spawns minions with temporary defensive barriers.
- **Port 22 (SSH)**: Stealth port. Minions spawned here are untraceable by the Boss's scanner laser for the first 3 seconds.
- **Gateway Focus (Overclocking)**: The player can click/focus on a specific Active Gateway in real-time. This doubles the port's spawning bandwidth for 5 seconds but increases its heat/signature, drawing the Boss's Anti-Virus Scanner laser directly to it.

### 2.3 Minion "Syscall" Cooldowns
The player can manually trigger high-impact tactical actions associated with active minion types:
- **Trojan Horse (`sudo chmod +x`)**: Gives all active Trojans on screen a temporary 2-second speed boost and firewall immunity to charge down the Core.
- **DDoS Packets (`ping -f`)**: Instantly detonates all active circle packets on screen, creating a localized EMP wave that accelerates Boss stun triggers.
- **Logic Bomb (`trigger_payload`)**: Triggers manual detonation of placed mines early instead of waiting for the Boss to float over them.

### 2.4 Network Jitter (Routing Upgrades)
Minion travel pathing is governed by network quality, which the player can upgrade in the Shop:
- **Direct Fiber Routing (Low Jitter)**: Minions travel in a straight, high-speed line directly to the Boss (high damage rate, but highly vulnerable to firewalls).
- **VPN Tunneling / Proxy Bounce (High Jitter)**: Minions travel in random, unpredictable zig-zag trajectories (evades scanner beams, but takes longer to reach the target).
- **Packet Redundancy**: Gives spawned minions a chance to create duplicate decoy packets that draw scanner fire.

---

## 3. Core Game Loop
1. **Preparation Phase (Hack Configuration)**:
   - Drag and drop hijacked ports onto the level grid.
   - Assign minion cards from inventory to ports.
2. **Battle Phase (Intrusion)**:
   - The network intrusion runs. Spawner ports automate the swarms.
   - The player manages Gateway Focus in real-time and triggers Syscall cooldowns to break through defenses.
   - The Digital Core fires firewall counter-measures, runs anti-virus sweeps, and releases System Purge waves.
3. **Evolution Phase (Upgrades Shop)**:
   - Player spends decrypted data credits to buy new port templates, minion cards, or active commands.
   - The Digital Core installs patch updates (Evolutions) like increased firewall speeds or homing projectiles.
