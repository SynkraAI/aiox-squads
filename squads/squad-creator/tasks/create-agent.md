# Task: Create Squad Agent

**Task ID:** create-agent
**Execution Type:** Agent
**Execution Rationale:** "Core operations (research, elicitation, creation) require LLM interpretation. Preflight validations (squad exists, sources count) could be scripted in future."
**Model:** Opus
**Model Rationale:** "Research + synthesis + creative generation = non-deterministic"
**Haiku Eligible:** NO -- deep research synthesis and creative persona generation require higher-capability reasoning
**Purpose:** Create a single domain-specific agent through template-based elicitation, research, and validation
**Orchestrator:** @squad-chief
**Mode:** Template-first (load template, elicit domain info, fill, validate)
**Quality Standard:** AIOX Level (300+ lines, voice_dna, output_examples)

> **Note:** This is the base version. For mind-cloned agents based on real experts, use squad-creator-pro with `*clone-mind` workflow.

**Frameworks Used:**
- `data/tier-system-framework.md` → Agent tier classification (Phase 3)
- `data/quality-dimensions-framework.md` → Agent validation (Phase 4)
- `data/decision-heuristics-framework.md` → Quality gate logic (Phase 4)

---

## PRO DETECTION

> At execution time, check if `squads/squad-creator-pro/workflows/wf-research-then-create-agent.yaml` exists.
> If YES and pro mode is active → delegate to pro workflow override.
> If NO → continue with this base version.
>
> Pro mode check: `squads/squad-creator-pro/config.yaml` exists → pro_mode=true

---

## DESIGN RULES (Non-Negotiable)

```yaml
self_contained:
  rule: "Squad DEVE ser self-contained - tudo dentro da pasta do squad"
  allowed:
    - "squads/{squad-name}/agents/*.md"
    - "squads/{squad-name}/tasks/*.md"
    - "squads/{squad-name}/data/*.yaml"
    - "squads/{squad-name}/checklists/*.md"
    - "squads/{squad-name}/minds/**/*"
  forbidden:
    - ".aiox/squad-runtime/minds/*"  # DNA extraido deve ser INTEGRADO, nao referenciado
    - ".aiox-core/*"     # Nao depender de core externo
    - "docs/*"           # Documentacao externa
  exception: "Mission router pode lazy-load tasks/data DO PROPRIO squad"

functional_over_philosophical:
  rule: "Agent deve saber FAZER o trabalho, nao ser clone perfeito"
  include:
    - "SCOPE - o que faz/nao faz"
    - "Heuristics - regras SE/ENTAO para decisoes"
    - "Core methodology - como executar a funcao INLINE"
    - "Voice DNA condensado - tom + 5 signature phrases"
    - "Handoff + Veto - quando parar/delegar"
    - "Output examples - calibracao de output"
  exclude_or_condense:
    - "Psychometric completo -> 1 paragrafo"
    - "Values hierarchy 16 itens -> top 5 relevantes a funcao"
    - "Core obsessions 7 itens -> 3 relevantes a funcao"
    - "Productive paradoxes -> remover se nao operacional"
    - "Dual persona -> so se funcao exige multiplos modos"

curadoria_over_volume:
  rule: "Menos mas melhor - curadoria > volume"
  targets:
    agent_lines: "400-800 lines focadas > 1500 lines dispersas"
    heuristics: "10 heuristics uteis > 30 genericas"
    signature_phrases: "5 verificaveis > 20 inferidas"
  mantra: "Se entrar lixo, sai lixo do outro lado"
```

**VETO CONDITIONS:**
- Agent referencia arquivo fora do squad -> VETO
- Agent tem >50% de conteudo filosofico vs operacional -> VETO
- Agent nao tem SCOPE definido -> VETO
- Agent nao tem heuristics de decisao -> VETO
- Agent nao tem output examples -> VETO

---

## Overview

This task creates a single high-quality agent using a template-driven approach. The agent template (`templates/agent-tmpl.md`) provides the structure, while domain elicitation and web research provide the content.

**v3.0 Changes:**
- Template-based creation flow (replaces research-then-create workflow)
- Domain info elicited from user directly
- Web research supplements elicitation (not replaces it)
- Removed all mind-cloning and DNA extraction references
- PRO DETECTION block for automatic delegation

