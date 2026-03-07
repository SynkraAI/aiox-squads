# Task: Upgrade Squad

**Task ID:** upgrade-squad
**Execution Type:** Hybrid (Script for inventory/scanning + Agent for gap analysis/planning)
**Purpose:** Upgrade existing squads to current AIOX structural standards with gap analysis and automated improvements
**Orchestrator:** @squad-chief
**Mode:** Audit > Plan > Execute (with dry-run option)
**Model:** `Sonnet` (requires structural gap analysis and upgrade planning)
**Haiku Eligible:** NO -- gap analysis requires interpretation of component structure

## Veto Conditions

```yaml
veto_conditions:
  - id: "VETO-UPGRADE-001"
    condition: "No dry-run executed with generated diff against target squad"
    trigger: "Before Phase 3 (Execute Upgrades)"
    block_behavior: "BLOCK upgrade execution; run dry-run and produce diff first"

  - id: "VETO-UPGRADE-002"
    condition: "Dry-run produced critical blockers not acknowledged"
    trigger: "Before applying any structural mutation"
    block_behavior: "BLOCK apply step until blockers are resolved or explicitly accepted"
```

**Core Philosophy:**
```
Squads evolve. Standards improve. Old squads need upgrades.
This task brings legacy squads up to current STRUCTURAL standards
without breaking what already works.
For qualitative upgrades (voice DNA quality, thinking DNA gaps), use squad-creator-pro *upgrade-squad.
```

**Frameworks Used:**
- `checklists/agent-quality-gate.md` -- Agent validation (800+ lines, 6 levels)
- `checklists/task-anatomy-checklist.md` -- Task validation (8 fields)
- `checklists/squad-checklist.md` -- Squad-level validation
- `data/quality-dimensions-framework.md` -- Scoring
- `data/tier-system-framework.md` -- Agent tier validation

---

## PRO DETECTION

> At execution time, check if `squads/squad-creator-pro/workflows/wf-brownfield-upgrade-squad.yaml` exists.
> If YES and pro mode is active -- delegate to pro workflow override.
> If NO -- continue with this base version.
>
> Pro mode check: `squads/squad-creator-pro/config.yaml` exists -- pro_mode=true

---

## Upgrade Flow

```
INPUT (squad_name, mode)
    |
[PHASE 0: INVENTORY]
    -> Scan all components (agents, tasks, workflows, etc.)
    -> Count lines, extract metadata
    -> Build component registry
    |
[PHASE 1: STRUCTURAL GAP ANALYSIS]
    -> Check config.yaml format compliance
    -> Check agent template structure compliance
    -> Check task anatomy (8 mandatory fields)
    -> Check workflow schema compliance
    -> Check for missing required files
    -> Score: PASS / NEEDS_UPGRADE / CRITICAL
    -> Generate gap report
    |
[PHASE 2: UPGRADE PLAN]
    -> Prioritize: Critical -> High -> Medium -> Low
    -> Estimate effort per component
    -> Present plan to user (if not --auto)
    |
[PHASE 3: EXECUTE UPGRADES]
    -> Apply structural fixes (add missing fields, fix format)
    -> Validate each upgrade
    -> Track changes
    |
[PHASE 4: VERIFICATION]
    -> Run *validate-squad after upgrades
    -> Compare before/after scores
    -> Generate upgrade report
    |
OUTPUT: Upgrade Report + Updated Components
```

---

## Inputs

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `squad_name` | string | Yes | Name of squad to upgrade | `"copy"`, `"legal"` |
| `mode` | enum | No | Execution mode | `audit`, `plan`, `execute`, `auto` |
| `focus` | enum | No | Focus area | `agents`, `tasks`, `workflows`, `all` |
| `dry_run` | bool | No | Preview changes without applying | `true`, `false` |

### Mode Descriptions

| Mode | Description | User Interaction |
|------|-------------|------------------|
| `audit` | Only generate gap report, no changes | None (read-only) |
| `plan` | Generate report + upgrade plan | Review plan |
| `execute` | Execute plan with confirmations | Confirm each change |
| `auto` | Execute all upgrades automatically | Minimal |

---

## PHASE 0: INVENTORY

