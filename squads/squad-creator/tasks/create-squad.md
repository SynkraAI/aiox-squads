# Task: Create Complete Squad

**Task ID:** create-squad
**Execution Type:** Hybrid
**Purpose:** Create a complete AIOX-FULLSTACK squad through guided elicitation, template selection, and validation
**Orchestrator:** @squad-chief
**Mode:** Incremental (human checkpoints) or YOLO (autonomous)
**Quality Standard:** AIOX Level (all components meet minimum standards)
**Model:** `Opus` (multi-phase orchestration with architecture tradeoffs and contextual elicitation)
**Haiku Eligible:** NO -- end-to-end squad orchestration demands high-complexity reasoning

**Frameworks Used:**
- `data/tier-system-framework.md` → Agent tier classification (Phase 2)
- `data/quality-dimensions-framework.md` → Squad validation (Phase 5)
- `data/decision-heuristics-framework.md` → Checkpoint logic (Phase 2, 5)
- `data/executor-matrix-framework.md` → Task executor assignment (Phase 3)
- `data/squad-type-definitions.yaml` → Squad type catalog (Phase 1)

---

## PRO DETECTION

> At execution time, check if `squads/squad-creator-pro/workflows/wf-create-squad.yaml` exists.
> If YES and pro mode is active → delegate to pro workflow override.
> If NO → continue with this base version.
>
> Pro mode check: `squads/squad-creator-pro/config.yaml` exists → pro_mode=true

---

## Overview

This task creates a complete, production-ready squad with all required components: agents, tasks, workflows, templates, checklists, and knowledge bases. The base version uses **template-driven creation** with domain research to build functional agents.

**Context-first entrypoint (recommended):**
- Run `detect-squad-context` first.
- If context is `greenfield_pure`, `pre_existing_brief`, or `partial_squad`, route to `wf-context-aware-create-squad`.
- If context is `legacy_assets`, route to `wf-brownfield-upgrade-squad`.

**v3.0 Changes:**
- Template-driven architecture (replaces mind-research-loop)
- Squad type selection from squad-type-definitions.yaml
- Simplified agent creation using templates/agent-tmpl.md
- PRO DETECTION block for automatic delegation to pro version
- Removed all mind-cloning and DNA extraction references

**Token economy rule (commands):**
- Keep primary commands only in `commands`.
- Store PT-BR aliases once in `command_aliases_ptbr`.
- Do not duplicate aliases in `commands`, `command_visibility`, and `all_commands`.

```
INPUT (domain + purpose + target_user)
    |
[PHASE 0: DISCOVERY]
    -> Validate domain viability
    -> Check for existing similar squads
    |
[PHASE 1: TEMPLATE SELECTION]
    -> Select squad type from squad-type-definitions.yaml
    -> Choose template approach (Operational vs Expert)
    -> Map use cases to agent roles
    |
[PHASE 2: ARCHITECTURE]
    -> Define tier structure (template-driven)
    -> Plan agent relationships
    -> Design quality gates
    |
[PHASE 3: CREATION]
    -> Create agents using templates/agent-tmpl.md
    -> Create workflows with checkpoints
    -> Create tasks with Task Anatomy
    |
[PHASE 4: INTEGRATION]
    -> Wire dependencies
    -> Generate documentation
    |
[PHASE 5: VALIDATION]
    -> Run squad-checklist.md
    -> Quality dimensions scoring
    -> Fix blocking issues
    |
OUTPUT: Complete squad + Quality Score
```

---

## Inputs

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `domain` | string | Yes | Domain expertise area | `"copywriting"`, `"legal"`, `"data"` |
| `purpose` | string | Yes | What the squad should accomplish | `"Create high-converting sales pages"` |
| `target_user` | string | Yes | Who will use this squad | `"Marketing teams at SaaS companies"` |
| `use_cases` | list | Yes | 3-5 key use cases | `["sales pages", "email sequences", "ads"]` |
| `mode` | enum | Yes | `"incremental"` or `"yolo"` | `"incremental"` |
| `squad_name` | string | No | Override default name | `"copy"` |

---

## Preconditions