```
INPUT (agent_purpose + domain + squad_name)
    |
[PHASE 1: TEMPLATE LOADING]
    -> Load templates/agent-tmpl.md
    -> Identify all required sections
    |
[PHASE 2: DOMAIN ELICITATION]
    -> Elicit role, scope, style, expertise areas from user
    -> Gather domain-specific vocabulary and anti-patterns
    |
[PHASE 3: TEMPLATE FILLING]
    -> Research domain best practices via web search
    -> Fill template with elicited info + research
    -> Classify tier and define persona
    |
[PHASE 4: VALIDATION]
    -> Run agent-quality-gate.md
    -> Fix blocking issues
    -> Save agent file
    |
OUTPUT: Agent file + Quality Gate PASS
```

---

## Inputs

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `agent_purpose` | string | Yes | What the agent should do | `"Create sales pages"` |
| `domain` | string | Yes | Domain/area of expertise | `"copywriting"` |
| `squad_name` | string | Yes | Target squad | `"copy"` |
| `agent_role` | string | No | Specific role within squad | `"headline-specialist"` |
| `tier_hint` | integer | No | Suggested tier (0-3) | `1` |

---

## Preconditions

- [ ] Target squad exists at `squads/{squad_name}/`
- [ ] squad-chief agent is active
- [ ] WebSearch tool available (for research)
- [ ] Write permissions for `squads/{squad_name}/agents/`
- [ ] Apply `squads/squad-creator/protocols/ai-first-governance.md`

## AI-First Governance Gate (Mandatory)

- [ ] Map `Existing -> Gap -> Decision` before creating agent
- [ ] Validate canonical sources (squad config/tasks/workflows/data)
- [ ] Mark dependency status: `implemented | partial | concept`
- [ ] List unresolved items; do not claim full completion if any unresolved

---

## PHASE 1: TEMPLATE LOADING

**Duration:** < 2 minutes
**Checkpoint:** None (fast validation)
**Mode:** Automatic

### Step 1.1: Identify Target Squad

**Actions:**
```yaml
identify_squad:
  validation:
    - check_path: "squads/{squad_name}/"
    - check_exists: true
    - load_config: "config.yaml"

  on_not_exists:
    option_1: "Create squad first with *create-squad"
    option_2: "Create agent standalone (not recommended)"
```

**Decision Point:**
```
IF squad_name provided AND squad exists:
    -> PROCEED
ELSE IF squad_name provided AND NOT exists:
    -> ASK: "Squad doesn't exist. Create it first?"
ELSE:
    -> ASK: "Which squad should this agent belong to?"
```

### Step 1.2: Load Agent Template

**Actions:**
```yaml
load_template:
  file: "templates/agent-tmpl.md"
  required: true

  extract_required_sections:
    # Level 1: Identity
    - activation_notice: "Standard AIOX header"
    - ide_file_resolution: "Dependency mapping"
    - activation_instructions: "Step-by-step activation"
    - agent_metadata: "name, id, title, icon, whenToUse"
    - persona: "role, style, identity, focus"

    # Level 2: Operational
    - core_principles: "5-10 principles"
    - commands: "Available commands"
    - quality_standards: "Domain methodology"
    - dependencies: "tasks, templates, checklists, data"
    - knowledge_areas: "Expertise domains"
    - capabilities: "What agent can do"

    # Level 3: Voice DNA
    - voice_dna: "vocabulary, sentence starters, metaphors, emotional states"

    # Level 4: Quality
    - output_examples: "3+ real examples"
    - objection_algorithms: "4+ common objections"
    - anti_patterns: "never_do (5+), always_do (5+)"
    - completion_criteria: "By task type"

    # Level 5: Credibility
    - credibility: "Domain authority markers"

    # Level 6: Integration
    - handoff_to: "3+ handoff scenarios"
    - synergies: "Related agents/workflows"

  output:
    template_loaded: true
    sections_to_fill: 18
    template_lines: N
```

**Output (PHASE 1):**
```yaml
phase_1_output:
  squad_name: "{squad-name}"
  pack_path: "squads/{squad-name}/"
  template_loaded: true
  sections_to_fill: 18
```

---

## PHASE 2: DOMAIN ELICITATION

**Duration:** 5-10 minutes
**Checkpoint:** SC_ELC_001 (Elicitation Complete)
**Mode:** Interactive (always requires user input)

### Step 2.1: Elicit Core Agent Identity

**Actions:**
```yaml
elicit_identity:
  questions:
    - agent_name: "What should this agent be called? (e.g., 'Sales Page Writer', 'Data Analyst')"
    - agent_id: "Short kebab-case identifier? (e.g., 'sales-page-writer', derived from name)"
    - role_description: "What is this agent's primary role? (1-2 sentences)"
    - icon: "What emoji best represents this agent?"
    - when_to_use: "When should users activate this agent? (1 sentence)"

  auto_derive:
    - agent_id: "From agent_name, kebab-case"
    - title: "From role_description, short form"
```