**Duration:** 1-2 minutes
**Mode:** Autonomous

### Step 0.1: Scan Squad Structure

```yaml
inventory_scan:
  actions:
    - "List all files in squads/{squad_name}/"
    - "Categorize by type: agents/, tasks/, workflows/, templates/, checklists/, data/"
    - "Count lines per file"
    - "Extract version from config.yaml"

  output_format:
    squad_name: "{name}"
    squad_version: "{version}"
    last_modified: "{date}"
    components:
      agents:
        count: N
        files:
          - name: "agent-name.md"
            lines: N
            has_activation_notice: true/false
            has_yaml_block: true/false
      tasks:
        count: N
        files:
          - name: "task-name.md"
            lines: N
            has_8_fields: true/false
      workflows:
        count: N
        files: [...]
      templates:
        count: N
        files: [...]
      checklists:
        count: N
        files: [...]
      data:
        count: N
        files: [...]
```

### Step 0.2: Extract Component Metadata

For each component, extract key structural metadata:

```yaml
agent_metadata:
  required_sections:
    - "ACTIVATION-NOTICE"
    - "IDE-FILE-RESOLUTION"
    - "activation-instructions:"
    - "agent:"
    - "persona:"
    - "core_principles:"
    - "commands:"
    - "dependencies:"

task_metadata:
  required_fields:
    - "task_name"
    - "status"
    - "responsible_executor"
    - "execution_type"
    - "input"
    - "output"
    - "action_items"
    - "acceptance_criteria"

workflow_metadata:
  required_sections:
    - "phases:"
    - "checkpoints:"
    - "outputs:"
```

**Phase 0 Output:**
```yaml
inventory:
  squad: "copy"
  version: "2.1.0"
  totals:
    agents: 25
    tasks: 45
    workflows: 3
    templates: 12
    checklists: 8
    data: 5
  component_details: [...]
```

---

## PHASE 1: STRUCTURAL GAP ANALYSIS

**Duration:** 3-5 minutes
**Mode:** Autonomous

This phase performs STRUCTURAL-ONLY gap analysis. It checks format compliance, template adherence,
field presence, and schema conformance. It does NOT evaluate qualitative aspects like voice DNA
quality, thinking DNA depth, or mind-cloning fidelity.

> For qualitative upgrades (voice DNA quality, thinking DNA gaps), use squad-creator-pro *upgrade-squad.

### Step 1.1: Config.yaml Format Compliance

```yaml
config_compliance:
  checks:
    - id: "S-CFG-001"
      check: "config.yaml exists"
      weight: blocking

    - id: "S-CFG-002"
      check: "config.yaml is valid YAML syntax"
      weight: blocking

    - id: "S-CFG-003"
      check: "Required fields present: name, version, description, entry_agent"
      weight: blocking

    - id: "S-CFG-004"
      check: "name uses kebab-case"
      pattern: "^[a-z0-9]+(-[a-z0-9]+)*$"
      weight: blocking

    - id: "S-CFG-005"
      check: "version follows semver (X.Y.Z)"
      pattern: "^\\d+\\.\\d+\\.\\d+$"
      weight: blocking

    - id: "S-CFG-006"
      check: "entry_agent references existing agent file"
      weight: blocking

    - id: "S-CFG-007"
      check: "slashPrefix defined (for IDE command installation)"
      weight: recommended

    - id: "S-CFG-008"
      check: "agents list matches files in agents/ directory"
      weight: recommended

  scoring:
    pass: "All blocking checks pass"
    needs_upgrade: "1-2 blocking checks fail"
    critical: ">2 blocking checks fail"
```

### Step 1.2: Agent Template Compliance (agent-tmpl.md structure)

For each agent file, check structural compliance against the agent template:

```yaml
agent_template_compliance:
  checks:
    # Level 0: Loader Configuration
    - id: "S-AGT-001"
      check: "Has ACTIVATION-NOTICE at top of file"
      current_standard: true
      weight: blocking

    - id: "S-AGT-002"
      check: "Has IDE-FILE-RESOLUTION section"
      current_standard: true
      weight: blocking

    - id: "S-AGT-003"
      check: "Has activation-instructions section"
      current_standard: true
      weight: blocking

    # Level 1: Identity Structure
    - id: "S-AGT-004"
      check: "agent.name defined"
      weight: blocking

    - id: "S-AGT-005"
      check: "agent.id defined (kebab-case)"
      weight: blocking

    - id: "S-AGT-006"
      check: "agent.title defined"
      weight: blocking

    - id: "S-AGT-007"
      check: "agent.whenToUse defined (20+ chars)"
      weight: blocking

    # Level 2: Operational Structure
    - id: "S-AGT-008"
      check: "persona section exists with role and style"
      weight: blocking

    - id: "S-AGT-009"
      check: "core_principles section exists with 3+ items"
      weight: blocking

    - id: "S-AGT-010"
      check: "commands section exists with *help and *exit"
      weight: blocking

    - id: "S-AGT-011"
      check: "dependencies section exists"
      weight: recommended

    # Level 3: Voice/Content Structure (presence only, not quality)
    - id: "S-AGT-012"
      check: "voice_dna section EXISTS (not empty)"
      weight: recommended
      note: "Quality of voice_dna content is evaluated by squad-creator-pro"

    - id: "S-AGT-013"
      check: "output_examples section EXISTS (not empty)"
      weight: recommended
      note: "Quality of examples is evaluated by squad-creator-pro"

    - id: "S-AGT-014"
      check: "anti_patterns section EXISTS"
      weight: recommended

    # Level 4: Integration Structure
    - id: "S-AGT-015"
      check: "handoff_to section exists if agent has downstream agents"
      weight: recommended

  scoring:
    pass: "All blocking checks pass"
    needs_upgrade: "1-3 blocking checks fail"
    critical: ">3 blocking checks fail"
```

### Step 1.3: Task Anatomy Fields (8 mandatory fields)

For each task, check against `task-anatomy-checklist.md`:

```yaml
task_anatomy_compliance:
  checks:
    - id: "S-TSK-001"
      check: "Has all 8 required fields"
      fields: ["task_name", "status", "responsible_executor", "execution_type", "input", "output", "action_items", "acceptance_criteria"]
      weight: blocking

    - id: "S-TSK-002"
      check: "task_name follows Verb + Object format"
      pattern: "^[A-Z][a-z]+ [A-Z]"
      weight: blocking

    - id: "S-TSK-003"
      check: "execution_type is valid enum"
      valid: ["Human", "Agent", "Hybrid", "Worker"]
      weight: blocking

    - id: "S-TSK-004"
      check: "input is array with 1+ items"
      weight: blocking

    - id: "S-TSK-005"
      check: "output is array with 1+ items"
      weight: blocking

    - id: "S-TSK-006"
      check: "action_items has 3+ concrete steps"
      weight: recommended

    - id: "S-TSK-007"
      check: "acceptance_criteria has 2+ testable criteria"
      weight: recommended

    - id: "S-TSK-008"
      check: "Complex tasks (500+ lines) have checklist reference"
      weight: recommended

  scoring:
    pass: "All blocking checks pass"
    needs_upgrade: "1-2 blocking checks fail"
    critical: ">2 blocking checks fail"
```

### Step 1.4: Workflow Schema Compliance

Check workflows against workflow-yaml-schema.yaml:

```yaml
workflow_schema_compliance:
  checks:
    - id: "S-WFL-001"
      check: "Workflow file is valid YAML"
      weight: blocking

    - id: "S-WFL-002"
      check: "Has 3+ phases"
      weight: blocking

    - id: "S-WFL-003"
      check: "Each phase has checkpoint"
      weight: blocking

    - id: "S-WFL-004"
      check: "Outputs flow between phases (output of N matches input of N+1)"
      weight: blocking

    - id: "S-WFL-005"
      check: "Quality gate before final output"
      weight: blocking

    - id: "S-WFL-006"
      check: "Has automation script (if 8+ phases)"
      weight: recommended

    - id: "S-WFL-007"
      check: "Phases are numbered sequentially"
      weight: recommended

  scoring:
    pass: "All blocking checks pass"
    needs_upgrade: "1-2 blocking checks fail"
    critical: ">2 blocking checks fail"
```