- [ ] squad-chief agent is active
- [ ] WebSearch tool available (for research)
- [ ] Write permissions for `squads/` directory
- [ ] Frameworks loaded: tier-system, quality-dimensions, decision-heuristics, executor-matrix
- [ ] `data/squad-type-definitions.yaml` exists and is readable

---

## PHASE 0: DISCOVERY

**Duration:** 5-10 minutes
**Checkpoint:** SC_DSC_001 (Discovery Complete)
**Mode:** Interactive (both modes)

### Step 0.0: Workspace Domain Awareness

**Actions:**
```yaml
workspace_domain_check:
  read_files:
    - "workspace/workspace.yaml"          # Lista de dominios e providers
    - "workspace/domains/"                # Dominios existentes
    - "workspace/businesses/"             # BUs e produtos existentes

  checks:
    - domain_exists_in_workspace: "workspace/domains/{domain}/ existe?"
    - product_alignment: "Squad serve qual produto em workspace/businesses/{bu}/products/?"
    - provider_overlap: "Squad usa providers ja declarados em workspace.yaml?"

  output:
    workspace_context:
      domain_match: "exact | partial | none"
      related_products: ["list"]
      available_providers: ["list"]
      existing_squads_for_domain: ["list"]

  behavior:
    domain_exists: "Informar ao usuario que o dominio ja tem definicoes no workspace. Squad deve alinhar com entities.yaml e workflows.yaml do dominio."
    domain_not_exists: "Prosseguir normalmente. Apos criacao, sugerir criacao de workspace/domains/{domain}/"
```

### Step 0.1: Validate Domain Viability

**Actions:**
```yaml
domain_viability_check:
  questions:
    - "Is this domain well-documented with established methodologies?"
    - "Do recognized practitioners exist with documented frameworks?"
    - "Can outputs be validated against objective criteria?"
    - "Is there enough depth to warrant a squad (vs single agent)?"

  scoring:
    - documented_methodologies: 0-3
    - recognized_practitioners: 0-3
    - validation_criteria: 0-2
    - complexity_warrants_squad: 0-2

  threshold: 6/10
  veto_conditions:
    - recognized_practitioners < 2 -> "Cannot create quality agents without domain research"
```

**Decision Point:**
```
IF viability_score >= 6:
    -> PROCEED to Step 0.2
ELSE IF viability_score >= 4:
    -> WARN: "Domain may not support full squad. Consider single agent."
    -> ASK: "Proceed with limited scope?"
ELSE:
    -> BLOCK: "Domain lacks sufficient documented frameworks"
    -> SUGGEST: "Consider researching domain first or choosing adjacent domain"
```

### Step 0.1.5: Workspace Domain Awareness

**Actions:**
```yaml
workspace_domain_check:
  read_files:
    - "workspace/workspace.yaml"          # Dominios e providers registrados
    - "workspace/domains/"                # Dominios existentes
    - "workspace/businesses/"             # BUs e produtos existentes

  analysis:
    - domain_exists: "workspace/domains/{domain}/ existe?"
    - domain_has_entities: "workspace/domains/{domain}/entities.yaml existe?"
    - domain_has_workflows: "workspace/domains/{domain}/workflows.yaml existe?"
    - related_products: "Quais produtos referenciam este dominio?"
    - provider_alignment: "Quais providers o dominio usa?"

  output:
    workspace_context:
      domain_exists: true | false
      entities_count: N
      workflows_count: N
      related_products: ["product_a", "product_b"]
      providers: ["clickup", "supabase"]
    recommendation: "Alinhar agentes do squad com entidades e workflows existentes no workspace"
```

**Usage:**
- Se `workspace/domains/{domain}/` existe -> informar squad-chief para que agentes respeitem entidades existentes
- Se `workspace/domains/{domain}/entities.yaml` existe -> incluir entidades como contexto nos agentes criados
- Se `workspace/businesses/{bu}/products/` tem produtos relevantes -> alinhar use cases com produtos existentes
- Informacao e **read-only** -- nao modifica workspace, apenas enriquece o contexto da criacao

### Step 0.2: Check Existing Squads

