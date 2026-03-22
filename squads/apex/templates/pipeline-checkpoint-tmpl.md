# Pipeline Checkpoint Templates

```yaml
id: pipeline-checkpoint-tmpl
version: "1.0.0"
title: "Apex Pipeline Checkpoint Templates"
description: >
  Presentation templates for the 6 user checkpoints in the Apex Pipeline.
  Each checkpoint pauses the pipeline to collect a creative decision from
  the user. The pipeline automates the PROCESS — the user decides the WHAT.
owner: apex-lead
```

---

## CP-01: Feature Brief

**When:** Start of pipeline (Phase 1: Specify)
**Purpose:** User describes WHAT they want to build

### Presentation Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ CHECKPOINT CP-01 — Feature Brief
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline: {pipeline.id}
Mode: {pipeline.mode}

I need your creative direction before the pipeline can begin.

**What do you want to build?**

Please describe:
1. **Feature:** What is the feature? (e.g., "notification system with toast and badge")
2. **Platforms:** Which platforms? (web / mobile / spatial / all)
3. **Constraints:** Any specific requirements? (e.g., "must match existing header style")

Routing analysis: {scope_classification}
{if scope == single-agent}
💡 This looks like a single-specialist task. Consider using `*apex-fix "{feature}"`
   instead of the full pipeline. Want to continue with the full pipeline? (y/n)
{/if}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Your decision starts the pipeline. Take your time.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Expected Input
- Free-form feature description
- Platform list
- Optional constraints

### State Update
```yaml
CP-01:
  status: completed
  decision: "{user's feature description}"
  decided_at: "{timestamp}"
pipeline:
  target_platforms: ["{platforms from user}"]
```

---

## CP-02: Design Review

**When:** After design phase completes (Phase 2: Design)
**Purpose:** User approves design spec or requests changes

### Presentation Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ CHECKPOINT CP-02 — Design Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline: {pipeline.id}
Phase: Design (2/7)
Agents: @interaction-dsgn → @design-sys-eng

**Design artifacts produced:**

| Artifact | Status |
|----------|--------|
| Design Spec | ✅ {path} |
| Token Map | ✅ {path} |
| Component API | ✅ {path} |
| Responsive Variants | ✅ {path} |

**Quality Gates:**

| Gate | Status |
|------|--------|
| QG-AX-001 Token Validation | {PASS/FAIL} |
| QG-AX-002 Spec Completeness | {PASS/FAIL} |
| QG-AX-003 Design Approved | ⏳ Awaiting your decision |

**Design Summary:**
{summary of key design decisions from design-spec.md}

**Your decision:**
- **APPROVE** — Design looks good, proceed to architecture
- **REVISE** — Describe what needs to change

{if revision_count > 0}
📝 Revision {revision_count}/3
{/if}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Expected Input
- `APPROVE` or `REVISE` with description of changes

### State Update
```yaml
CP-02:
  status: completed
  decision: APPROVE | REVISE
  revision_count: {n}
  notes: "{revision notes if REVISE}"
  decided_at: "{timestamp}"
```

---

## CP-03: Architecture Decision

**When:** After architecture phase completes (Phase 3: Architect)
**Purpose:** User confirms technical architecture

### Presentation Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ CHECKPOINT CP-03 — Architecture Decision
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline: {pipeline.id}
Phase: Architecture (3/7)
Agent: @frontend-arch

**Architecture artifacts produced:**

| Artifact | Path |
|----------|------|
| Component Hierarchy | {path} |
| State Architecture | {path} |
| Platform Strategy | {path} |

**Quality Gate:**
| Gate | Status |
|------|--------|
| QG-AX-004 Architecture Review | ⏳ Awaiting your decision |

**Key Decisions:**

| Decision | Choice |
|----------|--------|
| Rendering Strategy | {RSC / Client / Hybrid} |
| Package Location | {packages/ui/ or other} |
| State Management | {local / context / store} |
| Data Fetching | {server actions / hooks / SWR} |
| Platform Abstraction | {shared core / platform-specific} |

**Component Tree:**
{component hierarchy summary}

**Your decision:**
- **APPROVE** — Architecture is solid, proceed to implementation
- **REVISE** — Describe what needs to change

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Expected Input
- `APPROVE` or `REVISE` with specific architectural feedback

### State Update
```yaml
CP-03:
  status: completed
  decision: APPROVE | REVISE
  notes: "{e.g., App router, packages/ui/}"
  decided_at: "{timestamp}"
```

---

## CP-04: Visual Review

**When:** Before shipping (Phase 7: Ship)
**Purpose:** User reviews the implemented visual result

### Presentation Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ CHECKPOINT CP-04 — Visual Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline: {pipeline.id}
Phase: Ship (7/7) — Pre-ship visual review
Feature: {pipeline.feature}

**Implementation complete. All automated checks passed.**

**QA Results:**

| Check | Status |
|-------|--------|
| Visual Regression (QG-AX-008) | {PASS/FAIL} |
| Cross-Platform (QG-AX-009) | {PASS/FAIL} |
| TypeScript | ✅ Zero errors |
| Lint | ✅ Zero errors |
| Tests | ✅ All passing |

**Components implemented:**
{list of component paths}

**Platforms tested:**
{list of platforms with status}

Please review the implementation visually.