### Step 1.5: Missing Required Files Check

```yaml
required_files_check:
  checks:
    - id: "S-FIL-001"
      check: "config.yaml exists"
      weight: blocking

    - id: "S-FIL-002"
      check: "README.md exists"
      weight: blocking

    - id: "S-FIL-003"
      check: "CHANGELOG.md exists"
      weight: recommended

    - id: "S-FIL-004"
      check: "At least one agent in agents/"
      weight: blocking

    - id: "S-FIL-005"
      check: "Entry agent file exists"
      weight: blocking

    - id: "S-FIL-006"
      check: "All files referenced in config.yaml exist on disk"
      weight: blocking

    - id: "S-FIL-007"
      check: "All files referenced in agent dependencies exist"
      threshold: "80%"
      weight: recommended
```

### Step 1.6: Generate Gap Report

```yaml
gap_report_format:
  summary:
    squad: "{name}"
    overall_score: "X.X/10"
    status: "PASS | NEEDS_UPGRADE | CRITICAL"
    analysis_type: "STRUCTURAL ONLY"
    components_analyzed: N
    components_passing: N
    components_needing_upgrade: N
    components_critical: N

  by_category:
    config:
      status: "PASS | NEEDS_UPGRADE | CRITICAL"
      gaps:
        blocking: [...]
        recommended: [...]

    agents:
      total: N
      passing: N
      needing_upgrade: N
      critical: N
      details:
        - name: "agent-name.md"
          score: "X/10"
          status: "PASS | NEEDS_UPGRADE | CRITICAL"
          gaps:
            blocking:
              - "Missing ACTIVATION-NOTICE"
              - "No activation-instructions section"
            recommended:
              - "Could add voice_dna section"

    tasks:
      total: N
      passing: N
      needing_upgrade: N
      critical: N
      details: [...]

    workflows:
      total: N
      passing: N
      needing_upgrade: N
      critical: N
      details: [...]

    missing_files:
      blocking: [...]
      recommended: [...]

  priority_list:
    critical:
      - component: "agents/old-agent.md"
        gaps: 5
        effort: "2-3h"
    high:
      - component: "tasks/incomplete-task.md"
        gaps: 3
        effort: "1h"
    medium:
      - component: "agents/needs-polish.md"
        gaps: 2
        effort: "30m"
    low:
      - component: "templates/minor-update.md"
        gaps: 1
        effort: "15m"
```

**Phase 1 Output:**
```
GAP ANALYSIS REPORT: {squad_name}
Analysis Type: STRUCTURAL ONLY

Overall Score: 6.8/10 - NEEDS_UPGRADE

| Category | Pass | Upgrade | Critical |
|----------|------|---------|----------|
| Config   | 1    | 0       | 0        |
| Agents   | 15   | 8       | 2        |
| Tasks    | 30   | 12      | 3        |
| Workflows| 2    | 1       | 0        |
| Files    | OK   | 1       | 0        |

Top 5 Critical Issues:
1. agents/{agent-1}.md - Missing ACTIVATION-NOTICE and loader structure (S-AGT-001)
2. agents/{agent-2}.md - No activation-instructions section (S-AGT-003)
3. tasks/{task-1}.md - Missing 3 required fields (S-TSK-001)
4. tasks/{task-2}.md - execution_type invalid (S-TSK-003)
5. agents/{agent-3}.md - Missing agent.name and agent.id (S-AGT-004, S-AGT-005)

Estimated Total Effort: 8-12h

NOTE: This report covers structural compliance only.
For qualitative analysis (voice DNA quality, thinking DNA gaps),
use squad-creator-pro *upgrade-squad.
```

---

## PHASE 2: UPGRADE PLAN

**Duration:** 1-2 minutes
**Mode:** Interactive (unless --auto)

### Step 2.1: Prioritize Upgrades

```yaml
prioritization_rules:
  critical:
    criteria:
      - "Blocking structural checks failing"
      - "Component unusable without fix"
    action: "Must fix before squad is production-ready"

  high:
    criteria:
      - "Missing required sections"
      - "Template structure non-compliant"
    action: "Should fix in this upgrade cycle"

  medium:
    criteria:
      - "Recommended checks failing"
      - "Quality score below 7.0"
    action: "Fix if time permits"

  low:
    criteria:
      - "Minor structural improvements"
      - "Format consistency issues"
    action: "Optional polish"
```

