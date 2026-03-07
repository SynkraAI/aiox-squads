# Task: Generate Squad Overview

**Task ID:** squad-overview
**Purpose:** Generate comprehensive SQUAD-OVERVIEW.md documentation for any squad
**Orchestrator:** @squad-chief
**Mode:** Documentation generation with analysis
**Execution Type:** `Agent` (requires synthesis of multiple sources)
**Model:** `Sonnet` (documentation generation, moderate complexity)
**Haiku Eligible:** NO -- cross-source synthesis and narrative cohesion require reasoning

**Core Philosophy:**
```
A squad without proper documentation is a squad nobody can use.
SQUAD-OVERVIEW.md is the single source of truth for squad understanding.
Generate once, reference always.
```

---

## Task Anatomy

| Field | Value |
|-------|-------|
| **task_name** | Generate Squad Overview |
| **status** | `pending` |
| **responsible_executor** | @squad-chief |
| **execution_type** | `Agent` |
| **input** | squad_name, squad_path (optional) |
| **output** | SQUAD-OVERVIEW.md |
| **action_items** | 6 phases |
| **acceptance_criteria** | 8 criteria |

---

## Overview

This task generates a comprehensive SQUAD-OVERVIEW.md document that serves as the complete reference for any squad. The document includes:

- Vision and attributes
- Team composition and tier architecture
- Expert biographies (if mind-based)
- DNA extraction details (if applicable)
- Complete file structure
- Integrated frameworks
- Available commands
- Workflow diagrams
- Quality gates
- Usage examples

---

## Inputs

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `squad_name` | string | Yes | Name of squad to document | `"franchise"` |
| `squad_path` | string | No | Override default path | `"squads/franchise/"` |
| `include_minds` | boolean | No | Include mind DNA details | `true` (default) |
| `format` | string | No | Output format | `"detailed"` or `"compact"` |

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| SQUAD-OVERVIEW.md | `{squad_path}/SQUAD-OVERVIEW.md` | Complete squad documentation |

---

## Action Items

### PHASE 1: COLLECT SQUAD METADATA

**Duration:** < 1 minute
**Mode:** Autonomous

```yaml
collect_metadata:
  - action: "Read config.yaml"
    file: "{squad_path}/config.yaml"
    extract:
      - name
      - version
      - description
      - entry_agent
      - icon (if exists)
      - domain
      - whenToUse

  - action: "Read README.md header"
    file: "{squad_path}/README.md"
    extract:
      - title
      - tagline
      - quick_description

  - action: "Count components"
    commands:
      - "Count agents: ls {squad_path}/agents/*.md | wc -l"
      - "Count tasks: ls {squad_path}/tasks/*.md | wc -l"
      - "Count workflows: ls {squad_path}/workflows/*.yaml | wc -l"
      - "Count templates: ls {squad_path}/templates/*.* | wc -l"
      - "Count checklists: ls {squad_path}/checklists/*.md | wc -l"
      - "Count data files: ls {squad_path}/data/*.* | wc -l"
      - "Total size: du -sh {squad_path}"
```

---

### PHASE 2: ANALYZE AGENTS

**Duration:** 2-3 minutes
**Mode:** Agent analysis

```yaml
analyze_agents:
  for_each_agent:
    - action: "Read agent file"
      extract:
        - name/id
        - title/role
        - tier (if exists)
        - icon
        - whenToUse
        - commands (list)
        - line_count
        - file_size

  - action: "Detect agent types"
    checks:
      - "Is orchestrator/chief? (has delegation patterns)"
      - "Is expert clone? (has voice_dna, thinking_dna)"
      - "Is functional? (pure role, no DNA)"

  - action: "Build tier architecture"
    output:
      tier_0: [diagnostic/leader agents]
      tier_1: [master agents]
      tier_2: [specialist agents]
      orchestrator: [chief/coordinator]

  - action: "Extract handoff map"
    for_each_agent:
      - "handoff_to targets"
      - "receives_from sources"
```

---

### PHASE 3: COLLECT MIND DNA (if applicable)

**Duration:** 1-2 minutes
**Mode:** Conditional

```yaml
collect_mind_dna:
  condition: "include_minds == true AND .aiox/squad-runtime/minds/{expert}/ exists"

  for_each_expert:
    - action: "Check mind directory"
      path: ".aiox/squad-runtime/minds/{expert_slug}/"

    - action: "List DNA files"
      files:
        - voice_dna.yaml OR voice-dna.md
        - thinking_dna.yaml OR thinking-dna.md
        - mind_dna_complete.yaml
        - sources_inventory.yaml
        - quality_dashboard.md

    - action: "Extract key info"
      extract:
        - fidelity_score
        - frameworks_count
        - heuristics_count
        - source_count

    - action: "Build expert profile"
      output:
        name: "{expert_name}"
        role: "{role_in_squad}"
        fidelity: "{fidelity_score}"
        dna_files: [list]
        key_frameworks: [list]
```

---

### PHASE 4: ANALYZE STRUCTURE & FRAMEWORKS

**Duration:** 1-2 minutes
**Mode:** Analysis