**Actions:**
```yaml
existing_squad_check:
  search_paths:
    - "squads/{similar_names}/"
    - "squads/*/{domain}*"
    - ".claude/commands/*/{domain}*"

  analysis:
    - existing_coverage: "What does existing squad cover?"
    - gap_identification: "What's missing?"
    - extension_vs_new: "Extend existing or create new?"

  output:
    decision: "extend" | "create_new" | "abort_duplicate"
    rationale: "..."
```

**Decision Point:**
```
IF existing squad covers 80%+ of use cases:
    -> SUGGEST: "Extend existing squad instead"
    -> IF user confirms: -> GOTO extend-squad workflow
IF partial overlap:
    -> WARN: "Partial overlap detected. Plan for integration."
ELSE:
    -> PROCEED to Phase 1
```

### Step 0.3: Define Squad Structure

**Actions:**
```yaml
pack_structure_elicitation:
  required:
    - squad_name: "kebab-case identifier"
    - pack_title: "Human-readable title"
    - version: "1.0.0"
    - author: "Organization or person"
    - entry_agent: "Primary activation agent id (default: {squad_name}-chief)"
    - slash_prefix: "camelCase for commands"

  derived:
    - pack_path: "squads/{squad_name}/"
    - outputs_path: ".aiox/squad-runtime/create-squad/{squad_name}/"
    - command_path: ".claude/commands/{PackTitle}/"

  pattern_library:
    - prefix: "2-letter code (e.g., CP for Copy)"
    - initial_patterns:
      - "{PREFIX}-001: Core Process"
      - "{PREFIX}-002: Quality Standard"
      - "{PREFIX}-003: Exception Handling"
```

**Output (PHASE 0):**
```yaml
phase_0_output:
  viability_score: 8/10
  decision: "create_new"
  squad_name: "copy"
  pack_title: "Copy Squad"
  entry_agent: "copy-chief"
  slash_prefix: "copy"
  pattern_prefix: "CP"
  mode: "incremental"
```

**Checkpoint SC_DSC_001:**
```yaml
heuristic_id: SC_DSC_001
name: "Discovery Complete"
blocking: true
criteria:
  - viability_score >= 6
  - squad_name defined
  - no duplicate squad
```

---

## PHASE 1: TEMPLATE SELECTION

**Duration:** 5-15 minutes
**Checkpoint:** SC_TPL_001 (Template Selection Gate)
**Mode:** Interactive (incremental) / Autonomous (YOLO)

### Step 1.1: Load Squad Type Definitions

**Actions:**
```yaml
load_squad_types:
  file: "data/squad-type-definitions.yaml"
  required: true

  extract:
    - available_types: "List of squad archetypes"
    - type_characteristics: "What each type is optimized for"
    - recommended_agent_counts: "Min/max agents per type"
    - template_approaches: "Operational vs Expert patterns"
```

### Step 1.2: Select Squad Type

**Actions:**
```yaml
squad_type_selection:
  decision_inputs:
    - domain: "{domain}"
    - purpose: "{purpose}"
    - use_cases: "{use_cases}"
    - target_user: "{target_user}"

  matching_criteria:
    - domain_alignment: "Which type best fits the domain?"
    - use_case_coverage: "Which type covers the most use cases?"
    - complexity_match: "Does type complexity match squad needs?"

  elicit_if_ambiguous:
    question: "Multiple squad types could work. Which approach fits best?"
    present_options:
      - type: "Describe each matching type with pros/cons"
      - recommendation: "Highlight best match with rationale"
```

**Decision Point:**
```
IF clear single match:
    -> AUTO-SELECT and inform user
ELSE IF 2-3 close matches:
    -> PRESENT options with rationale
    -> ASK user to select
ELSE:
    -> WARN: "Domain is unusual. Using generic template."
    -> PROCEED with generic structure
```

### Step 1.3: Choose Template Approach