### Step 2.2: Generate Upgrade Plan

```yaml
upgrade_plan:
  squad: "{name}"
  generated: "{timestamp}"
  total_components: N
  components_to_upgrade: N
  estimated_effort: "X-Yh"
  upgrade_type: "STRUCTURAL"

  phases:
    - phase: 1
      name: "Critical Structural Fixes"
      components:
        - file: "agents/{agent-1}.md"
          upgrades:
            - "Add ACTIVATION-NOTICE at top"
            - "Add IDE-FILE-RESOLUTION section"
            - "Add activation-instructions section"
          effort: "45m"
          auto_applicable: true

        - file: "tasks/{task-1}.md"
          upgrades:
            - "Add missing fields: execution_type, acceptance_criteria"
            - "Convert input/output to arrays"
          effort: "20m"
          auto_applicable: true

    - phase: 2
      name: "Required Sections"
      components:
        - file: "agents/{agent-2}.md"
          upgrades:
            - "Add persona section with role and style"
            - "Add commands section with *help and *exit"
          effort: "30m"
          auto_applicable: true

    - phase: 3
      name: "Structural Polish"
      components:
        - file: "agents/{agent-3}.md"
          upgrades:
            - "Add empty voice_dna section (TODO placeholder)"
            - "Add empty output_examples section (TODO placeholder)"
            - "Add dependencies section"
          effort: "20m"
          auto_applicable: true
```

### Step 2.3: Present Plan for Approval

If mode != `auto`:

```
UPGRADE PLAN: {squad_name}
Type: STRUCTURAL UPGRADES ONLY

Phase 1: Critical Structural Fixes (Est: 1.5h)
  +-- agents/{agent-1}.md [AUTO] - Add loader structure (ACTIVATION-NOTICE, IDE-FILE-RESOLUTION)
  +-- agents/{agent-2}.md [AUTO] - Add loader structure
  +-- tasks/{task-1}.md [AUTO] - Add missing required fields

Phase 2: Required Sections (Est: 1h)
  +-- agents/{agent-2}.md [AUTO] - Add persona, commands sections
  +-- N more agents need structural sections

Phase 3: Structural Polish (Est: 30m)
  +-- agents/{agent-3}.md [AUTO] - Add empty placeholder sections
  +-- N more agents need placeholder sections

Options:
1. Execute Phase 1 only (critical structural fixes)
2. Execute Phases 1-2 (with mandatory sections)
3. Execute all phases
4. Export plan and exit
5. Cancel

Which option? [1-5]:
```

---

## PHASE 3: EXECUTE STRUCTURAL UPGRADES

**Duration:** Varies by scope
**Mode:** Interactive or Auto

This phase applies STRUCTURAL fixes only: adding missing fields, fixing format compliance,
inserting required sections with placeholder content. It does NOT generate qualitative content
like voice DNA vocabulary, output examples, or thinking DNA.

### Step 3.1: Auto-Applicable Structural Upgrades

Upgrades that can be safely automated (structural additions only):

