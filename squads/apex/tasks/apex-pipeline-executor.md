# Task: apex-pipeline-executor

```yaml
id: apex-pipeline-executor
version: "1.0.0"
title: "Apex Pipeline Executor"
description: >
  Orchestrates the full Apex Pipeline — automated agent handoffs through
  7 phases with 6 user checkpoints. Supports autonomous mode (*apex-go)
  and guided mode (*apex-step). The executor automates the PROCESS;
  the user decides the WHAT.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - workflows/wf-apex-pipeline.yaml
  - data/pipeline-state-schema.yaml
  - data/veto-conditions.yaml
  - data/performance-budgets.yaml
  - templates/pipeline-checkpoint-tmpl.md
  - tasks/apex-route-request.md
outputs:
  - Pipeline state file at .aios/apex-pipeline/{pipeline-id}.yaml
  - Implemented components across target platforms
  - QA verdict (PASS | FAIL)
  - PR URL (if shipped)
```

---

## Commands

This task handles 8 pipeline commands. All are triggered by the user through apex-lead.

### Primary Commands

#### `*apex-go {description}`

**Autonomous mode.** Runs the full 7-phase pipeline automatically. Pauses ONLY at the 6 user checkpoints (CP-01 through CP-06) and when a quality gate fails.

**Execution:**

1. Initialize pipeline state from `data/pipeline-state-schema.yaml` defaults
2. Set `mode: autonomous`
3. Set `feature: "{description}"`
4. Generate `pipeline.id: "apex-pipe-{timestamp}"`
5. Create state file at `.aios/apex-pipeline/{pipeline-id}.yaml`
6. Execute Phase 1 (Specify):
   - Run routing analysis using `apex-route-request.md` logic
   - Present **CP-01** (Feature Brief) — PAUSE for user input
   - If scope is `single-agent`, suggest `*apex-fix` as alternative
7. On CP-01 completion, execute remaining phases automatically:
   - Phase 2 (Design) → pause at **CP-02**
   - Phase 3 (Architect) → pause at **CP-03**
   - Phase 4 (Implement) → NO pause (fully automated)
   - Phase 5 (Polish) → pause at **CP-05** (between motion and a11y/perf)
   - Phase 6 (QA) → NO pause (fully automated)
   - Phase 7 (Ship) → pause at **CP-04** then **CP-06**
8. Between checkpoints, orchestrate agents per `wf-apex-pipeline.yaml`
9. Save state on every transition (phase, checkpoint, gate, handoff, error)

**Example:**
```
User: *apex-go "notification system with toast and badge"
Emil: [presents CP-01, gathers brief, then runs pipeline autonomously]
```

---

#### `*apex-step {description}`

**Guided mode.** Runs one phase at a time. After each phase completes, shows the result and waits for user approval before advancing.

**Execution:**

1. Same initialization as `*apex-go` but set `mode: guided`
2. Execute Phase 1 → show result → PAUSE
3. On user approval, execute Phase 2 → show result → PAUSE
4. Continue phase by phase
5. All 6 checkpoints are still presented within their phases
6. Between phases, show phase completion summary:

```
Phase {n} ({name}) complete.
  Agents: {agents used}
  Gates: {gate results}
  Artifacts: {artifacts produced}

Ready for Phase {n+1} ({next_name})?
Type 'continue' to proceed or describe any adjustments.
```

---

### Control Commands

#### `*apex-resume`

Resume a paused or crashed pipeline from its last saved state.

**Execution:**

1. Look for pipeline state files in `.aios/apex-pipeline/`
2. If multiple exist, list them and ask user to select
3. If one exists, load it automatically
4. Read `pipeline.status` and `pipeline.current_phase`:
   - `paused_at_checkpoint` → re-present the checkpoint
   - `blocked_at_gate` → show gate failure details and options
   - `running` (crash recovery) → resume from `current_phase`
5. Continue execution in the original mode (autonomous/guided)

**Example:**
```
User: *apex-resume
Emil: Found pipeline apex-pipe-1709312400
      Feature: "notification system"
      Status: paused_at_checkpoint (CP-03)
      Resuming from Architecture Decision checkpoint...
```

---

#### `*apex-status`

Show visual progress of the current or most recent pipeline.

**Execution:**

1. Load current pipeline state from `.aios/apex-pipeline/`
2. Display progress using template from `pipeline-checkpoint-tmpl.md` (Progress Bar section)
3. Show:
   - Pipeline ID, feature, mode, status
   - Phase progress bar with status indicators
   - Current phase and agent
   - Checkpoint decisions made so far
   - Gate results
   - Any active blockers

---

#### `*apex-abort`

Cancel the current pipeline. Artifacts are preserved.

**Execution:**

1. Load current pipeline state
2. Set `pipeline.status: aborted`
3. Save final state
4. Display:
```
Pipeline {pipeline.id} aborted.
Feature: "{pipeline.feature}"
Phase reached: {current_phase} ({phase_name})
Artifacts preserved at: .aios/apex-pipeline/{pipeline-id}.yaml

Artifacts produced before abort are still available.
To start a new pipeline: *apex-go "{feature}"
```

---

#### `*apex-retry {phase}`

Re-execute a specific phase after fixing an issue.

**Execution:**

1. Load current pipeline state
2. Validate `{phase}` is a valid phase number (1-7) or name
3. Reset that phase's status to `pending`
4. Reset associated gates to `PENDING`
5. Re-execute the phase
6. Continue pipeline from that point