**Actions:**
```yaml
template_approach:
  operational:
    description: "Agents defined by function/role, not based on specific experts"
    best_for: "Technical domains, process-heavy workflows"
    agent_naming: "Function-based (e.g., analyzer, writer, reviewer)"
    example: "data-squad with etl-agent, query-optimizer, schema-designer"

  expert_template:
    description: "Agents modeled after domain expert archetypes using web research"
    best_for: "Creative domains, knowledge-heavy workflows"
    agent_naming: "Archetype-based (e.g., strategist, master-copywriter)"
    example: "copy-squad with headline-specialist, persuasion-expert"

  decision_tree:
    - IF domain is technical/process-oriented:
        approach: "operational"
    - ELSE IF domain is creative/knowledge-oriented:
        approach: "expert_template"
    - ELSE:
        approach: "hybrid (operational core + expert specialists)"
```

### Step 1.4: Map Use Cases to Agent Roles

**Actions:**
```yaml
use_case_agent_mapping:
  for_each_use_case:
    - use_case: "{use_case}"
      derive:
        - required_roles: "What agent roles are needed?"
        - tier_suggestion: "Which tier should handle this?"
        - shared_roles: "Can an existing role cover this?"

  output:
    agent_roster:
      - role: "diagnostician"
        tier: 0
        covers_use_cases: ["all - initial analysis"]
      - role: "primary-executor"
        tier: 1
        covers_use_cases: ["use_case_1", "use_case_2"]
      - role: "specialist"
        tier: 3
        covers_use_cases: ["use_case_3"]

  constraints:
    min_agents: 3
    max_agents: 12
    must_have_tier_0: true
    must_have_orchestrator: true
```

**Output (PHASE 1):**
```yaml
phase_1_output:
  squad_type: "expert_template"
  template_approach: "expert_template"
  agent_roster:
    - role: "diagnostician"
      tier: 0
      covers: ["all"]
    - role: "sales-page-writer"
      tier: 1
      covers: ["sales pages"]
    - role: "email-specialist"
      tier: 3
      covers: ["email sequences"]
  total_agents_planned: 6
  checkpoint_status: "PASS"
```

**Checkpoint SC_TPL_001:**
```yaml
heuristic_id: SC_TPL_001
name: "Template Selection Gate"
blocking: true
criteria:
  - squad_type selected
  - template_approach defined
  - agent_roster has tier_0
  - agent_roster has orchestrator
  - all use_cases mapped to at least one role
```

---

## PHASE 2: ARCHITECTURE

**Duration:** 10-20 minutes
**Checkpoint:** SC_ARC_001 (Architecture Approved)
**Mode:** Interactive (incremental) / Autonomous (YOLO)

### Step 2.1: Define Tier Structure

**Apply: tier-system-framework.md**

**Actions:**
```yaml
tier_structure_design:
  # Build from Phase 1 agent roster
  orchestrator:
    purpose: "Coordinates all tiers, routes requests"
    agent_id: "{squad_name}-chief"

  tier_0_diagnosis:
    purpose: "First contact, analysis, classification"
    agents: "From roster where tier == 0"
    required: true  # Every squad MUST have Tier 0

  tier_1_masters:
    purpose: "Primary experts with core execution capability"
    agents: "From roster where tier == 1"

  tier_2_systematizers:
    purpose: "Framework creators and methodology agents"
    agents: "From roster where tier == 2"

  tier_3_specialists:
    purpose: "Specific format/channel experts"
    agents: "From roster where tier == 3"

  tools:
    purpose: "Validation, checklists, calculators"
    examples: ["quality-checker", "compliance-validator"]
```

### Step 2.2: Plan Agent Relationships

**Actions:**
```yaml
agent_relationships:
  handoff_map:
    # Who hands off to whom
    - from: "orchestrator"
      to: "tier_0_agents"
      when: "New request arrives"

    - from: "tier_0_agents"
      to: "tier_1_agents"
      when: "Diagnosis complete, execution needed"

  synergies:
    # Who works well together
    - agents: ["diagnosis-agent", "master-agent"]
      pattern: "Diagnosis feeds master context"

  conflicts:
    # Who should NOT be combined
    - agents: ["aggressive-style", "conservative-style"]
      reason: "Contradictory approaches"
```

### Step 2.3: Design Quality Gates