```yaml
analyze_structure:
  - action: "Build directory tree"
    output: |
      squads/{squad_name}/
      ├── config.yaml
      ├── README.md
      ├── agents/
      │   ├── {agent-1}.md
      │   └── ...
      ├── tasks/
      ├── workflows/
      ├── templates/
      ├── checklists/
      └── data/

  - action: "Extract frameworks"
    for_each_agent:
      - "Search for framework patterns"
      - "Extract framework names and purposes"

  - action: "Build command table"
    for_each_agent:
      for_each_command:
        - command_name
        - description
        - delegates_to (if applicable)

  - action: "Map workflow flow"
    if_workflows_exist:
      - "Extract phase sequence"
      - "Identify handoffs"
      - "Build flow diagram"
```

---

### PHASE 5: GENERATE DOCUMENT

**Duration:** 2-3 minutes
**Mode:** Generation

```yaml
generate_document:
  sections:
    - id: "vision"
      title: "VISAO GERAL"
      content:
        - Squad name and tagline
        - Attributes table (name, version, location, size, activation, compliance)
        - Key differentiators

    - id: "team"
      title: "TIME DE ESPECIALISTAS"
      content:
        - Tier architecture diagram
        - Agent details table (name, role, lines, tier, fidelity)
        - Total lines count

    - id: "experts"
      title: "SOBRE OS ESPECIALISTAS"
      condition: "has_real_experts"
      content:
        - Biography for each expert
        - Credentials and achievements
        - Key contributions

    - id: "dna"
      title: "DNA EXTRAIDO"
      condition: "has_mind_dna"
      content:
        - Directory structure
        - Files per expert
        - Fidelity scores

    - id: "structure"
      title: "ESTRUTURA DO SQUAD"
      content:
        - Complete directory tree
        - Component counts

    - id: "frameworks"
      title: "FRAMEWORKS INTEGRADOS"
      content:
        - Framework table by expert
        - Application descriptions

    - id: "commands"
      title: "COMANDOS DISPONIVEIS"
      content:
        - Leader commands table
        - Commands by specialist table

    - id: "workflow"
      title: "FLUXO DE TRABALHO"
      content:
        - ASCII workflow diagram
        - Phase descriptions

    - id: "compliance"
      title: "COMPLIANCE"
      condition: "has_compliance_config"
      content:
        - Legal requirements
        - Standards followed

    - id: "integrations"
      title: "INTEGRACOES"
      content:
        - Receives from (other squads)
        - Delivers to (other squads)
        - Internal AIOX integrations

    - id: "quality_gates"
      title: "QUALITY GATES"
      content:
        - Gate definitions
        - Minimum scores

    - id: "usage"
      title: "COMO USAR"
      content:
        - Activation command
        - Common workflow examples

    - id: "heuristics"
      title: "HEURISTICAS-CHAVE"
      condition: "has_heuristics"
      content:
        - Key decision rules by expert

    - id: "metrics"
      title: "METRICAS"
      content:
        - Creation statistics
        - Quality scores

    - id: "closing"
      title: "TIME DOS SONHOS"
      condition: "has_real_experts"
      content:
        - Expert summary with flags
        - Squad philosophy
```

---

### PHASE 6: WRITE OUTPUT

**Duration:** < 30 seconds
**Mode:** Write

```yaml
write_output:
  - action: "Write SQUAD-OVERVIEW.md"
    path: "{squad_path}/SQUAD-OVERVIEW.md"

  - action: "Verify file"
    checks:
      - "File exists"
      - "File > 500 lines (for detailed format)"
      - "All sections present"

  - action: "Report completion"
    output: |
      ✅ SQUAD-OVERVIEW.md created
      📁 {squad_path}/SQUAD-OVERVIEW.md
      📏 {line_count} lines
      📦 {file_size}
```

---

## Output Template

```markdown
# SQUAD {SQUAD_NAME} — Documentacao Completa

---

## VISAO GERAL

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                      {ICON} SQUAD {NAME} v{VERSION}                        │
│                                                                             │
│   "{TAGLINE}"                                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

| Atributo | Valor |
|----------|-------|
| Nome | {name} |
| Versao | {version} |
| Localizacao | squads/{name}/ |
| Tamanho | {size} ({file_count} arquivos) |
| Ativacao | @{entry_agent} |
| {Compliance if exists} | {compliance_info} |

---

## TIME DE ESPECIALISTAS

### Arquitetura de Tiers

{ASCII_TIER_DIAGRAM}

### Detalhamento dos Agents

| Agent | Papel | Linhas | Tamanho | Tier | Fidelidade DNA |
|-------|-------|--------|---------|------|----------------|
{AGENT_ROWS}

Total: {total_lines} linhas de agents especializados

---

## SOBRE OS ESPECIALISTAS

{FOR_EACH_EXPERT}
### {EXPERT_NAME}

- **Credenciais:** {credentials}
- **Foco:** {focus_area}
- **Frameworks principais:** {frameworks}
- **Por que no squad:** {rationale}
{/FOR_EACH_EXPERT}

---

## DNA EXTRAIDO (MINDS)

{MIND_DIRECTORY_STRUCTURE}

---

## ESTRUTURA DO SQUAD

{DIRECTORY_TREE}

---

## FRAMEWORKS INTEGRADOS

| Expert | Framework | Aplicacao |
|--------|-----------|-----------|
{FRAMEWORK_ROWS}

---

## COMANDOS DISPONIVEIS

### Comandos do Lider (@{leader})

| Comando | Descricao | Delega para |
|---------|-----------|-------------|
{LEADER_COMMAND_ROWS}

### Comandos por Especialista

| Agent | Comandos Principais |
|-------|---------------------|
{SPECIALIST_COMMAND_ROWS}

---

## FLUXO DE TRABALHO COMPLETO

{ASCII_WORKFLOW_DIAGRAM}

---

## COMPLIANCE

{COMPLIANCE_DETAILS}

---

## INTEGRACOES

{INTEGRATION_DIAGRAM}

---

## QUALITY GATES

{QUALITY_GATE_DEFINITIONS}

---

## COMO USAR

```bash
# 1. Ativar o squad
@{entry_agent}