### Step 2.2: Elicit Scope and Expertise

**Actions:**
```yaml
elicit_scope:
  questions:
    - primary_tasks: "What are the 3-5 main tasks this agent performs?"
    - out_of_scope: "What should this agent NOT do? (3+ items)"
    - expertise_areas: "What specific knowledge domains does this agent cover?"
    - methodology: "What methodology or framework should this agent follow?"
    - tools_and_dependencies: "What tools or data does this agent need access to?"

  optional_questions:
    - reference_experts: "Are there specific experts or methodologies to draw from?"
    - existing_standards: "Are there existing quality standards for this domain?"
```

### Step 2.3: Elicit Style and Voice

**Actions:**
```yaml
elicit_voice:
  questions:
    - communication_tone: "How should this agent communicate? (e.g., formal, casual, technical, creative)"
    - vocabulary_always: "What domain terms should the agent always use? (5+ terms)"
    - vocabulary_never: "What terms should the agent avoid? (3+ terms)"
    - signature_phrases: "Any catchphrases or signature expressions? (3-5)"
    - emotional_range: "What emotional states should the agent express? (e.g., confident when teaching, cautious when reviewing)"

  fallback_if_minimal_input:
    action: "Derive voice characteristics from domain research in Phase 3"
    note: "Web research will supplement any gaps in voice definition"
```

### Step 2.4: Elicit Quality Criteria

**Actions:**
```yaml
elicit_quality:
  questions:
    - completion_criteria: "How do you know when the agent's task is done well?"
    - common_mistakes: "What are the most common mistakes in this domain?"
    - quality_checklist: "What should the agent always check before delivering output?"
    - handoff_triggers: "When should this agent hand off to another agent or human?"
```

**Checkpoint SC_ELC_001:**
```yaml
heuristic_id: SC_ELC_001
name: "Elicitation Complete"
blocking: true
criteria:
  - agent_name defined
  - role_description defined
  - primary_tasks >= 3
  - out_of_scope >= 3
  - methodology defined or research_needed flagged
```

**Output (PHASE 2):**
```yaml
phase_2_output:
  agent_name: "{Agent Name}"
  agent_id: "{agent-id}"
  role: "{role description}"
  scope:
    does: ["task1", "task2", "task3"]
    does_not: ["exclusion1", "exclusion2", "exclusion3"]
  methodology: "{methodology or 'research_needed'}"
  voice:
    tone: "{tone}"
    vocabulary_always: ["term1", "term2", "term3"]
    vocabulary_never: ["term1", "term2"]
  checkpoint_status: "PASS"
```

---

## PHASE 3: TEMPLATE FILLING

**Duration:** 10-20 minutes
**Checkpoint:** None (validation in Phase 4)
**Mode:** Autonomous

### Step 3.1: Research Domain Best Practices

**Actions:**
```yaml
domain_research:
  method: "WebSearch"

  queries:
    - "{domain} best practices {agent_purpose}"
    - "{domain} methodology framework"
    - "{domain} expert techniques {primary_tasks}"
    - "{domain} common anti-patterns mistakes"

  extract:
    - methodologies: "Step-by-step processes"
    - frameworks: "Decision frameworks and mental models"
    - vocabulary: "Standard domain terminology"
    - anti_patterns: "Common mistakes and what to avoid"
    - quality_criteria: "How experts evaluate work"

  quality_criteria:
    min_unique_sources: 3
    requires_actionable_content: true
    max_inference_ratio: 0.30  # 70%+ must be cited or elicited

  output:
    research_summary:
      sources_used: N
      methodologies_found: N
      vocabulary_extracted: N
```

### Step 3.2: Classify Tier

**Apply: tier-system-framework.md**

**Actions:**
```yaml
classify_tier:
  decision_tree:
    - IF agent performs diagnosis/analysis FIRST:
        tier: 0
        rationale: "Foundation agent - must run before execution"

    - ELSE IF agent is primary executor with core methodology:
        tier: 1
        rationale: "Master with execution capability"

    - ELSE IF agent created/systematizes frameworks:
        tier: 2
        rationale: "Systematizer - methodology agent"

    - ELSE IF agent specializes in specific format/channel:
        tier: 3
        rationale: "Format specialist"

    - ELSE IF agent is validation/checklist tool:
        tier: "tools"
        rationale: "Utility agent"

  override:
    if_tier_hint_provided: "Use tier_hint, validate against decision_tree"
```

### Step 3.3: Fill Template Sections