**Actions:**
```yaml
quality_gates_design:
  gates:
    - id: "QG-001"
      name: "Request Classification"
      transition: "Input -> Tier 0"
      type: "routing"
      criteria: "Request type identified"

    - id: "QG-002"
      name: "Diagnosis Complete"
      transition: "Tier 0 -> Tier 1"
      type: "blocking"
      criteria: "Analysis approved, requirements clear"

    - id: "QG-003"
      name: "Draft Review"
      transition: "Execution -> Output"
      type: "blocking"
      criteria: "Quality checklist passed"

  escalation_paths:
    - on_failure: "Return to previous tier with feedback"
    - on_repeated_failure: "Escalate to human review"
```

**Output (PHASE 2):**
```yaml
phase_2_output:  # [Example]
  tier_structure:
    orchestrator: "{squad}-chief"
    tier_0: ["{diagnosis-agent-1}", "{diagnosis-agent-2}"]
    tier_1: ["{master-agent-1}", "{master-agent-2}"]
    tier_2: ["{systematizer-1}", "{systematizer-2}"]
    tier_3: ["{specialist-1}", "{specialist-2}"]
    tools: ["{tool-1}", "{tool-2}"]

  quality_gates: 5
  handoffs: 12
  architecture_score: 8/10
```

**Checkpoint SC_ARC_001:**
```yaml
heuristic_id: SC_ARC_001
name: "Architecture Approved"
blocking: true
criteria:
  - tier_0_defined: true
  - orchestrator_defined: true
  - quality_gates >= 3
  - handoff_map_complete: true

# Incremental mode: Human approval required
# YOLO mode: Auto-approve if criteria met
```

---

## PHASE 3: CREATION

**Duration:** 30-60 minutes (varies by squad size)
**Checkpoint:** SC_CRT_001 (Creation Quality)
**Mode:** Autonomous (both modes, with quality gates)

### Step 3.1: Create Directory Structure

**Actions:**
```yaml
create_directories:
  base: "squads/{squad_name}/"
  subdirectories:
    - agents/
    - tasks/
    - workflows/
    - templates/
    - checklists/
    - data/
    - docs/

  initial_files:
    - config.yaml (from templates/config-tmpl.yaml)
    - README.md (placeholder)
```

### Step 3.2: Create Agents (Template-Driven)

**For each agent in the roster, use the agent template directly:**
```yaml
for_each_agent_role:
  template: "templates/agent-tmpl.md"

  process:
    step_1_load_template:
      action: "Load templates/agent-tmpl.md as base structure"

    step_2_research_role:
      action: "Research domain best practices for this role via WebSearch"
      focus:
        - "What methodologies exist for this role?"
        - "What are the key frameworks and processes?"
        - "What vocabulary and terminology is standard?"
        - "What are common anti-patterns?"

    step_3_fill_template:
      action: "Fill template sections with researched content"
      sections:
        - agent_metadata: "name, id, title, icon, whenToUse"
        - persona: "role, style, identity, focus"
        - core_principles: "5-10 principles from domain research"
        - commands: "Role-specific commands"
        - voice_dna: "Domain-appropriate vocabulary and tone"
        - output_examples: "3+ realistic examples"
        - anti_patterns: "Domain-specific never_do/always_do"
        - completion_criteria: "Per task type"
        - handoff_to: "3+ handoff scenarios"

    step_4_validate:
      action: "Run agent-quality-gate.md for each agent"
      blocking: true
      retry_on_fail: true
      max_retries: 2

  quality_gate:
    # Each agent must pass SC_AGT_001
    blocking: true
    min_lines: 300
    required_sections:
      - voice_dna
      - output_examples
      - anti_patterns
      - completion_criteria
```

### Step 3.3: Create Orchestrator Agent

**Special agent creation:**
```yaml
create_orchestrator:
  agent_id: "{squad_name}-chief"
  role: "Squad Orchestrator"
  tier: "orchestrator"

  special_capabilities:
    - "Route requests to appropriate tier"
    - "Manage multi-agent workflows"
    - "Track context across handoffs"
    - "Report squad status"

  commands:
    - "*help" - List all squad capabilities
    - "*route" - Route request to best agent
    - "*status" - Show current context
    - "*handoff" - Transfer to specific agent

  must_include:
    - tier_routing_logic
    - quality_gate_checks
    - context_preservation
```