```yaml
auto_upgrades:
  # Loader structure additions
  add_activation_notice:
    when: "ACTIVATION-NOTICE missing"
    action: |
      Insert at top of file:
      "ACTIVATION-NOTICE: This file contains your full agent operating guidelines..."
    safe: true

  add_ide_file_resolution:
    when: "IDE-FILE-RESOLUTION missing"
    action: |
      Insert IDE-FILE-RESOLUTION block with:
      - base_path: "squads/{squad_name}"
      - resolution_pattern based on squad structure
    safe: true

  add_activation_instructions:
    when: "activation-instructions missing"
    action: |
      Insert standard activation-instructions block with:
      - STEP 1: Read THIS ENTIRE FILE
      - STEP 2: Adopt persona
      - STEP 3: Greet user
      - Standard rules (DO NOT load external files, STAY IN CHARACTER, etc)
    safe: true

  # Agent identity fields
  add_agent_identity:
    when: "agent section missing required fields"
    action: |
      Add missing agent fields with TODO placeholders:
      agent:
        name: "TODO: Agent Name"
        id: "TODO: agent-id"
        title: "TODO: Agent Title"
        whenToUse: "TODO: When to use this agent (20+ chars)"
    safe: true
    requires_review: true

  # Task field additions
  add_missing_task_fields:
    when: "Task missing required fields"
    action: |
      Add missing fields with sensible defaults:
      - status: "pending"
      - execution_type: "Agent" (default)
      - input: [] (empty array)
      - output: [] (empty array)
      - action_items: [] (empty array)
      - acceptance_criteria: [] (empty array)
    safe: true
    requires_review: true

  convert_to_array:
    when: "input/output is string instead of array"
    action: |
      Convert: "Single item" -> ["Single item"]
    safe: true

  # Empty section placeholders
  add_empty_sections:
    when: "Required section missing"
    action: |
      Add empty section with TODO comment:
      voice_dna:
        # TODO: Add vocabulary, sentence_starters, metaphors
        # Use squad-creator-pro *upgrade-squad for qualitative voice DNA generation
        vocabulary:
          always_use: []
          never_use: []
      output_examples:
        # TODO: Add 3+ input/output examples
        # Use squad-creator-pro *upgrade-squad for qualitative example generation
        examples: []
    safe: true
    requires_review: true

  # Required files
  create_missing_readme:
    when: "README.md missing"
    action: |
      Create minimal README.md with:
      - Squad name and description from config.yaml
      - Agent list
      - Quick start section (TODO)
    safe: true
    requires_review: true

  create_missing_changelog:
    when: "CHANGELOG.md missing"
    action: |
      Create minimal CHANGELOG.md with:
      - Current version from config.yaml
      - Initial entry with current date
    safe: true
```

### Step 3.2: Apply Upgrades

```yaml
upgrade_execution:
  for_each_upgrade:
    - step: "Backup original file"
      action: "Copy to .backup/{filename}.{timestamp}.bak"

    - step: "Apply structural upgrade"
      action: "Modify file according to upgrade spec"

    - step: "Validate change"
      action: "Re-run relevant structural checks on modified section"

    - step: "Log change"
      action: |
        Add to upgrade_log:
          file: "{filename}"
          upgrade: "{upgrade_id}"
          timestamp: "{now}"
          status: "applied | failed | skipped"
          type: "structural"
          notes: "{any issues}"

  on_failure:
    action: "Restore from backup, log failure, continue"
```

**Phase 3 Output:**
```
STRUCTURAL UPGRADES APPLIED

Phase 1 Complete:
  [done] agents/{agent-1}.md - Added loader structure (ACTIVATION-NOTICE, IDE-FILE-RESOLUTION)
  [done] agents/{agent-2}.md - Added loader structure
  [done] tasks/{task-1}.md - Added missing required fields

Phase 2 Complete:
  [done] agents/{agent-2}.md - Added persona and commands sections
  [done] agents/{agent-3}.md - Added persona section

Phase 3 Complete:
  [done] agents/{agent-3}.md - Added empty voice_dna placeholder (TODO)
  [done] agents/{agent-4}.md - Added empty output_examples placeholder (TODO)

Changes Applied: 7
Changes Skipped: 0
Backups Created: 7

NOTE: All upgrades are structural. Placeholder sections marked with TODO
require qualitative content. Use squad-creator-pro *upgrade-squad for:
- Voice DNA generation from source material
- Output example creation
- Thinking DNA gap analysis
```

---

## PHASE 4: VERIFICATION

**Duration:** 2-3 minutes
**Mode:** Autonomous

### Step 4.1: Re-run Validation

```yaml
verification:
  action: "Run *validate-squad {squad_name}"
  compare:
    - "Before score vs After score"
    - "Before structural gaps vs After structural gaps"
    - "Blocking issues resolved?"
```

### Step 4.2: Generate Upgrade Report

