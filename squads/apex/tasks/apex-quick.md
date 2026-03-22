# Task: apex-quick

```yaml
id: apex-quick
version: "1.0.0"
title: "Apex Quick Pipeline"
description: >
  Lightweight 3-phase pipeline for changes that are too big for *apex-fix
  but don't need the full 7-phase pipeline. No design spec, no architecture
  docs, no separate polish cycle. Specify → Implement → Ship.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-route-request.md
  - data/veto-conditions.yaml
outputs:
  - Implemented feature/change
  - Typecheck + lint + a11y passing
  - Ready for commit
```

---

## Command

### `*apex-quick {description}`

3-phase pipeline for medium-scoped changes. Skips design docs, architecture docs, and separate polish cycle. Quality checks are integrated into the implementation phase.

---

## When to Use

- New simple component (button variant, card, badge)
- Multi-file change across 2-3 domains (CSS + React + animation)
- Refactor of existing component (restructure, add states)
- UI enhancement (redesign section, add responsive behavior)
- Changes touching 3-10 files

## When NOT to Use

- Single-file fix → `*apex-fix`
- New feature with complex user flows → `*apex-go`
- Cross-platform (web + mobile) → `*apex-go`
- Changes requiring design approval from stakeholder → `*apex-go`

---

## Phases

### Phase 1: Specify (CP-QK-01)

**Agent:** apex-lead
**Checkpoint:** CP-QK-01 (user confirms scope)

```
apex-lead analyzes the request:

1. Route using apex-route-request.md
2. Identify all agents needed
3. List files likely to be modified
4. Present scope summary to user:

   *apex-quick scope*

   Feature: "{description}"
   Agents: @css-eng, @react-eng, @motion-eng
   Estimated files: 3-5
   Approach: {brief plan}

   Proceed? (yes / adjust / upgrade to *apex-go)
```

**On user approval:** Proceed to Phase 2.
**On "adjust":** Revise plan, re-present CP-QK-01. Max 2 revisions.
**On "upgrade":** Switch to `*apex-go` with same description.

---

### Phase 2: Implement

**Agents:** Determined by routing in Phase 1
**Execution:** Sequential (agent by agent) or parallel where independent

```
For each agent in the plan:
  1. Agent reads relevant files
  2. Agent implements their part
  3. Agent runs domain-specific checks:
     - @css-eng: responsive behavior verified
     - @react-eng: component renders all states
     - @motion-eng: spring configs applied, reduced-motion handled
     - @a11y-eng: axe-core check, keyboard nav, contrast
     - @perf-eng: no performance regression
  4. If check fails: agent fixes (max 2 attempts), then escalate to apex-lead
```

**Integrated polish:** Unlike the full pipeline, polish is NOT a separate phase. Each agent applies polish as part of implementation:
- @motion-eng applies springs during implementation, not after
- @a11y-eng checks during implementation, not after
- @perf-eng validates during implementation, not after

---

### Phase 3: Ship (CP-QK-02)

**Agent:** apex-lead
**Checkpoint:** CP-QK-02 (user confirms ship)

```
1. Run quality checks:
   - npm run typecheck (or npx tsc --noEmit)
   - npm run lint
   - npm test (if exists)

2. Present summary:

   *apex-quick complete*

   Feature: "{description}"
   Agents used: @css-eng, @react-eng, @motion-eng
   Files modified:
     - src/components/Header.tsx
     - src/components/Modal.tsx
     - src/index.css
   Checks: typecheck PASS | lint PASS | tests PASS

   Ready to commit?

3. On user approval: user commits (or ask Claude to commit)
4. Do NOT push — delegate to @devops if user wants to push
```

---

## Quality Gates (Reduced Set)

Only 3 gates for quick pipeline:

| Gate | Check | Blocking |
|------|-------|----------|
| QG-QK-001 | Zero new TypeScript errors | YES |
| QG-QK-002 | Zero new lint errors | YES |
| QG-QK-003 | No test regressions | YES (if tests exist) |

**Skipped gates (vs full pipeline):**
- QG-AX-001 (Token validation) — no token system in web-spa profile
- QG-AX-002 (Figma spec) — no Figma in quick pipeline
- QG-AX-003 (Design approval) — integrated into CP-QK-01
- QG-AX-004 (Architecture review) — skipped for quick changes
- QG-AX-008 (Visual regression) — no Chromatic in web-spa profile
- QG-AX-009 (Cross-platform) — web-only in quick pipeline

**Always enforced (even in quick):**
- Accessibility: if @a11y-eng is used, zero critical axe-core violations
- Performance: if @perf-eng is used, no regression beyond 10%
- QG-AX-010 items: typecheck + lint must pass

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-QK-001
    condition: "Change creates new shared package"
    action: "BLOCK — shared packages require *apex-go with architecture review"
    blocking: true

  - id: VC-QK-002
    condition: "Change spans more than 15 files"
    action: "WARN — consider upgrading to *apex-go for proper tracking"
    blocking: false

  - id: VC-QK-003
    condition: "Change requires cross-platform (web + mobile)"
    action: "BLOCK — cross-platform requires *apex-go"
    blocking: true
```

---

## Examples

**Example 1 — New card component:**
```
User: *apex-quick "add a stats card to the dashboard with animation"
Emil: [Phase 1] Routing: @react-eng (structure) + @css-eng (styling) + @motion-eng (entrance)
      3 agents, ~4 files. Proceed?
User: yes
Emil: [Phase 2] @react-eng creates StatsCard, @css-eng styles it, @motion-eng adds spring entrance
Emil: [Phase 3] All checks pass. 4 files modified. Ready to commit?
```

**Example 2 — Responsive redesign:**
```
User: *apex-quick "make the services section responsive with better mobile layout"
Emil: [Phase 1] Routing: @css-eng (layout) + @interaction-dsgn (mobile UX)
      2 agents, ~2 files. Proceed?
User: yes
Emil: [Phase 2] @interaction-dsgn defines mobile layout, @css-eng implements
Emil: [Phase 3] All checks pass. Ready to commit?
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | User (changes applied locally) |
| Next action | User commits, then optionally delegates push to @devops |

---

*Apex Squad — Quick Pipeline Task v1.0.0*