### Step 3.4: Create Workflows

**For complex multi-step operations:**
```yaml
create_workflows:
  # Identify operations that need workflows
  criteria:
    - spans_multiple_agents: true
    - has_intermediate_checkpoints: true
    - output_feeds_next_step: true

  template: "templates/workflow-tmpl.yaml"

  minimum_structure:
    - phases: 3+
    - checkpoints_per_phase: 1+
    - framework_references: 2+

  quality_standard:
    min_lines: 500
```

### Step 3.5: Create Tasks

**Apply: executor-matrix-framework.md**

**For atomic single-session operations:**
```yaml
create_tasks:
  # Each task follows Task Anatomy (8 fields)
  task_anatomy:
    - id: "Unique identifier"
    - purpose: "What and why"
    - executor: "Human | Agent | Hybrid | Worker"
    - inputs: "What it needs"
    - preconditions: "What must be true"
    - steps: "How to execute"
    - outputs: "What it produces"
    - validation: "How to verify"

  executor_assignment:
    # From data/executor-matrix-framework.md
    decision_tree:
      - IF rule_based AND low_stakes -> Worker
      - ELSE IF needs_judgment -> Hybrid (AI draft, human approve)
      - ELSE IF creative_synthesis -> Agent
      - ELSE -> Human

  quality_standard:
    simple_tasks: 300+ lines
    complex_tasks: 500+ lines
```

**Output (PHASE 3):**
```yaml
phase_3_output:
  agents_created: 8
  all_pass_quality_gate: true
  workflows_created: 3
  tasks_created: 12
  templates_created: 5
  total_lines: 14500
```

---

## PHASE 4: INTEGRATION

**Duration:** 10-15 minutes
**Checkpoint:** SC_INT_001 (Integration Complete)
**Mode:** Autonomous

### Step 4.1: Wire Dependencies

**Actions:**
```yaml
wire_dependencies:
  for_each_agent:
    - verify tasks exist
    - verify templates exist
    - verify checklists exist
    - update dependencies block

  create_missing:
    - if dependency referenced but doesn't exist -> create stub
    - mark stubs with TODO for later completion
```

### Step 4.2: Create Knowledge Base

**Actions:**
```yaml
create_knowledge_base:
  file: "data/{squad_name}-kb.md"

  sections:
    - domain_overview: "What this domain is about"
    - key_concepts: "Essential terminology"
    - best_practices: "From domain research"
    - common_patterns: "Reusable patterns"
    - anti_patterns: "What to avoid"
    - regulatory: "If applicable"
```

### Step 4.3: Generate Documentation

**Actions:**
```yaml
generate_documentation:
  readme:
    file: "README.md"
    sections:
      - overview
      - installation
      - quick_start
      - agents_list
      - workflows_list
      - tasks_list
      - templates_list
      - usage_examples

  config:
    file: "config.yaml"
    validate: true
```

### Step 4.4: Publish Chief Activation Surfaces (Command + Codex Skill)

**Actions:**
```yaml
publish_chief_activation:
  command_sync:
    task: "sync-ide-command"
    input:
      type: "squad"
      name: "{squad_name}"
    must_produce:
      - ".claude/commands/{slash_prefix}/agents/{entry_agent}.md"

  codex_skill_sync:
    task: "sync-chief-codex-skill"
    input:
      squad_name: "{squad_name}"
    must_produce:
      - ".codex/skills/{entry_agent}/SKILL.md"

  blocking_rule: "Do not finalize squad creation if either artifact is missing"
```

---

## PHASE 5: VALIDATION

**Duration:** 5-10 minutes
**Checkpoint:** SC_VAL_001 (Squad Validated)
**Mode:** Autonomous with human review option

### Step 5.1: Run Squad Checklist

**Execute: checklists/squad-checklist.md**

**Actions:**
```yaml
run_squad_checklist:
  categories:
    - structure: "Directory structure correct"
    - agents: "All agents meet standards"
    - workflows: "All workflows have checkpoints"
    - tasks: "All tasks follow anatomy"
    - documentation: "README complete"
    - integration: "Dependencies wired"

  blocking_items:
    - orchestrator_exists
    - tier_0_exists
    - quality_gates_defined
    - readme_complete
```

