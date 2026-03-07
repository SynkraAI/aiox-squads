# Task: Refresh Squad Registry

**Task ID:** refresh-registry
**Purpose:** Scan all squads in the ecosystem and update ecosystem-registry.yaml
**Orchestrator:** @squad-chief
**Mode:** 100% Deterministic (Script only)
**Execution Type:** `Worker` (Script handles everything — scan, merge, write)
**Worker Script:** `scripts/refresh-registry.py --write`
**Model:** None (no LLM needed)
**Haiku Eligible:** N/A (Worker task)
**Mapped in:** `command_scripts` section of squad-chief.md
**Registry Path Resolution:** `--registry-path` > `AIOX_ECOSYSTEM_REGISTRY_PATH` > `.aiox/squad-runtime/ecosystem-registry.yaml`

---

## ⛔ EXECUTION: Script Only — Zero LLM

```
EXECUTE THIS COMMAND AND DISPLAY OUTPUT:

  python3 squads/squad-creator/scripts/refresh-registry.py --write

DO NOT:
- Count agents/tasks manually
- Read squad manifests yourself (`config.yaml` / `squad.yaml`)
- Infer domains or keywords
- Generate highlights or example_use
- Do ANY enrichment manually

The script handles: scan → merge with existing → preserve enrichments → write YAML → print summary.
Semantic enrichments (domain, keywords, highlights, example_use) are preserved from existing registry.
New squads get auto-inferred values that can be manually improved later.
```

---

**Architecture:**
```
100% DETERMINISTIC (Python Script)
├── Count agents, tasks, etc.
├── Read canonical squad metadata from config.yaml (fallback: squad.yaml)
├── List directory contents
├── Merge with existing registry (preserve manual enrichments)
├── Auto-infer domain/keywords for NEW squads only
├── Write ecosystem-registry.yaml
└── Print summary with changes detected
```

**Script:** `scripts/refresh-registry.py --write`

---

## Overview

This task is 100% deterministic — a single Python script handles everything:

```
TRIGGER (*refresh-registry command or post-create hook)
    ↓
[SINGLE STEP: RUN SCRIPT]
    → python3 scripts/refresh-registry.py --write
    → Scans squads/ directory (counts, config metadata, agent names)
    → Loads existing registry (preserves manual enrichments)
    → Merges: fresh counts + preserved semantics
    → Writes updated ecosystem-registry.yaml
    → Prints summary with changes detected
    ↓
OUTPUT: Updated ecosystem-registry.yaml + console summary
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: "VETO-REG-001"
    condition: "Target registry write requested without backup artifact"
    trigger: "Before --write operation"
    block_behavior: "BLOCK write unless backup exists or operator explicitly accepts risk"

  - id: "VETO-REG-002"
    condition: "squads/ root not detected or manifest scan fails"
    trigger: "Before scan starts"
    block_behavior: "BLOCK refresh; require valid squads path"
```

---

## Triggers (Hooks)

### 1. Manual Command
```bash
*refresh-registry
```

### 2. On Squad-Creator Activation (Optional)
```yaml
# In squad-chief.md activation-instructions
auto_refresh:
  enabled: false  # Set to true for auto-refresh
  condition: "registry older than 24 hours"
```

### 3. After Creating New Squad
```yaml
# Automatic trigger after *create-squad completes
post_create_hook:
  action: "refresh-registry"
  when: "squad creation successful"
```

### 4. Pre-Commit Hook (Recommended)
```bash
# .claude/hooks/refresh-registry.sh
# Trigger: Changes to squads/*/config.yaml or squads/*/squad.yaml

#!/bin/bash
if git diff --cached --name-only | grep -qE "squads/.*/(config|squad)\.yaml"; then
  echo "Squad config changed, refreshing registry..."
  # Claude Code will handle this via hook
fi
```

---

## Inputs

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `squads_path` | string | No | `squads/` | Base path to scan |
| `preserve_manual` | boolean | No | `true` | Keep manual highlights, quality_reference |
| `update_gaps` | boolean | No | `false` | Re-analyze gaps (slower) |

---

## Execution

```bash
# Single command — does everything
python3 squads/squad-creator/scripts/refresh-registry.py --write
```

**What the script does:**
1. Scans `squads/` directory
2. Reads each canonical `config.yaml` (fallback: `squad.yaml`)
3. Counts files in each subdirectory (agents, tasks, workflows, templates, checklists, data)
4. Lists agent names
5. Checks for README.md, CHANGELOG.md
6. Loads existing `ecosystem-registry.yaml`
7. Merges: fresh deterministic data + preserved semantic enrichments
8. Auto-infers domain/keywords/highlights for NEW squads only
9. Writes updated `ecosystem-registry.yaml`
10. Prints summary with changes detected

**Merge strategy:**
- **ALWAYS fresh:** counts, agent_names, paths, version, has_readme, has_changelog
- **ALWAYS preserved from existing:** description, domain, keywords, highlights, example_use, quality_score
- **Preserved sections:** gaps, ecosystem_health, quality_references, conventions
- **New squads:** get auto-inferred values (can be manually improved later)

**Other modes (for debugging):**
```bash
# JSON output (no write)
python3 scripts/refresh-registry.py --output json --registry-format

# Summary only
python3 scripts/refresh-registry.py --output summary
```

---

## Output

```yaml
output:
  file: "{registry_path}"
  console: |
    Registry updated successfully!

    Squads: {total} ({new} new, {updated} updated)
    Domains covered: {domain_count}
    Gaps remaining: {gap_count}

    New squads detected:
    - {new_squad_1}
    - {new_squad_2}

    Updated squads:
    - {updated_squad_1}: +2 agents, +1 task
```

---

## Hook Configuration

### Add to .claude/hooks/

Create `.claude/hooks/post-squad-create.py`:

```python
#!/usr/bin/env python3
"""
Hook: Refresh registry after squad creation
Trigger: After successful *create-squad execution
"""

import os
import sys

def should_run(event):
    """Check if this hook should run"""
    # Run after create-squad task completes
    return (
        event.get('task') == 'create-squad' and
        event.get('status') == 'success'
    )

def main():
    # Signal to Claude Code to run refresh-registry
    print("HOOK: Squad created, triggering registry refresh")
    print("ACTION: run-task refresh-registry")
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

### Add to squad-chief.md

```yaml
post_command_hooks:
  "*create-squad":
    on_success:
      - task: "refresh-registry"
        silent: true  # Don't show output unless error
```

---

## Usage Examples

### Manual Refresh
```bash
@squad-chief
*refresh-registry
```

### Refresh with Gap Analysis
```bash
*refresh-registry --update-gaps
```

### Check Registry Status
```bash
*show-registry
# Shows current registry contents

*registry-status
# Shows: last updated, total squads, any issues
```

---

## Validation

After refresh, verify:

```yaml
validation:
  - All squads in squads/ are in registry
  - All registry entries have valid paths
  - domain_index has no orphan entries
  - YAML is valid and parseable
  - No duplicate keywords pointing to wrong squads
```

---

_Task Version: 1.0.0_
_Created: 2026-02-01_
_Trigger: Manual, post-create-squad, or pre-commit hook_
