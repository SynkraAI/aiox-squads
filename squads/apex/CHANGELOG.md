# Changelog — Apex Squad

## [1.1.0] — 2026-03-07

### Added
- **7 Discovery Tools** (was 2): routes, dependencies, motion, a11y, performance
- **Visual Analysis**: *apex-analyze (8 dimensions), *apex-compare, *apex-consistency
- **Agent Handoff Protocol**: visible delegation, specialist intros, chain suggestions
- **8 Gap Fixes**: code review, dark mode audit, design critique, export tokens, integration tests, refactor workflow, responsive breakpoints, conditional after_transform
- **Intelligence Enhancements**: 17 intent chains (was 12), 10 caches (was 5), conditional after_transform by preset category
- **31 Design Presets**: Apple, Google, Tech, Movements, Industry, Dark, Experimental
- **Style Commands**: *apex-inspire, *apex-transform with token override
- **Config**: squad-config.yaml (centralized operational config)
- **README.md rewritten**: complete documentation of all capabilities

### Changed
- Tasks: 67 → 84 (+17)
- Workflows: 7 → 8 (+1 component refactor)
- Intent chains: 12 → 17 (+5 for new discoveries)
- Context caches: 5 → 10 (+5 for new discoveries)
- Veto conditions: 85% coverage → 100% (all have available_check)
- design-presets.yaml: fixed count 42 → 31 (actual)
- responsive-audit.md: added mandatory breakpoints (320/375/768/1024/1440) + 3 veto conditions
- apex-intelligence.yaml: after_transform now conditional by preset category (6 categories)
- apex-entry.md: integrated handoff protocol reference
- apex-fix.md: integrated handoff protocol (delegation + specialist intro)

## [1.0.0] — 2026-03-01

### Initial Release
- 15 agents (1 orchestrator + 14 specialists) with DNA from real frontend leaders
- 67 tasks covering all frontend domains
- 7 workflows (feature build, pipeline, component create, cross-platform sync, design-to-code, polish cycle, ship validation)
- 28 checklists for quality validation
- 13 templates for documentation
- 9 data files (agent registry, veto conditions, pipeline state, performance budgets, spring configs, design tokens, platform capabilities, intelligence, presets)
- 10 quality gates with 4 enforcement levels
- 4 auto-detected profiles (full, web-next, web-spa, minimal)
- Pipeline executor with 7 phases, 6 checkpoints, 8 commands
- Discovery tools: *discover-components, *discover-design
- Single entry point: @apex {natural language}
- AIOS integration with handoff artifacts