**Actions:**
```yaml
fill_template:
  template: "templates/agent-tmpl.md"

  section_sources:
    # Level 1: Identity (from elicitation)
    agent_metadata:
      name: "From Step 2.1 elicit_identity"
      id: "From Step 2.1 auto_derive"
      title: "From Step 2.1 role_description"
      icon: "From Step 2.1 icon"
      whenToUse: "From Step 2.1 when_to_use"

    persona:
      role: "From Step 2.2 + research"
      style: "From Step 2.3 communication_tone"
      identity: "Synthesized from elicitation + research"
      focus: "From Step 2.2 primary_tasks"

    # Level 2: Operational (from elicitation + research)
    core_principles:
      source: "Combine elicited methodology + researched best practices"
      count: "5-10 principles"

    commands:
      source: "Derive from primary_tasks"
      standard: ["*help", "*exit"]

    quality_standards:
      source: "From Step 2.4 + research"

    dependencies:
      source: "From Step 2.2 tools_and_dependencies"

    # Level 3: Voice DNA (from elicitation + research)
    voice_dna:
      vocabulary_always_use: "From Step 2.3 + research vocabulary"
      vocabulary_never_use: "From Step 2.3"
      sentence_starters: "Derived from tone + domain conventions"
      metaphors: "5+ domain-appropriate metaphors from research"
      emotional_states: "From Step 2.3 emotional_range"

    # Level 4: Quality (from elicitation + research)
    output_examples:
      source: "3+ examples from domain research showing input -> output"
      requirement: "Must use vocabulary.always_use terms"

    objection_algorithms:
      source: "Derived from Step 2.4 common_mistakes"
      count: "4+ objection/response pairs"

    anti_patterns:
      never_do: "From Step 2.4 common_mistakes + research"
      always_do: "From Step 2.2 methodology + research"

    completion_criteria:
      source: "From Step 2.4 completion_criteria"

    # Level 5: Credibility
    credibility:
      source: "Domain authority markers from research"

    # Level 6: Integration
    handoff_to:
      source: "From Step 2.4 handoff_triggers"
      count: "3+ scenarios"

  validation_during_fill:
    - "All output_examples use vocabulary.always_use"
    - "No output_examples use vocabulary.never_use"
    - "Sentence starters match emotional_states"
    - "Metaphors appear in examples"
```

### Step 3.4: Apply Voice Consistency

**Actions:**
```yaml
voice_consistency_check:
  ensure:
    - "All sections use consistent tone from Step 2.3"
    - "Vocabulary terms from always_use appear across output_examples"
    - "No forbidden vocabulary appears in any section"
    - "Signature phrases woven into agent identity and examples"

  fix_if_inconsistent:
    - "Replace generic terms with domain vocabulary"
    - "Adjust tone in sections that drift from persona"
```

**Output (PHASE 3):**
```yaml
phase_3_output:
  agent_file_content: "..."
  lines: 550
  sections_complete: 6/6
  voice_consistency: true
  tier: 1
```

---

## PHASE 4: VALIDATION

**Duration:** 2-5 minutes
**Checkpoint:** SC_AGT_001 (Agent Quality Gate)
**Mode:** Autonomous with retry

### Step 4.1: Run Quality Gate SC_AGT_001

**Checklist:** `checklists/agent-quality-gate.md`

**Actions:**
```yaml
run_quality_gate:
  heuristic_id: SC_AGT_001
  name: "Agent Quality Gate"
  blocking: true

  blocking_requirements:
    lines: ">= 300"
    voice_dna:
      vocabulary_always_use: ">= 5 items"
      vocabulary_never_use: ">= 3 items"
    output_examples: ">= 3"
    anti_patterns_never_do: ">= 5"
    completion_criteria: "defined"
    handoff_to: "defined"

  scoring:
    | Dimension | Weight | Check |
    |-----------|--------|-------|
    | Structure | 0.20 | All 6 levels present |
    | Voice DNA | 0.20 | Complete with vocabulary |
    | Examples | 0.20 | Real, not generic |
    | Anti-patterns | 0.15 | Specific to domain |
    | Integration | 0.15 | Handoffs defined |
    | Research | 0.10 | Traceable to sources |

  threshold: 7.0
  veto_conditions:
    - lines < 300 -> "Agent too short"
    - no_voice_dna -> "Missing voice consistency"
    - examples < 3 -> "Insufficient examples"
```

**Decision Point:**
```
IF all blocking requirements pass AND score >= 7.0:
    -> PROCEED to Step 4.3
ELSE:
    -> Log specific failures
    -> GOTO Step 4.2 (Fix Issues)
```

### Step 4.2: Fix Blocking Issues

