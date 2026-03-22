# Task: apex-audit

```yaml
id: apex-audit
version: "1.0.0"
title: "Apex Squad Readiness Audit"
description: >
  Diagnostic command that analyzes the current project and reports squad readiness:
  which agents are relevant, which veto conditions work, which tools are installed,
  and which profile to recommend. Run this before first use of the squad in a project.
elicit: false
owner: apex-lead
executor: apex-lead
outputs:
  - Readiness report with score
  - Recommended profile
  - List of working/broken veto conditions
  - List of available/missing tools
```

---

## Command

### `*apex-audit`

Diagnose squad readiness for the current project. No user input needed.

---

## Execution Steps

### Step 1: Detect Stack

Read `package.json` (and `package-lock.json` if needed) to detect:

```yaml
detection_checks:
  - check: "react in dependencies"
    result: has_react
  - check: "react-dom in dependencies"
    result: has_react_dom
  - check: "next in dependencies"
    result: has_next
  - check: "vite in dependencies"
    result: has_vite
  - check: "react-native in dependencies"
    result: has_react_native
  - check: "expo in dependencies"
    result: has_expo
  - check: "three in dependencies"
    result: has_three
  - check: "@react-three/fiber in dependencies"
    result: has_r3f
  - check: "tailwindcss in dependencies/devDependencies"
    result: has_tailwind
  - check: "framer-motion OR motion in dependencies"
    result: has_motion
  - check: "@testing-library/react in devDependencies"
    result: has_testing_library
  - check: "typescript in devDependencies"
    result: has_typescript
```

### Step 2: Determine Profile

```
IF has_react_native OR has_expo:
  IF has_next: profile = "full"
  ELSE: profile = "full"  # mobile needs full squad
ELIF has_next:
  profile = "web-next"
ELIF has_react AND has_vite:
  profile = "web-spa"
ELIF has_react:
  profile = "web-spa"
ELSE:
  profile = "minimal"
```

### Step 3: Check Agent Relevance

For each of the 15 agents, check if their domain is relevant:

```yaml
agent_relevance:
  apex-lead:      always_relevant
  frontend-arch:  relevant_if: [has_next, has_react_native, monorepo_detected]
  interaction-dsgn: always_relevant
  design-sys-eng: relevant_if: [packages_tokens_exists, figma_config_exists]
  css-eng:        relevant_if: [has_react]  # always for web
  react-eng:      relevant_if: [has_react]
  mobile-eng:     relevant_if: [has_react_native, has_expo]
  cross-plat-eng: relevant_if: [has_react_native AND has_react_dom]
  spatial-eng:    relevant_if: [has_three, has_r3f]
  motion-eng:     relevant_if: [has_motion]
  a11y-eng:       always_relevant
  perf-eng:       always_relevant
  qa-visual:      relevant_if: [chromatic_installed, storybook_installed]
  qa-xplatform:   relevant_if: [has_react_native, playwright_installed]
```

### Step 4: Check Tool Availability

Run existence checks for each tool referenced by veto conditions:

```yaml
tool_checks:
  - tool: "TypeScript compiler"
    check: "npx tsc --version 2>/dev/null"
    used_by: [QG-AX-010]

  - tool: "Lint"
    check: "npm run lint --dry-run 2>/dev/null || npx eslint --version 2>/dev/null || npx biome --version 2>/dev/null"
    used_by: [QG-AX-010]

  - tool: "Test runner"
    check: "npm test --dry-run 2>/dev/null || npx vitest --version 2>/dev/null || npx jest --version 2>/dev/null"
    used_by: [QG-AX-010]

  - tool: "axe-core / a11y testing"
    check: "npm run test:a11y --dry-run 2>/dev/null"
    used_by: [QG-AX-005]

  - tool: "Lighthouse CI"
    check: "npx lhci --version 2>/dev/null"
    used_by: [QG-AX-007]

  - tool: "Storybook"
    check: "npm run storybook:build --dry-run 2>/dev/null || npx storybook --version 2>/dev/null"
    used_by: [QG-AX-008]

  - tool: "Chromatic"
    check: "npx chromatic --version 2>/dev/null"
    used_by: [QG-AX-008]

  - tool: "Playwright"
    check: "npx playwright --version 2>/dev/null"
    used_by: [QG-AX-009]

  - tool: "Bundle analyzer"
    check: "npm run analyze:bundle --dry-run 2>/dev/null"
    used_by: [QG-AX-007]
```

