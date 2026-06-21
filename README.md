# AG_Game - Godot AI Agent Round Table

This repository features a fully integrated **AI Agent Round Table** for Godot 4.x game development. It leverages specialized developer personas (configured as workspace customizations) to automate game design, technical architecture, coding, unit testing, and packaging.

## 🚀 Quick Start

1. **Prerequisites**: Ensure you have [uv](https://docs.astral.sh/uv/) installed.
2. **Run the Round Table**: Execute the orchestrator script to simulate a development cycle for a gameplay feature:
   ```bash
   uv run round_table/round_table.py --prompt "Add double-jump to player character"
   ```
3. **View the Dashboard**: Once completed, open the generated HTML report to see the discussion, code changes, unit tests, and build logs:
   [round_table_dashboard.html](file:///e:/Godot/Projects/AntiGravityWorkspace/AG_Game/round_table/round_table_dashboard.html) in your browser.

---

## 👥 The Agent Team (Personas)

- **🤖 Coordinator**: Project manager who governs the workflow and aggregates results.
- **📜 Game Designer**: Designs mechanics and writes the **Game Design Document (GDD)**.
- **📐 Technical Architect**: Reviews design structures, enforces patterns, and writes the **Technical Architecture Document (TAD)**.
- **💻 GDScript Expert**: Writes statically-typed GDScript 2.0 and setups component interactions.
- **🏗️ Scene Architect**: Structures the node tree and configures UI/visual dependencies.
- **🛡️ QA Tester**: Implements GUT automated test suites and writes manual test checklists.
- **🚀 DevOps Expert**: Configures export presets and runs multi-platform packaging (Windows, Linux, Android).

---

## 📂 Project Structure & Best Practices

All assets, scripts, scenes, and tests for a specific entity are stored in a **single self-contained directory** under `Source/Entities/` (no global file segregation):
- **Documentation**: Game Design and Technical Architecture documents are kept in separate subdirectories inside `Documentation/`.
- **Automated Tests**: Unit and integration tests are placed under a local `tests/` subdirectory in the entity's folder.
- **Coding Style**: Strict static typing is enforced for all variables and functions.
- **Architecture**: Component-based layout is favored over inheritance trees.