### Step 5.2: Quality Dimensions Scoring

**Apply: quality-dimensions-framework.md**

**Actions:**
```yaml
quality_scoring:
  dimensions:
    - accuracy: "Are agents well-researched and domain-accurate?"
    - coherence: "Do components work together?"
    - strategic_alignment: "Does squad serve purpose?"
    - operational_excellence: "Is squad usable?"
    - innovation_capacity: "Can squad grow?"
    - risk_management: "Are guardrails in place?"

  weights:
    accuracy: 0.20
    coherence: 0.20
    strategic_alignment: 0.15
    operational_excellence: 0.20
    innovation_capacity: 0.10
    risk_management: 0.15

  threshold: 7.0
  veto_if_below_5:
    - accuracy
    - coherence
    - operational_excellence
```

### Step 5.3: Fix Blocking Issues

**Actions:**
```yaml
fix_blocking_issues:
  for_each_blocking_issue:
    - identify_root_cause
    - determine_fix_approach
    - execute_fix
    - re-validate

  max_iterations: 3
  on_max_iterations_exceeded:
    - report_remaining_issues
    - ask_human_for_direction
```

### Step 5.4: Pro Enhancement Suggestion

**Conditional: Check for squad-creator-pro availability.**

```yaml
pro_enhancement_check:
  check: "squads/squad-creator-pro/config.yaml exists?"

  if_pro_available:
    suggest: |
      Squad creation complete with base quality.
      For further improvement, squad-creator-pro is installed.
      Run *optimize to apply:
        - Mind-cloned agents based on real experts
        - Voice DNA extraction for authentic tone
        - Thinking DNA for expert-level reasoning
        - Advanced fidelity scoring and calibration

  if_pro_not_available:
    note: "Base squad created. For mind-cloned agents based on real experts, install squad-creator-pro."
```

**Output (PHASE 5):**
```yaml
phase_5_output:
  checklist_pass: true
  quality_score: 8.2/10
  blocking_issues_resolved: 2
  warnings: 3
  pro_available: true/false
  status: "PASS"
```

---

## PHASE 6: HANDOFF

**Duration:** 2-5 minutes
**Mode:** Interactive

### Step 6.1: Present Squad Summary

**Actions:**
```yaml
present_summary:
  created:
    - agents: 8
    - workflows: 3
    - tasks: 12
    - templates: 5
    - checklists: 4

  quality:
    - overall_score: 8.2/10
    - template_approach: "expert_template"
    - tier_coverage: "Full (0-3 + tools)"

  activation:
    - install: "npm run install:squad {squad_name}"
    - activate: "@{squad_name}"
    - example: "@{squad-name}:{agent-name}"
```

### Step 6.2: Document Next Steps

**Actions:**
```yaml
next_steps:
  optional_improvements:
    - "Add more specialists to Tier 3"
    - "Create domain-specific templates"
    - "Add integration tests"
    - "If squad-creator-pro installed, run *optimize for mind-cloned agents"

  handoff_to:
    - agent: "qa-architect"
      when: "Need deep validation audit"
    - agent: "domain-orchestrator"
      when: "Ready to use squad"
```

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Squad Directory | `squads/{squad_name}/` | Complete squad structure |
| Agents | `squads/{squad_name}/agents/` | All agent definitions |
| Workflows | `squads/{squad_name}/workflows/` | Multi-phase workflows |
| Tasks | `squads/{squad_name}/tasks/` | Atomic tasks |
| Templates | `squads/{squad_name}/templates/` | Output templates |
| Checklists | `squads/{squad_name}/checklists/` | Validation checklists |
| Runtime Outputs | `.aiox/squad-runtime/create-squad/{squad_name}/` | Artifacts gerados em execucoes reais |
| Knowledge Base | `squads/{squad_name}/data/{squad_name}-kb.md` | Domain knowledge |
| Documentation | `squads/{squad_name}/README.md` | Usage documentation |
| Config | `squads/{squad_name}/config.yaml` | Squad configuration |

---

## Validation Criteria (All Must Pass)