# 2. Comando principal
*{main_command}

# 3. Fluxo tipico
{typical_flow}
```

---

## HEURISTICAS-CHAVE

| Expert | ID | Heuristica |
|--------|----|------------|
{HEURISTIC_ROWS}

---

## METRICAS DE CRIACAO

| Metrica | Valor |
|---------|-------|
| Agents criados | {agent_count} |
| Tasks criadas | {task_count} |
| Workflows criados | {workflow_count} |
| Fidelidade media DNA | {avg_fidelity} |
| Linhas totais | {total_lines} |

---

## TIME DOS SONHOS — ENTREGUE

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
{EXPERT_SUMMARY_BOX}
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

---

Squad {name} v{version} — Pronto para uso! {icon}

— Clone minds > create bots.
```

---

## Acceptance Criteria

| ID | Criterion | Measurement |
|----|-----------|-------------|
| AC-1 | File created | SQUAD-OVERVIEW.md exists in squad root |
| AC-2 | All sections present | Document has all applicable sections |
| AC-3 | Agents documented | All agents listed with metadata |
| AC-4 | Commands documented | All commands from all agents listed |
| AC-5 | Structure documented | Directory tree is complete |
| AC-6 | Workflow documented | Flow diagram present (if workflows exist) |
| AC-7 | Minimum length | > 300 lines for detailed format |
| AC-8 | No placeholders | No {PLACEHOLDER} text in final output |

---

## Quality Gate

**Reference Checklist:** `checklists/squad-overview-checklist.md`

```yaml
quality_gate:
  id: "QG-SQOV-001"
  name: "Squad Overview Quality Gate"
  placement: "exit"
  type: "hybrid"
  severity: "warning"
  checklist: "squad-overview-checklist.md"

  scoring:
    total_points: 100
    categories:
      structure_completeness: 30
      content_quality: 35
      technical_accuracy: 20
      visual_formatting: 15

  thresholds:
    excellent: 90  # Ready for production
    pass: 80       # Acceptable
    conditional: 70 # Needs fixes
    fail: 60       # Regenerate

  veto_conditions:
    - "File doesn't exist"
    - "< 100 lines"
    - "No VISAO GERAL section"
    - "No commands section"
    - "Contains {PLACEHOLDER} text"
```

**Post-Generation Validation:**
1. Run quick validation script from checklist
2. Apply 100-point scoring
3. Report score in completion message

---

## Usage

```bash
# Generate overview for any squad
@squad-chief
*squad-overview franchise

# With options
*squad-overview copy --format=compact

# Without mind details
*squad-overview design --include-minds=false
```

---

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| Squad not found | config.yaml missing | Report error, list available squads |
| No agents | agents/ empty | Create minimal doc with warning |
| Mind dir missing | .aiox/squad-runtime/minds/{expert}/ not found | Skip DNA section, note in doc |

---

## Integration

This task integrates with:
- `*validate-squad` — Can run after validation to document validated squad
- `*create-squad` — Automatically called at end of squad creation
- `*refresh-registry` — Updates registry after doc creation

---

## Examples

### Example 1: Franchise Squad

```bash
*squad-overview franchise
```

**Output:** `squads/franchise/SQUAD-OVERVIEW.md` with:
- 6 experts documented
- Compliance section for Lei 13.966/2019
- Complete workflow diagram
- 600+ lines

### Example 2: Pipeline Squad

```bash
*squad-overview book-summary --include-minds=false
```

**Output:** `squads/book-summary/SQUAD-OVERVIEW.md` with:
- Orchestrator documented
- Phase-based workflow
- No DNA section (pipeline, not expert-based)
- 400+ lines

---

## Related

| Command | Purpose |
|---------|---------|
| `*squad-overview {name}` | Generate this documentation |
| `*validate-squad {name}` | Validate squad first |
| `*squad-analytics` | Get detailed metrics |

| Reference | File |
|-----------|------|
| **Quality Checklist** | `checklists/squad-overview-checklist.md` |
| Squad Checklist | `checklists/squad-checklist.md` |
| Type Definitions | `data/squad-type-definitions.yaml` |

---