**Constraints:**
- Can only retry the current or a previous phase
- Cannot skip ahead
- Gate fix attempts counter is NOT reset (tracks total attempts)

---

### Direct Routes

#### `*apex-fix {description}`

Route a request directly to the best specialist agent without running the full pipeline. Uses the routing logic from `apex-route-request.md`.

**Execution:**

1. Run routing analysis from `apex-route-request.md`
2. Classify scope (should be single-agent or multi-agent)
3. Route directly to target agent with full context
4. No pipeline state created — this is a lightweight operation

**Example:**
```
User: *apex-fix "the modal animation feels mechanical"
Emil: Routing to @motion-eng — animation quality is their domain.
      [activates @motion-eng with full context]
```

---

#### `*apex-audit {domain}`

Run an audit-only pass for a specific quality domain without the full pipeline.

**Execution:**

1. Validate `{domain}` is one of: `a11y`, `perf`, `motion`, `visual`
2. Route to the appropriate specialist:
   - `a11y` → @a11y-eng (runs WCAG 2.2 AA audit)
   - `perf` → @perf-eng (runs Lighthouse + bundle analysis)
   - `motion` → @motion-eng (audits spring physics + reduced-motion)
   - `visual` → @qa-visual (runs visual regression tests)
3. Agent produces audit report
4. No pipeline state created — standalone operation

**Example:**
```
User: *apex-audit a11y
Emil: Running accessibility audit via @a11y-eng...
      [activates @a11y-eng with audit-only scope]
```

---

## Agent Orchestration Protocol

### Handoff Between Phases

When transitioning between phases, the executor:

1. Generates a handoff artifact following `.claude/rules/agent-handoff.md` protocol
2. Stores artifact at `.aios/handoffs/handoff-{from}-to-{to}-{timestamp}.yaml`
3. Artifact contains: story context, decisions, files modified, next action
4. Incoming agent receives the handoff artifact (not the full previous agent persona)
5. Logs handoff in pipeline state `handoff_log`

### Parallel Agent Execution

For phases with parallel execution (4: Implement, parts of 5: Polish, 6: QA):

1. Determine which agents run based on `target_platforms`
2. Launch all parallel agents simultaneously
3. Collect results as each agent completes
4. All agents must complete before phase transitions
5. If any agent fails, retry once, then escalate

### Gate Evaluation

When evaluating a quality gate:

1. Load veto conditions from `data/veto-conditions.yaml` for the gate
2. Execute each veto condition check
3. If ALL pass → gate PASS
4. If ANY fail → gate FAIL:
   - Create FIX sub-task for the responsible agent
   - Agent fixes the issue
   - Re-evaluate gate (max 3 fix attempts per gate)
   - If max reached → escalate: agent → apex-lead → aios-master
5. Log all results in pipeline state `gate_results`
6. Log any veto triggers in `veto_log`

---

## State Persistence

The executor saves pipeline state on every significant event:

| Event | Save Trigger |
|-------|-------------|
| Phase starts | `phases.{n}.status: in_progress, started_at: {now}` |
| Phase completes | `phases.{n}.status: completed, completed_at: {now}` |
| Checkpoint presented | `checkpoints.{CP}.status: presented` |
| Checkpoint decided | `checkpoints.{CP}.status: completed, decision: {d}` |
| Gate evaluated | `gate_results.{gate}: {result}` |
| Agent handoff | `handoff_log: [{entry}]` |
| Error occurs | `pipeline.status: {error_status}` |
| Pipeline aborted | `pipeline.status: aborted` |

State file location: `.aios/apex-pipeline/{pipeline-id}.yaml`
Schema: `data/pipeline-state-schema.yaml`

---

## Error Handling

### Gate Failure Flow (Unidirectional)

```
Gate FAIL → Create FIX sub-task for responsible agent
         → Agent attempts fix (max 3 attempts)
         → Re-evaluate gate
         → If still failing after 3 → escalate to apex-lead
         → apex-lead cannot resolve → escalate to aios-master
```

**Critical:** Flow is UNIDIRECTIONAL. A gate failure creates a FIX task for the current phase agent. It NEVER rolls back to a previous phase.

### Agent Failure

```
Agent fails → Retry 1x
           → If still failing → escalate to apex-lead
           → apex-lead assigns alternative approach or escalates to aios-master
```

### Checkpoint Timeout

```
Checkpoint presented → 48 hours with no user response
                    → Pipeline status: paused_at_checkpoint
                    → State preserved for *apex-resume
```

### Pipeline Crash

```
Unexpected error → State auto-saved (last known good state)
                → User runs *apex-resume to restore
```

---

## Quality Gate

```yaml
gate:
  id: QG-apex-pipeline-executor
  blocker: true
  criteria:
    - "Pipeline state file created and maintained throughout execution"
    - "All 6 checkpoints presented to user at correct points"
    - "All 10 quality gates evaluated (QG-AX-001 through QG-AX-010)"
    - "Agent handoffs follow .claude/rules/agent-handoff.md protocol"
    - "State persisted on every transition for crash recovery"
    - "Error handling follows unidirectional flow (never rollback)"
  on_fail: "BLOCK — investigate state file integrity and gate evaluation logs"
  on_pass: "Pipeline complete — feature shipped or blocked by user decision"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | Multiple agents throughout pipeline execution |
| Artifact | Pipeline state file with full execution history |
| Next action | Depends on pipeline phase and mode |

---

*Apex Squad — Pipeline Executor Task v1.0.0*
