# Technical Guidelines & Coding Standards

All developers (Coder, UI Designer, VFX/SFX Generator, Tester) must adhere to these guidelines during implementation. The Technical Architect will reject any code that violates these.

## 1. Core Principles
* **Domain-Driven Design (DDD)**: Folder structures must reflect game domains. Keep assets, scripts, scenes, and tests localized to their functional domain component.
* **Composition over Inheritance**: Implement reusable gameplay behaviors as child nodes (components) rather than extending scripts with deep inheritance hierarchies.
* **Keep It Simple Stupid (KISS)**: Write clean, readable code. Avoid over-engineering.
* **Don't Repeat Yourself (DRY)**: Keep shared or generic utilities inside the `framework` or `core` components folder.
* **Static Typing**: Every variable, function parameter, and function return type must be statically typed in GDScript (e.g. `var speed: float = 100.0`, `func update(delta: float) -> void`).

## 2. Godot Best Practices
* **Signals & Communication**: Use **"signal up, call down"** inside node trees. Parents call methods directly on children. Children emit signals to notify parents of events. Avoid hard references up the tree.
* **Custom Resources**: Use custom `Resource` classes for data configurations, combat stats, and upgrades.
* **Scene Inheritance**: For entity variations (different minions, bosses, levels), save each variant as a distinct inherited scene (`.tscn`) rather than handling variation flags inside a single scene or script.

## 3. Testing Standards
* **Naming**: All test scripts must reside inside the component's folder and follow the `tests_` prefix naming convention (e.g. `tests_steering.gd`) for auto-discovery by GUT.
* **Scope**: Maintain unit, integration (inter-component/system), and UI tests where appropriate.