### Step 5: Check Veto Condition Viability

For each veto condition in `data/veto-conditions.yaml`:
- If `available_check` exists → run it
- If referenced paths don't exist in project → mark as SKIP
- If referenced npm scripts don't exist → mark as SKIP
- Otherwise → mark as ACTIVE

### Step 6: Generate Report

```
APEX SQUAD READINESS AUDIT
===========================

Project: {project name from package.json}
Stack: {detected stack summary}
Profile: {recommended profile}

AGENTS ({active_count}/{total_count} active)
---------------------------------------------
 ACTIVE   @apex-lead (Emil) — Orchestrator
 ACTIVE   @css-eng (Josh) — CSS/Layout/Responsive
 ACTIVE   @react-eng (Kent) — React Components
 ACTIVE   @motion-eng (Matt) — Spring Animations
 ACTIVE   @a11y-eng (Sara) — Accessibility
 ACTIVE   @perf-eng (Addy) — Performance
 ACTIVE   @interaction-dsgn (Ahmad) — UX Patterns
 ACTIVE   @qa-visual (Andy) — Visual QA
 SKIP     @frontend-arch (Arch) — No Next.js/monorepo
 SKIP     @design-sys-eng (Diana) — No token system
 SKIP     @mobile-eng (Krzysztof) — No React Native
 SKIP     @cross-plat-eng (Fernando) — No cross-platform
 SKIP     @spatial-eng (Paul) — No 3D/WebXR
 SKIP     @qa-xplatform (Michal) — No mobile platform

TOOLS ({available_count}/{total_count} available)
--------------------------------------------------
 OK       TypeScript compiler (tsc)
 OK       Lint (eslint/biome)
 MISSING  Test runner (vitest/jest)
 MISSING  axe-core (a11y testing)
 MISSING  Lighthouse CI
 MISSING  Storybook
 MISSING  Chromatic
 MISSING  Playwright
 MISSING  Bundle analyzer

VETO CONDITIONS ({active_count} active / {skip_count} skipped)
---------------------------------------------------------------
 ACTIVE   VC-010-B — TypeScript errors (npm run typecheck)
 ACTIVE   VC-010-C — Lint errors (npm run lint)
 SKIP     VC-001-A — Hardcoded hex (packages/ui/ not found)
 SKIP     VC-005-A — axe-core (test:a11y not configured)
 SKIP     VC-007-A — Lighthouse (not installed)
 SKIP     VC-008-A — Chromatic (not installed)
 ...

QUALITY GATES ({enforced_count}/{total_count} enforced)
--------------------------------------------------------
 ENFORCED  QG-AX-010 — Lead Sign-off (typecheck + lint)
 PARTIAL   QG-AX-005 — Accessibility (manual only, no axe-core)
 PARTIAL   QG-AX-007 — Performance (manual only, no Lighthouse CI)
 SKIP      QG-AX-001 — Token Validation (no token system)
 SKIP      QG-AX-008 — Visual Regression (no Chromatic)
 SKIP      QG-AX-009 — Cross-Platform (no mobile)
 ...

READINESS SCORE: {score}/10
RECOMMENDED COMMANDS: *apex-fix, *apex-quick
RECOMMENDED SETUP: Install vitest, axe-core for better coverage

===========================
```

---

## Scoring

```yaml
scoring:
  base_score: 5  # Having React + TypeScript

  bonuses:
    - "+1 if lint configured"
    - "+1 if test runner available"
    - "+1 if a11y testing available"
    - "+1 if performance testing available (Lighthouse)"
    - "+1 if visual regression available (Chromatic/Percy)"
    - "+1 if E2E testing available (Playwright/Cypress)"

  penalties:
    - "-1 if no TypeScript"
    - "-1 if no lint"
    - "-2 if no test runner AND no lint"

  max_score: 10
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | User (diagnostic report) |
| Next action | User decides which tools to install, or proceeds with current setup |

---

*Apex Squad — Readiness Audit Task v1.0.0*