**Actions:**
```yaml
fix_blocking_issues:
  for_each_failure:
    - identify: "What's missing"
    - source: "Where to get it"
    - fix: "Add the content"

  common_fixes:
    lines_short:
      - "Expand core_principles with detail"
      - "Add more output_examples"
      - "Expand objection_algorithms"

    missing_voice_dna:
      - "Extract from domain research"
      - "Add vocabulary lists"
      - "Define emotional states"

    few_examples:
      - "Research domain for real examples"
      - "Create based on methodology"
      - "Ensure they show input -> output"

  max_iterations: 2
  on_max_iterations: "Flag for human review"
```

### Step 4.3: Save Agent File

**Actions:**
```yaml
save_agent:
  path: "squads/{squad_name}/agents/{agent_id}.md"

  post_save:
    - verify_yaml_valid
    - update_pack_readme
    - update_config_yaml
    - log_creation
```

**Output (PHASE 4):**
```yaml
# Example output - values will vary based on your squad
phase_4_output:
  quality_score: 8.3/10
  blocking_requirements: "ALL PASS"
  agent_file: "squads/{squad-name}/agents/{agent-name}.md"
  lines: 550
  status: "PASS"
```

---

## PHASE 5: HANDOFF

**Duration:** < 1 minute
**Mode:** Interactive

### Step 5.1: Present Agent Summary

**Actions:**
```yaml
# Example output - values will vary based on your squad
present_summary:
  agent_created:
    name: "{Agent Name}"
    id: "{agent-id}"
    tier: 1
    file: "squads/{squad-name}/agents/{agent-id}.md"
    lines: 550

  quality:
    score: 8.3/10
    research_sources: 5
    voice_dna: "Complete"

  activation:
    command: "@{squad-name}:{agent-id}"
    example: "{example task for this agent}"

  commands:
    - "*help - Show available commands"
    - "*{primary-task} - Main task"

  pro_note: |
    This agent was created using template-based elicitation.
    For mind-cloned agents based on real experts with Voice DNA
    and Thinking DNA extraction, use squad-creator-pro:
      *clone-mind {expert-name}
```

### Step 5.2: Document Next Steps

**Actions:**
```yaml
next_steps:
  recommended:
    - "Test agent with sample task"
    - "Create associated tasks if needed"
    - "Add to squad orchestrator routing"

  optional:
    - "Create more agents for the squad"
    - "Build workflows that use this agent"
    - "If squad-creator-pro installed, enhance with *clone-mind for expert fidelity"

  handoff_to:
    - agent: "squad-chief"
      when: "Continue building squad"
    - agent: "created-agent"
      when: "Ready to use agent"
```

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Agent File | `squads/{squad_name}/agents/{agent_id}.md` | Complete agent definition |
| Updated README | `squads/{squad_name}/README.md` | Agent added to list |
| Updated Config | `squads/{squad_name}/config.yaml` | Agent registered |

---

## Validation Criteria (All Must Pass)

### Structure
- [ ] Agent file created at correct location
- [ ] YAML block is valid
- [ ] All 6 levels present

### Content
- [ ] Lines >= 300
- [ ] voice_dna complete with vocabulary
- [ ] output_examples >= 3
- [ ] anti_patterns.never_do >= 5
- [ ] completion_criteria defined
- [ ] handoff_to defined

### Quality
- [ ] SC_AGT_001 score >= 7.0
- [ ] Domain research performed
- [ ] Tier assigned

### Integration
- [ ] README.md updated
- [ ] config.yaml updated
- [ ] Dependencies exist or noted

---

## Heuristics Reference

| Heuristic ID | Name | Where Applied | Blocking |
|--------------|------|---------------|----------|
| SC_ELC_001 | Elicitation Complete | Phase 2 | Yes |
| SC_AGT_001 | Agent Quality Gate | Phase 4 | Yes |

---

## Error Handling

```yaml
error_handling:
  elicitation_incomplete:
    - note_missing_fields
    - research_to_supplement
    - if_critical_missing: "Re-elicit from user"

  research_insufficient:
    - retry_with_different_queries
    - expand_search_scope
    - if_still_fails: "Create agent with TODO notes for gaps"

  validation_fails:
    - identify_specific_failures
    - attempt_automated_fix
    - if_cannot_fix: "Save as draft, flag for review"

  pack_not_exists:
    - suggest_create_pack_first
    - offer_standalone_option
```

---

## Integration with AIOX

This task creates agents that:
- Follow AIOX agent definition standards (6 levels)
- Can be activated with @squad:agent-id syntax
- Integrate with memory layer
- Support standard command patterns (*help, *exit, etc.)
- Work within squad structure
- Pass quality gate SC_AGT_001

---

_Task Version: 3.0_
_Last Updated: 2026-02-24_
_Lines: 400+_
