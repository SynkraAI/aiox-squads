# Task: Auto-Heal (Reactive Error Recovery)

**Task ID:** auto-heal
**Execution Type:** Reactive (triggered by error during session)
**Purpose:** Diagnose and fix errors encountered during squad operations
**Orchestrator:** @squad-chief
**Model:** `Sonnet` (error diagnosis and safe-fix decisioning)
**Haiku Eligible:** NO -- escalation and remediation policy require reasoning beyond deterministic matching

**Philosophy:**
```
"Errors are data. Fix when possible. Escalate when not.
 Persist fixes to prevent recurrence. Never fail silently."
```

---

## Overview

Auto-heal is a **reactive** error recovery system. It does NOT run as a background daemon.

**Trigger:** An error occurs during task execution (script failure, broken reference,
config issue) and the agent or user invokes `*auto-heal` with the error context.

**Flow:**
```
ERROR OCCURS → *auto-heal → DIAGNOSE → FIX or ESCALATE → PERSIST → VERIFY
```

**Key Principle:** Fixes are WRITTEN TO THE SQUAD permanently, not just applied at runtime.

---

## Inputs

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `error_message` | string | Yes | The error output or description |
| `error_source` | string | No | Script/task/command that failed |
| `squad_name` | string | No | Defaults to current squad context |

---

## Error Categories

```yaml
error_categories:
  # Category 1: Script Failures
  script_errors:
    auto_fixable: "partial"
    examples:
      - "python3: command not found"
      - "Permission denied: scripts/validate-squad.sh"
      - "ModuleNotFoundError: No module named 'yaml'"
      - "SyntaxError in script"
    fix_strategy: "Check dependencies, fix permissions, install modules"

  # Category 2: Broken References
  reference_errors:
    auto_fixable: "yes"
    examples:
      - "File not found: tasks/missing-task.md"
      - "Entry agent file not found"
      - "Handoff to non-existent agent"
      - "Template referenced but missing"
    fix_strategy: "Scan config.yaml dependencies, identify and report missing files"

  # Category 3: Configuration Errors
  config_errors:
    auto_fixable: "yes"
    examples:
      - "Invalid YAML syntax in config.yaml"
      - "Missing required field: entry_agent"
      - "Version format invalid"
      - "Duplicate key in YAML"
    fix_strategy: "Parse error, locate line, suggest or apply fix"

  # Category 4: Validation Failures
  validation_errors:
    auto_fixable: "partial"
    examples:
      - "validate-squad.sh exited with code 1"
      - "Checklist coverage below threshold"
      - "Orphan tasks detected"
      - "Security scan found issues"
    fix_strategy: "Parse validation output, prioritize blocking issues, fix sequentially"

  # Category 5: Runtime Environment
  environment_errors:
    auto_fixable: "yes"
    examples:
      - "Missing environment variable"
      - "Node.js/Python version incompatible"
      - "MCP server not responding"
    fix_strategy: "Check .env, suggest install, verify connectivity"
```

---

## PHASE 1: DIAGNOSE

**Trigger:** Agent receives error context (message, source, stack trace if available).

### Step 1.1: Pattern Matching

```yaml
error_patterns:
  - id: "ERR-SCRIPT-001"
    pattern:
      message_contains: ["command not found", "not recognized"]
    category: "script_errors"
    severity: "high"
    auto_fixable: true
    fix: "Identify missing command, suggest install"

  - id: "ERR-SCRIPT-002"
    pattern:
      message_contains: ["Permission denied"]
    category: "script_errors"
    severity: "medium"
    auto_fixable: true
    fix: "chmod +x on the script"

  - id: "ERR-SCRIPT-003"
    pattern:
      message_contains: ["ModuleNotFoundError", "No module named"]
    category: "script_errors"
    severity: "medium"
    auto_fixable: true
    fix: "pip3 install missing module"

  - id: "ERR-REF-001"
    pattern:
      message_contains: ["File not found", "No such file", "does not exist"]
    category: "reference_errors"
    severity: "high"
    auto_fixable: false
    fix: "Report missing file, check if renamed or moved"

  - id: "ERR-CFG-001"
    pattern:
      message_contains: ["YAML", "syntax error", "could not find expected"]
    category: "config_errors"
    severity: "high"
    auto_fixable: true
    fix: "Parse YAML error line, fix indentation or syntax"

  - id: "ERR-CFG-002"
    pattern:
      message_contains: ["Missing required field", "missing key"]
    category: "config_errors"
    severity: "high"
    auto_fixable: true
    fix: "Add missing field with sensible default"

  - id: "ERR-VAL-001"
    pattern:
      message_contains: ["validation failed", "exited with code", "ABORT"]
    category: "validation_errors"
    severity: "medium"
    auto_fixable: false
    fix: "Parse validation output, list failures, suggest fixes"

  - id: "ERR-ENV-001"
    pattern:
      message_contains: ["env", "undefined variable", "not set"]
    category: "environment_errors"
    severity: "medium"
    auto_fixable: false
    fix: "Check .env file, suggest variable addition"
```

### Step 1.2: Diagnosis Output

```yaml
diagnosis:
  error_id: "{pattern_id or UNKNOWN}"
  category: "{category}"
  severity: "low|medium|high"
  auto_fixable: true|false
  root_cause: "{description}"
  recommended_fix: "{fix description}"
```

---

## PHASE 2: FIX

**Mode:** Apply fix only if auto_fixable=true AND fix is safe.

### Fix: Script Permission

```yaml
fix_script_permission:
  applies_to: ["ERR-SCRIPT-002"]
  steps:
    - "Identify script path from error message"
    - "Run: chmod +x {script_path}"
    - "Retry original command"
  verify: "Command succeeds"
```