{if storybook available}
📖 Storybook: Run `npm run storybook` to see all components
{/if}
{if dev server available}
🌐 Dev Server: Run `npm run dev` to see the feature in context
{/if}

**Your decision:**
- **APPROVE** — Looks great, proceed to final ship decision
- **REVISE** — Describe visual issues to fix

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Expected Input
- `APPROVE` or `REVISE` with visual feedback

### State Update
```yaml
CP-04:
  status: completed
  decision: APPROVE | REVISE
  notes: "{visual feedback if REVISE}"
  decided_at: "{timestamp}"
```

---

## CP-05: Motion Feel

**When:** After motion engineering, before a11y/perf (Phase 5: Polish)
**Purpose:** User approves animation feel or adjusts spring configs

### Presentation Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ CHECKPOINT CP-05 — Motion Feel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline: {pipeline.id}
Phase: Polish (5/7) — Motion review
Agent: @motion-eng

**Motion has been applied to all components.**

**Quality Gate:**
| Gate | Status |
|------|--------|
| QG-AX-005 Motion Review | ⏳ Awaiting your feel check |

**Animations applied:**

| Component | Animation | Spring Config |
|-----------|-----------|---------------|
{for each animated component}
| {name} | {enter/exit/transform/feedback} | stiffness: {s}, damping: {d}, mass: {m} |
{/for}

**Reduced-motion fallbacks:** ✅ All present

Please test the animations. Focus on HOW THEY FEEL, not just how they look.

{if dev server available}
🌐 Dev Server: `npm run dev` — interact with the components
{/if}

**Your decision:**
- **APPROVE** — Animations feel right
- **ADJUST** — Tell me what to change:
  - "more snappy" → higher stiffness
  - "more bouncy" → lower damping
  - "more subtle" → higher damping, lower mass
  - "slower entrance" → lower stiffness for enter animations
  - Or provide custom spring values: `stiffness: X, damping: Y, mass: Z`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feel > Look. Take your time.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Expected Input
- `APPROVE` or `ADJUST` with spring config direction

### State Update
```yaml
CP-05:
  status: completed
  decision: APPROVE | ADJUST
  adjustments: "{adjustment description}"
  decided_at: "{timestamp}"
```

---

## CP-06: Final Ship Decision

**When:** End of pipeline (Phase 7: Ship)
**Purpose:** User makes the final SHIP or BLOCK decision

### Presentation Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ CHECKPOINT CP-06 — Final Ship Decision
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline: {pipeline.id}
Feature: {pipeline.feature}
Mode: {pipeline.mode}

**Pipeline Summary:**

| Phase | Status | Duration |
|-------|--------|----------|
| 1. Specify | ✅ | {duration} |
| 2. Design | ✅ | {duration} |
| 3. Architect | ✅ | {duration} |
| 4. Implement | ✅ | {duration} |
| 5. Polish | ✅ | {duration} |
| 6. QA | ✅ | {duration} |
| 7. Ship | ⏳ Awaiting your decision | — |

**All Quality Gates:**

| Gate | Status |
|------|--------|
| QG-AX-001 Token Validation | ✅ PASS |
| QG-AX-002 Spec Completeness | ✅ PASS |
| QG-AX-003 Design Approved | ✅ PASS |
| QG-AX-004 Architecture Review | ✅ PASS |
| QG-AX-005 Motion Review | ✅ PASS |
| QG-AX-006 Accessibility | ✅ PASS |
| QG-AX-007 Performance | ✅ PASS |
| QG-AX-008 Visual Regression | ✅ PASS |
| QG-AX-009 Cross-Platform | ✅ PASS |
| QG-AX-010 Final Review | ✅ PASS |

**Checkpoints Completed:**

| Checkpoint | Decision |
|------------|----------|
| CP-01 Feature Brief | ✅ {summary} |
| CP-02 Design Review | ✅ {decision} |
| CP-03 Architecture | ✅ {decision} |
| CP-04 Visual Review | ✅ {decision} |
| CP-05 Motion Feel | ✅ {decision} |
| CP-06 Ship Decision | ⏳ NOW |

**Files Changed:** {count} files across {platform_count} platforms
**Tests:** All passing
**TypeScript:** Zero errors
**Lint:** Zero errors

**Your final decision:**
- **SHIP** — Create PR and merge. This feature is ready.
- **BLOCK** — Do not ship. Describe why.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The final call is always yours.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Expected Input
- `SHIP` or `BLOCK` with reason

### State Update
```yaml
CP-06:
  status: completed
  decision: SHIP | BLOCK
  block_reason: "{reason if BLOCK}"
  decided_at: "{timestamp}"
pipeline:
  status: completed | blocked_at_gate
```

---

## Progress Bar Template

Used in `*apex-status` to show pipeline progress:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ Apex Pipeline — {pipeline.feature}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ID: {pipeline.id}
Mode: {pipeline.mode}
Status: {pipeline.status}
Platforms: {pipeline.target_platforms}

[{1}]──[{2}]──[{3}]──[{4}]──[{5}]──[{6}]──[{7}]
 SPE    DES    ARC    IMP    POL    QA    SHIP

Legend: ✅ = done, ▶ = active, ⏳ = pending, ❌ = blocked

Current: Phase {current_phase} — {current_phase_name}
Agent: @{current_agent}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

*Apex Squad — Pipeline Checkpoint Templates v1.0.0*
