# Task: apex-pivot

```yaml
id: apex-pivot
version: "1.0.0"
title: "Apex Pipeline Pivot"
description: >
  Mid-pipeline direction change. Saves current state, marks the current phase
  as pivoted, and reopens the relevant checkpoint for the user to redefine
  scope. Preserves all work done so far — nothing is discarded.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - data/pipeline-state-schema.yaml
outputs:
  - Pipeline state updated with pivot marker
  - Relevant checkpoint reopened
```

---

## Command

### `*apex-pivot {reason}`

Change direction in a running pipeline without losing progress.

---

## When to Use

- User changes their mind about the feature mid-implementation
- Stakeholder feedback requires scope change
- Technical discovery makes original plan infeasible
- User wants to simplify or expand the current feature

---

## Execution Steps

### Step 1: Save Current State

```yaml
pivot_snapshot:
  pipeline_id: "{current pipeline ID}"
  pivot_at: "{ISO 8601 timestamp}"
  phase_at_pivot: "{current phase}"
  agent_at_pivot: "{current agent}"
  reason: "{user's reason}"
  work_preserved:
    - "{list of files modified so far}"
    - "{artifacts produced so far}"
```

### Step 2: Determine Pivot Point

```
IF current_phase <= 2 (Specify or Design):
  Reopen CP-01 (Feature Brief)
  Rationale: "Scope is still being defined, cheapest to pivot here"

ELIF current_phase == 3 (Architect):
  Reopen CP-02 (Design Review)
  Rationale: "Architecture depends on design — re-confirm design first"

ELIF current_phase == 4 (Implement):
  Reopen CP-03 (Architecture Decision)
  Rationale: "Implementation changes may need architecture adjustment"

ELIF current_phase >= 5 (Polish/QA/Ship):
  Reopen CP-04 (Visual Review)
  Rationale: "Polish phase — review what exists and decide what to change"
```

### Step 3: Present Pivot

```
APEX PIPELINE PIVOT
====================

Pipeline: {pipeline-id}
Phase at pivot: {phase name} (Phase {n})
Reason: {user's reason}

Work preserved:
  - {files and artifacts so far}

Reopening: {checkpoint name}
  {Present the checkpoint as if it were fresh, but with context of what exists}

What would you like to change?
```

### Step 4: Resume

After user responds to the reopened checkpoint:
1. Update pipeline state with new direction
2. Mark previous phase work as `pivoted` (not `failed` or `aborted`)
3. Continue pipeline from the checkpoint's phase forward
4. Agents reuse existing code where applicable — no clean-slate restart

---

## State Updates

```yaml
# Added to pipeline state on pivot
pivot_log:
  - pivot_number: 1
    at_phase: 4_implement
    reason: "user wants simpler design"
    reopened_checkpoint: CP-03
    timestamp: "2026-03-06T15:00:00Z"
    files_preserved: ["src/components/Modal.tsx", "src/index.css"]
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-PIVOT-001
    condition: "Pipeline in Phase 7 (Ship) with PR already created"
    action: "BLOCK — cannot pivot after PR. Close PR first or create new pipeline."
    blocking: true

  - id: VC-PIVOT-002
    condition: "More than 3 pivots in same pipeline"
    action: "WARN — consider aborting (*apex-abort) and starting fresh"
    blocking: false
```

---

*Apex Squad — Pipeline Pivot Task v1.0.0*