### Fix: Missing Python Module

```yaml
fix_missing_module:
  applies_to: ["ERR-SCRIPT-003"]
  steps:
    - "Parse module name from error"
    - "Run: pip3 install {module_name}"
    - "Retry original command"
  verify: "Import succeeds"
```

### Fix: YAML Syntax

```yaml
fix_yaml_syntax:
  applies_to: ["ERR-CFG-001"]
  steps:
    - "Read the file"
    - "Identify error line from parser output"
    - "Fix indentation, missing quotes, or invalid characters"
    - "Write corrected file"
    - "Validate YAML parses cleanly"
  verify: "python3 -c \"import yaml; yaml.safe_load(open('{file}'))\""
```

### Fix: Missing Config Field

```yaml
fix_missing_field:
  applies_to: ["ERR-CFG-002"]
  steps:
    - "Identify which field is missing"
    - "Check template (templates/config-tmpl.yaml) for default value"
    - "Add field with template default"
    - "Verify config passes structure check"
  verify: "validate-squad.sh passes Phase 1"
```

---

## PHASE 3: ESCALATE (when auto-fix not possible)

```yaml
escalation:
  format: |
    ## Auto-Heal: Escalation Required

    **Error:** {error_message}
    **Source:** {error_source}
    **Category:** {category}
    **Pattern:** {pattern_id or UNKNOWN}

    **Root Cause:** {root_cause}

    **Suggested Fix:**
    {step_by_step_fix_instructions}

    **Command to try:**
    `{suggested_command}`

  escalation_levels:
    - level: "user_action"
      when: "Fix requires user decision (e.g., which file to keep)"
      action: "Present options, let user choose"

    - level: "manual_fix"
      when: "Fix is known but involves files outside squad scope"
      action: "Show exact commands user should run"

    - level: "investigation"
      when: "Error pattern unknown"
      action: "Collect context, suggest where to look"
```

---

## PHASE 4: PERSIST

**Purpose:** Record fix so it does not recur and can be audited.

```yaml
persist:
  log_file: "squads/{squad_name}/data/auto-heal-log.yaml"

  entry:
    id: "HEAL-{date}-{seq}"
    timestamp: "{ISO8601}"
    error_pattern: "{pattern_id}"
    error_message: "{message}"
    fix_applied: "{description}"
    files_changed:
      - file: "{path}"
        change: "{what changed}"
    result: "success|failed|escalated"
    verified: true|false
```

---

## Safety Mechanisms

```yaml
safety:
  never_auto_fix:
    - "Agent definition content (persona, heuristics, voice_dna)"
    - "Workflow logic or phase ordering"
    - "Veto conditions or quality gates"
    - "Files outside the squad directory"

  always_backup_before_fix:
    - "config.yaml -> config.yaml.bak"
    - "Any file being modified"

  post_fix_checklist:
    - id: "HEAL-VER-001"
      check: "Retry original operation"
      description: "Re-run the exact operation that originally failed"
      on_fail: "rollback"
    - id: "HEAL-VER-002"
      check: "Backup exists"
      description: "Verify .bak file was created before fix was applied"
      on_fail: "abort — never fix without backup"
    - id: "HEAL-VER-003"
      check: "Syntax validation"
      description: "Parse modified file (YAML safe_load, markdown lint)"
      on_fail: "rollback"
    - id: "HEAL-VER-004"
      check: "Regression detection"
      description: "Run validate-squad.sh and compare error count — must not increase"
      on_fail: "rollback"

  rollback_policy:
    trigger: "Any HEAL-VER-* check fails"
    steps:
      - "Restore file from .bak backup"
      - "Re-run validation to confirm rollback restored clean state"
      - "Log failed fix attempt with HEAL-VER-{NNN} ID"
      - "If rollback itself fails: HALT and escalate to human"
    note: "Rollback is atomic per-file. Partial fixes are never left in place."

  limits:
    max_auto_fixes_per_session: 5
    max_retries_per_error: 3
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: "VETO-HEAL-001"
    condition: "Fix would modify agent persona or heuristics"
    blocks: "Auto-fix"
    message: "Cannot auto-fix agent definitions. Human review required."

  - id: "VETO-HEAL-002"
    condition: "Fix would write outside squad directory"
    blocks: "Auto-fix"
    message: "Cannot modify files outside squads/{squad_name}/."

  - id: "VETO-HEAL-003"
    condition: "Same error failed auto-fix 3 times"
    blocks: "Auto-fix (escalate instead)"
    message: "Recurring failure. Escalating to human."

  - id: "VETO-HEAL-004"
    condition: "Error pattern unknown"
    blocks: "Auto-fix"
    message: "Unknown error type. Escalating for analysis."
```

---

## Commands

```yaml
commands:
  diagnose:
    command: "*auto-heal --diagnose {error_context}"
    description: "Diagnose an error and suggest fix"

  fix:
    command: "*auto-heal --fix {error_context}"
    description: "Diagnose AND apply fix if safe"

  history:
    command: "*auto-heal --history"
    description: "Show auto-heal log for current squad"
```

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Auto-Heal Log | `data/auto-heal-log.yaml` | All fixes applied |
| Backups | `*.bak` next to modified files | Pre-fix backups |

---

## Related Tasks

| Task | Purpose |
|------|---------|
| `setup-runtime.md` | Initial environment setup |
| `operational-test.md` | Validates squad after fixes |

---

_Task Version: 2.0.0_
_Last Updated: 2026-03-06_
_Philosophy: "Fix automatically, persist permanently, escalate immediately."_