```yaml
upgrade_report:
  header:
    squad: "{name}"
    upgrade_date: "{date}"
    upgrade_type: "STRUCTURAL"
    upgraded_by: "Squad Architect"

  summary:
    before_score: "6.8/10"
    after_score: "8.5/10"
    improvement: "+1.7 points"
    status: "PASS | NEEDS_MORE_WORK"

  changes_made:
    total: N
    by_type:
      structural: N
      formatting: N
      placeholder: N
    by_priority:
      critical: N
      high: N
      medium: N
      low: N

  components_upgraded:
    - file: "agents/{agent-1}.md"
      before: "5.2/10"
      after: "8.0/10"
      changes:
        - "Added ACTIVATION-NOTICE"
        - "Added IDE-FILE-RESOLUTION"
        - "Added activation-instructions"

  remaining_todos:
    structural:
      - file: "agents/{agent-2}.md"
        todo: "Fill in TODO placeholders for agent identity fields"
    qualitative:
      - file: "agents/{agent-3}.md"
        todo: "voice_dna section is empty placeholder - use squad-creator-pro for generation"
      - file: "agents/{agent-4}.md"
        todo: "output_examples section is empty placeholder - use squad-creator-pro for generation"

  recommendations:
    - "Fill in all TODO placeholders in upgraded files"
    - "For qualitative upgrades (voice DNA quality, thinking DNA gaps), use squad-creator-pro *upgrade-squad"
    - "Schedule follow-up validation in 1 week"

  backups:
    location: "squads/{squad}/.backup/"
    files: N
    restore_command: "cp .backup/{file}.bak {file}"
```

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Gap Report | Console + `{squad}/docs/gap-report-{date}.md` | Structural gap analysis |
| Upgrade Plan | Console | Prioritized structural upgrade plan |
| Upgrade Report | `{squad}/docs/upgrade-report-{date}.md` | Post-upgrade summary |
| Backups | `{squad}/.backup/` | Original files before upgrade |

---

## Usage

```bash
# Audit only (no changes)
@squad-chief
*upgrade-squad copy --mode=audit

# Generate plan
*upgrade-squad copy --mode=plan

# Execute with confirmations
*upgrade-squad copy --mode=execute

# Auto-execute all safe structural upgrades
*upgrade-squad copy --mode=auto

# Dry run (preview changes)
*upgrade-squad copy --mode=execute --dry-run

# Focus on specific component type
*upgrade-squad copy --focus=agents
*upgrade-squad copy --focus=tasks
```

---

## Anti-Patterns

### Never Do

- Upgrade without backup
- Auto-apply qualitative content changes (only structural)
- Skip validation after upgrades
- Ignore critical structural gaps
- Upgrade during active development on squad
- Attempt voice DNA generation or mind-cloning (that is squad-creator-pro territory)

### Always Do

- Backup before any modification
- Validate after every upgrade batch
- Document all changes in upgrade report
- Mark placeholder TODOs clearly
- Preserve original author intent
- Distinguish structural fixes from qualitative improvements

---

## Completion Criteria

```yaml
upgrade_complete_when:
  - "All critical structural gaps resolved (or documented as exceptions)"
  - "After score >= Before score + 1.0 (meaningful improvement)"
  - "No blocking structural checks failing"
  - "Upgrade report generated"
  - "Backups verified"

handoff_to:
  - agent: "@squad-chief"
    when: "Upgrade complete, user wants to validate"
    command: "*validate-squad {name}"

  - agent: "User"
    when: "Manual TODOs remain"
    context: "Review TODO markers in upgraded files"

qualitative_upgrade_note: |
  For qualitative upgrades beyond structural compliance, use:
    squad-creator-pro *upgrade-squad
  This includes:
    - Voice DNA quality analysis and generation
    - Thinking DNA gap detection
    - Output example quality improvement
    - Mind-cloning fidelity assessment
```

---

## Related

| Command | Purpose |
|---------|---------|
| `*validate-squad {name}` | Full validation (run after upgrade) |
| `*refresh-registry` | Update registry after upgrades |

| Reference | File |
|-----------|------|
| Agent Quality Gate | `checklists/agent-quality-gate.md` |
| Task Anatomy | `checklists/task-anatomy-checklist.md` |
| Squad Checklist | `checklists/squad-checklist.md` |
| Quality Dimensions | `data/quality-dimensions-framework.md` |
| Tier System | `data/tier-system-framework.md` |

---