### Structure
- [ ] Squad directory exists at `squads/{squad_name}/`
- [ ] All required subdirectories created
- [ ] config.yaml is valid YAML
- [ ] config.yaml defines explicit `entry_agent`
- [ ] Runtime state exists at `.aiox/squad-runtime/create-squad/{squad_name}/state.json`

### Agents
- [ ] Orchestrator agent exists
- [ ] At least one Tier 0 agent exists
- [ ] All agents pass SC_AGT_001 (300+ lines, voice_dna, etc.)
- [ ] All agents have tier assigned

### Workflows
- [ ] Complex operations have workflows (not just tasks)
- [ ] All workflows have 3+ phases
- [ ] All workflows have checkpoints

### Tasks
- [ ] All tasks follow Task Anatomy (8 fields)
- [ ] Complex tasks are 500+ lines
- [ ] Executor assigned for each task

### Documentation
- [ ] README.md complete with all sections
- [ ] Usage examples provided
- [ ] Installation instructions clear

### Quality
- [ ] Overall score >= 7.0
- [ ] No blocking items failed
- [ ] Domain research documented

---

## Heuristics Reference

| Heuristic ID | Name | Where Applied | Blocking |
|--------------|------|---------------|----------|
| SC_DSC_001 | Discovery Complete | Phase 0 | Yes |
| SC_TPL_001 | Template Selection Gate | Phase 1 | Yes |
| SC_ARC_001 | Architecture Approved | Phase 2 | Yes |
| SC_AGT_001 | Agent Quality Gate | Phase 3 | Yes |
| SC_CRT_001 | Creation Quality | Phase 3 | Yes |
| SC_INT_001 | Integration Complete | Phase 4 | No |
| SC_VAL_001 | Squad Validated | Phase 5 | Yes |

---

## Veto Conditions

Hard blockers that MUST halt the pipeline. Each veto has a unique ID,
trigger condition, and blocking behavior. These align with the `fix_cycle`
and `failed` states in `create-squad.yaml`.

| ID | Condition | Trigger | Behavior |
|----|-----------|---------|----------|
| VETO-SQD-001 | Overwrite without confirmation | Squad directory already exists AND user has not explicitly confirmed overwrite | HALT pipeline at PHASE 0. Prompt user for confirmation or abort. |
| VETO-SQD-002 | Validation score below threshold after retries | Quality score < 7.0 after `fix_cycle` exhausts `max_retries` (2) | Transition to `failed` state. No further automated recovery. Manual intervention required. |
| VETO-SQD-003 | Missing entry agent | `config.yaml` has no `entry_agent` field OR referenced agent file does not exist | HALT at PHASE 3 validation step. Cannot proceed to integration without a valid entry point. |
| VETO-SQD-004 | Missing workspace integration level | `config.yaml` has no `workspace_integration.level` field | HALT at PHASE 3 validation step. Every squad must declare its workspace integration level (none/read_only/read_write/workspace_first). |
| VETO-SQD-005 | Smoke test failure | All 3 smoke test scenarios fail (activation, help, basic_task) | Transition to `failed` state via `smoke_failed` trigger. Squad is not safe to register. |

**Veto enforcement:** Vetos are checked at their respective phase boundaries.
A triggered veto writes a `VETO-SQD-{NNN}` entry to the validation report
and transitions the pipeline to `failed` (terminal, no recovery).

---

## Error Handling

```yaml
error_handling:
  template_selection_fails:
    - review_domain_against_squad_types
    - if_no_match: "Use generic template with domain customization"

  agent_creation_fails:
    - identify_missing_research
    - supplement_with_web_search
    - retry_creation
    - if_still_fails: "Create simpler agent, note for improvement"

  validation_fails:
    - log_specific_failures
    - attempt_automated_fix
    - if_cannot_fix: "Report to human for decision"
```

---

## Integration with AIOX

This task creates squads that seamlessly integrate with:
- Core AIOX-FULLSTACK framework
- Standard installer (`npm run install:squad`)
- Memory layer for tracking
- Agent activation system (@agent-id syntax)
- Quality frameworks for validation

---

_Task Version: 3.0_
_Last Updated: 2026-02-24_
_Lines: 500+_
