# Test Plan: Neon Netrun

This document outlines the testing strategy, automated test suites (GUT), and execution guidelines for **Neon Netrun**, an inverted cyberpunk hacking swarm shooter.

---

## 1. Testing Strategy

We employ a **three-tier testing strategy** using the GUT library, ensuring verification across all layers of modular logic before full deployment:

1. **Unit Tests**: Focus on isolating individual components, math algorithms, class properties, and signal emission behaviors in stubs.
2. **Integration Tests**: Verify interactions between network spawners, minions, global Event Bus (`NetrunEvents`), and the Boss Core (e.g., protocol shielding, stealth delays, and detonating packets triggering stuns).
3. **End-to-End (E2E) Tests**: Simulate full loops (spawning minions, pathing to target, Boss stuns, damage amplification, recovery system purges, and core destruction).

---

## 2. Automated GUT Test Suites

The following test suites have been implemented inside the modular `tests/` subdirectories:

### A. Unit Tests
* **Minion Base (`res://Entities/Netrun/Minions/tests/test_minion_base.gd`)**
  * `test_default_values`: Checks initial speed, health, and Direct Fiber pathing values.
  * `test_apply_routing_upgrade`: Verifies transition from low jitter (Direct Fiber) to high jitter (VPN Tunneling).
  * `test_take_damage_without_shield`: Verifies standard damage reduction.
  * `test_take_damage_with_shield`: Verifies Port 443 (HTTPS) barrier absorption.
  * `test_destroy_frees_node`: Assures zero memory leaks by validating node queueing for deletion.

* **Port Spawner (`res://Entities/Netrun/Spawners/tests/test_port_spawner.gd`)**
  * `test_default_values`: Validates base port type (HTTP) and base cooldowns.
  * `test_set_focus_doubles_bandwidth`: Verifies Gateway Overclocking doubles spawn speed.
  * `test_focus_emits_alert_signal`: Assures the Boss AI core is notified of the spawner's overclock position.

* **Boss Core (`res://Entities/Netrun/Boss/tests/test_boss_core.gd`)**
  * `test_default_values`: Confirms base state configuration.
  * `test_take_damage_normal`: Checks normal damage.
  * `test_take_damage_during_buffer_overflow`: Validates double-damage modifier during stun.
  * `test_ddos_accumulation_triggers_stun`: Verifies 10 hits within the window trigger `BUFFER_OVERFLOW` stun.
  * `test_stun_duration_and_recovery`: Verifies auto-recovery and return to `ACTIVE` after stun timers expire.

### B. Integration Tests
* **Gameplay Integration (`res://Entities/Netrun/tests/test_netrun_integration.gd`)**
  * `test_port_443_shielded_spawning`: Tests that spawners set the defensive barrier flag on HTTPS minions.
  * `test_port_22_stealth_spawning`: Tests that spawners set the stealth/untraceable flag on SSH minions.
  * `test_syscall_ddos_detonation_applies_boss_stun`: Tests global Event Bus `ping_blast` trigger causing minion self-destruction and Boss stun state transition.

### C. End-to-End (E2E) Tests
* **Battle Cycle (`res://Entities/Netrun/tests/test_netrun_e2e.gd`)**
  * `test_complete_battle_loop`: Runs a full simulation of the intrusion battle phase. Validates: spawn automation -> navigation to target -> DDoS accumulation -> stun state transition -> double damage processing -> stun timeout -> System Purge recovery -> and core destruction.

---

## 3. How to Run Tests

### Command Line (Headless)
Execute the tests using the project's Godot executable path from PowerShell/cmd. 
Specify the directory `res://Entities/Netrun` and include subdirectories:

```powershell
Start-Process "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" `
    -ArgumentList "--headless", "--path", "Source", "-s", "addons/gut/gut_cmdln.gd", "-gdir=res://Entities/Netrun", "-ginclude_subdirs", "-gexit" `
    -NoNewWindow -Wait
```

### Godot Editor GUI
1. Open the project in Godot.
2. In the bottom dock, click the **GUT** tab.
3. Set **Directory 1** to `res://Entities/Netrun`.
4. Click **Run All**.
