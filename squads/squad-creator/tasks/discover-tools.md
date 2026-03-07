# Task: Discover Tools for Squad

**Task ID:** discover-tools
**Execution Type:** Agent
**Purpose:** Research and discover MCP servers that can potentialize a squad's deliverables
**Orchestrator:** @squad-chief
**Mode:** Autonomous with human validation
**Quality Standard:** AIOX Level (comprehensive research, validated sources)
**Model:** `Opus` (multi-source research synthesis and prioritization)
**Haiku Eligible:** NO -- discovery quality depends on deep semantic evaluation

**Frameworks Used:**
- `data/quality-dimensions-framework.md` → Tool quality scoring
- `data/decision-heuristics-framework.md` → Tool selection logic
- `protocols/ai-first-governance.md` → Canonical scope validation + contradiction guard

> **Note:** This is the base version focused on MCP server discovery. For comprehensive multi-source discovery (APIs, CLIs, Libraries, GitHub Projects, Skills/Prompts), use squad-creator-pro `*discover-tools`.

---

## PRO DETECTION

> At execution time, check if `squads/squad-creator-pro/workflows/wf-discover-tools.yaml` exists.
> If YES and pro mode is active → delegate to pro workflow override.
> If NO → continue with this base version.
>
> Pro mode check: `squads/squad-creator-pro/config.yaml` exists → pro_mode=true

---

## Overview

This task validates domain context, scans internal infrastructure, identifies capability gaps, and searches for MCP servers to fill those gaps. The base version focuses on the highest-value tool category (MCP servers) and produces a synthesized report.

**Philosophy:** "A squad should leverage available MCP tools to deliver maximum value with minimum user intervention."

**v3.0 Changes:**
- Simplified to MCP-focused discovery (base version)
- Removed API, CLI, GitHub, Library, and Skill discovery phases (moved to pro)
- Internal infrastructure scan uses existing squad structure instead of external library
- PRO DETECTION block for automatic delegation

```
INPUT (domain + use_cases + existing_capabilities)
    |
[PHASE -2: DOMAIN CONTEXT VALIDATION]
    -> Resolve domain intent from canonical artifacts
    -> Build evidence pack (paths + status)
    -> Block on ambiguity (no name-only inference)
    |
[PHASE -1: INTERNAL INFRASTRUCTURE DISCOVERY]
    -> Scan existing squad structure and capabilities
    -> Map internal capability coverage
    -> Define external-only search scope
    |
[PHASE 0: CAPABILITY GAP ANALYSIS + LOCAL SKILLS SCAN]
    -> Map required capabilities
    -> Scan local skills (.claude/skills/) and squads (squads/*/config.yaml)
    -> Check what tools already provide
    -> Identify gaps to fill
    |
[PHASE 1: MCP SERVER DISCOVERY]
    -> Search official MCP repositories
    -> Search GitHub for MCP servers
    -> Validate and score findings
    |
[PHASE 2: SYNTHESIS & RECOMMENDATIONS]
    -> Score MCP findings
    -> Rank by impact vs effort
    -> Generate integration report
    |
OUTPUT: Tool Discovery Report + Capability Map
```

---

## Inputs

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `domain` | string | Yes | Squad domain | `"copywriting"`, `"legal"`, `"data"` |
| `use_cases` | list | Yes | Key squad use cases | `["sales pages", "email sequences"]` |
| `existing_tools` | list | No | Tools already in use | `["exa", "web_fetch"]` |
| `capability_gaps` | list | No | Known capability gaps | `["pdf_processing", "email_sending"]` |
| `budget_tier` | enum | No | `"free_only"`, `"low_cost"`, `"enterprise"` | `"low_cost"` |
| `scope_hint` | string | No | Extra clarification when domain name is ambiguous | `"rules extraction from code"` |

---

## Preconditions

- [ ] squad-chief agent is active
- [ ] WebSearch/EXA tool available (for research)
- [ ] WebFetch tool available (for page analysis)
- [ ] Write permissions for `.aiox/squad-runtime/discovery/{domain}/`
- [ ] Domain and use cases clearly defined
- [ ] Domain scope resolved from canonical sources (not inferred from name)

## Veto Conditions

```yaml
veto_conditions:
  - id: "VETO-TOOLS-001"
    condition: "Canonical domain context unresolved or contradictory"
    trigger: "Before external search (PHASE -2 ambiguity gate)"
    block_behavior: "BLOCK recommendations; require clarification first"

  - id: "VETO-TOOLS-002"
    condition: "Recommended tool has no compatibility evidence for required capability"
    trigger: "During synthesis/ranking phase"
    block_behavior: "BLOCK recommendation from final list until compatibility is validated"
```

---

## PHASE -2: DOMAIN CONTEXT VALIDATION (MANDATORY)

**Duration:** 2-6 minutes
**Checkpoint:** SC_DCV_001 (Domain Context Validation Gate)
**Mode:** Autonomous + Elicitation on ambiguity

### Step -2.1: Resolve Scope From Canonical Artifacts

**Actions:**
```yaml
scope_resolution:
  canonical_sources_priority:
    - "squads/{domain}/squad.yaml"
    - "squads/{domain}/config.yaml"
    - "squads/{domain}/README.md"
    - "{registry_path}"
    - "related squad workflows/tasks/agents"

  rules:
    - "DO NOT infer scope from slug/name alone"
    - "Collect explicit domain/purpose/use-cases evidence"
    - "Mark unresolved or conflicting sources explicitly"
```

### Step -2.2: Build Canonical Evidence Pack

**Actions:**
```yaml
evidence_pack:
  required_fields:
    - source_path
    - extracted_scope_statement
    - status: "implemented|partial|concept"

  output:
    canonical_scope:
      declared_domain: ""
      declared_purpose: ""
      evidence: []
      contradictions: []
      confidence: "high|medium|low"
```

### Step -2.3: Enforce Ambiguity Gate

**Actions:**
```yaml
ambiguity_gate:
  pass_when:
    - "declared_domain is explicit"
    - "declared_purpose is explicit"
    - "no unresolved contradiction"

  fail_when:
    - "scope derived only from name/slug"
    - "canonical files missing/conflicting"
    - "confidence == low"

  on_fail:
    action: "HALT discovery and ask user clarification before external search"
```

**Output (PHASE -2):**
```yaml
phase_minus_2_output:
  scope_status: "verified|partial|unverified"
  canonical_scope:
    domain: ""
    purpose: ""
  evidence_paths: []
  contradictions_found: []
  requires_user_clarification: true/false
```

---

## PHASE -1: INTERNAL INFRASTRUCTURE DISCOVERY (MANDATORY)

**Duration:** 3-8 minutes
**Checkpoint:** SC_INT_001 (Internal Coverage Gate)
**Mode:** Autonomous

### Step -1.1: Scan Existing Squad Structure

**Actions:**
```yaml
internal_scan:
  scan_paths:
    - "squads/{domain}/config.yaml"       # Squad configuration
    - "squads/{domain}/agents/"            # Existing agents
    - "squads/{domain}/tasks/"             # Existing tasks
    - "squads/{domain}/workflows/"         # Existing workflows
    - "squads/{domain}/data/"              # Existing data files

  extract:
    - declared_tools: "From config.yaml tools section"
    - agent_capabilities: "From agent definitions"
    - task_dependencies: "From task dependency blocks"
    - workflow_integrations: "From workflow tool references"

  also_scan:
    - ".claude/settings.local.json"        # Configured MCP servers
    - ".claude/settings.json"              # Project MCP servers
```

### Step -1.2: Map Internal Coverage

**Actions:**
```yaml
internal_coverage_mapping:
  for_each_use_case:
    - derive_required_capabilities: true
      match_against: "existing agent/task/tool capabilities"

  output:
    covered_by_internal: []
    partially_covered_by_internal: []
    not_covered_by_internal: []
```

### Step -1.3: Define External Search Scope

**Actions:**
```yaml
external_scope_definition:
  rule: "Search external only for not_covered_by_internal OR justified enhancement"

  for_each_capability:
    if covered_by_internal:
      external_search: "skip"
      recommendation_policy: "internal_primary"
    if partially_covered_by_internal:
      external_search: "optional"
      recommendation_policy: "internal_primary + external_fallback"
    if not_covered_by_internal:
      external_search: "required"
      recommendation_policy: "external_primary_allowed"
```

**Output (PHASE -1):**
```yaml
phase_minus_1_output:
  internal_capabilities_found: 12
  covered_by_internal: 8
  partial_internal: 2
  external_only_gaps: 2
  external_search_scope:
    required: ["pdf_processing", "email_automation"]
    optional: ["benchmark_timing"]
```

---

## PHASE 0: CAPABILITY GAP ANALYSIS

**Duration:** 5-10 minutes
**Checkpoint:** None (fast analysis)
**Mode:** Autonomous

### Step 0.1: Map Required Capabilities

**Actions:**
```yaml
capability_mapping:
  for_each_use_case:
    - use_case: "{use_case}"
      ask:
        - "What INPUT does this use case need?"
        - "What PROCESSING does it require?"
        - "What OUTPUT should it produce?"
        - "What INTEGRATIONS would enhance it?"

      derive:
        input_capabilities:
          - "web_research"        # If needs external info
          - "file_reading"        # If needs local files
          - "user_input"          # If needs user data
          - "api_data"            # If needs external data

        processing_capabilities:
          - "text_analysis"       # NLP, sentiment, etc.
          - "data_transformation" # ETL, formatting
          - "code_generation"     # If creates code
          - "image_processing"    # If handles images

        output_capabilities:
          - "file_generation"     # Creates files
          - "api_calls"           # Sends to external services
          - "notifications"       # Alerts/messages
          - "reports"             # Structured reports

        enhancement_capabilities:
          - "automation"          # Reduces manual work
          - "quality_checks"      # Validates output
          - "integration"         # Connects to other tools
```

### Step 0.2: Check Existing Tool Coverage

**Actions:**
```yaml
coverage_analysis:
  loads:
    - "squads/{domain}/config.yaml"       # Squad tools
    - ".claude/settings.local.json"       # Configured MCPs

  for_each_capability:
    - check: "capability_mapping.{capability}"
      find_tools: true

      result:
        covered_internal: ["internal_tool1"]
        partially_covered_internal: ["internal_tool2"]
        covered: ["tool1", "tool2"]
        partially_covered: ["tool3"]
        not_covered: true/false

  output:
    coverage_report:
      internal_fully_covered: []
      internal_partially_covered: []
      fully_covered: []
      partially_covered: []
      gaps: []  # Only external-only gaps go to MCP discovery
```

### Step 0.2b: Scan Local Skills & Squads

**Actions:**
```yaml
local_skills_scan:
  # 1. Scan project-level skills
  scan_path: ".claude/skills/*/SKILL.md"
  for_each_skill:
    extract:
      - name: "from frontmatter"
      - description: "from frontmatter"
      - capabilities: "inferred from description + body"
      - agent: "if skill delegates to specific agent"
      - tools_used: "allowed-tools from frontmatter"

    match_against: capability_requirements
    classify:
      - COVERS: "Skill directly solves this capability"
      - ADAPTABLE: "Skill partially covers, can be forked/extended"
      - UNRELATED: "No match"

  # 2. Scan squad capabilities
  scan_path: "squads/*/config.yaml"
  for_each_squad:
    extract:
      - domain
      - agents: "names + specialties"
      - tasks: "names + purposes"
      - workflows: "names + purposes"
      - skills: "if embedded"

    match_against: capability_requirements
    classify:
      - REUSABLE: "Squad component directly applicable"
      - ADAPTABLE: "Component can be modified for this domain"
      - UNRELATED: "Different domain, no overlap"

  # 3. Scan global skills (user-level)
  scan_path: "~/.claude/skills/*/SKILL.md"
  same_extraction: true

  output:
    local_skills_coverage:
      skills_scanned: N
      squads_scanned: N
      covers:
        - capability: "web_research"
          covered_by:
            - { type: "skill", name: "tech-search", path: ".claude/skills/tech-search/SKILL.md" }
      adaptable:
        - capability: "competitor_analysis"
          adaptable_from:
            - { type: "squad", name: "spy", component: "deep-research task", effort: "low" }
      gaps: []  # Capabilities with NO skill/squad coverage
```

**Key Principle:** Skills are zero-cost and immediate.
A local skill that covers a capability should be preferred over adding external tool complexity.

### Step 0.3: Prioritize Gaps

**Actions:**
```yaml
gap_prioritization:
  for_each_gap:
    - capability: "{gap}"
      score:
        impact: 0-10  # How much value does filling this gap add?
        frequency: 0-10  # How often is this capability needed?
        user_dependency: 0-10  # How much does gap require user intervention?

      priority: (impact * 0.4) + (frequency * 0.3) + (user_dependency * 0.3)

  input_filter:
    only_include:
      - "not_covered_by_internal"
      - "partially_covered_by_internal_with_strong_justification"

  output:
    prioritized_gaps:
      - capability: "..."
        priority: 8.5
        search_queries: []
```

**Output (PHASE 0):**
```yaml
phase_0_output:
  total_capabilities_needed: 15
  already_covered: 8
  partially_covered: 3
  gaps_to_research: 4
  prioritized_gaps:
    - capability: "pdf_processing"
      priority: 9.2
    - capability: "email_automation"
      priority: 8.5
    - capability: "competitor_monitoring"
      priority: 7.8
```

---

## PHASE 1: MCP SERVER DISCOVERY

**Duration:** 10-15 minutes
**Checkpoint:** SC_MCP_001 (MCP Discovery Gate)
**Mode:** Autonomous

**Scope Rule:** Only search capabilities from `external_search_scope.required` plus justified optional enhancements.

### Step 1.1: Search Official MCP Repositories

**Actions:**
```yaml
official_mcp_search:
  sources:
    - url: "https://github.com/modelcontextprotocol/servers"
      type: "official"
      priority: 1

    - url: "https://github.com/anthropics/anthropic-tools"
      type: "official"
      priority: 1

    - url: "https://glama.ai/mcp/servers"
      type: "directory"
      priority: 2

  search_queries:
    - "MCP server {domain}"
    - "Model Context Protocol {use_case}"
    - "{domain} anthropic MCP"

  for_each_result:
    extract:
      - name
      - description
      - capabilities
      - installation
      - requirements
      - last_updated
      - stars
      - issues_count
```

### Step 1.2: Search GitHub for Community MCPs

**Actions:**
```yaml
github_mcp_search:
  queries:
    - query: "topic:mcp-server {domain}"
      type: "topic"
    - query: "mcp server {domain} in:readme"
      type: "code"
    - query: "model context protocol {use_case}"
      type: "repositories"

  filters:
    - stars: ">= 10"
    - updated: "within 6 months"
    - has_readme: true
    - has_license: true

  for_each_result:
    validate:
      - has_installation_docs: true
      - has_usage_examples: true
      - compatible_with_claude: true  # Check for anthropic/claude mentions
```

### Step 1.3: Score and Rank MCP Findings

**Actions:**
```yaml
mcp_scoring:
  criteria:
    official_source:
      weight: 0.30
      check: "Is from modelcontextprotocol or anthropic?"

    documentation:
      weight: 0.20
      check: "Has complete README?"

    maintenance:
      weight: 0.20
      check: "Updated in last 6 months?"

    community:
      weight: 0.15
      check: "Stars > 50? Active issues?"

    capability_match:
      weight: 0.15
      check: "Solves prioritized gap?"

  threshold: 6.0
  max_recommendations: 5
```

**Output (PHASE 1):**
```yaml
phase_1_output:
  mcps_found: 12
  mcps_qualified: 5
  top_recommendations:
    - name: "mcp-server-pdf"
      score: 8.5
      fills_gap: "pdf_processing"
      source: "https://github.com/..."
      install: "npm install @mcp/server-pdf"
```

---

## PHASE 2: SYNTHESIS & RECOMMENDATIONS

**Duration:** 5-10 minutes
**Checkpoint:** SC_TDR_001 (Tool Discovery Report Gate)
**Mode:** Interactive

### Step 2.1: Consolidate All Findings

**Actions:**
```yaml
consolidation:
  combine:
    - phase_minus_1_output  # Internal-first baseline
    - phase_0_output        # Local skills/squads coverage snapshot
    - phase_1_output        # MCPs

  deduplicate:
    - "Same tool found in multiple searches"

  categorize_by_gap:
    - gap: "pdf_processing"
      tools: [mcp-pdf]
      skills: []
    - gap: "deep_research"
      tools: [mcp-perplexity]
      skills: [tech-search, tech-research]  # Local skills covering this gap
```

### Step 2.2: Calculate Impact vs Effort Matrix

**Actions:**
```yaml
impact_effort_matrix:
  for_each_tool:
    impact_score:
      - capability_coverage: 0-10  # How much of gap does it fill?
      - quality_improvement: 0-10  # How much better is output?
      - automation_gain: 0-10      # How much manual work saved?

    effort_score:
      - installation_complexity: 0-10
      - integration_time: "hours/days"
      - cost: "$0/free | $X/month | enterprise"
      - learning_curve: "low | medium | high"
      - is_skill: true/false  # Skills get near-zero effort bonus

    roi_score: impact_score / effort_score

  quadrants:
    quick_wins: "High impact, low effort"
    strategic: "High impact, high effort"
    fill_ins: "Low impact, low effort"
    avoid: "Low impact, high effort"
```

### Step 2.3: Generate Integration Plan

**Actions:**
```yaml
integration_plan:
  immediate_actions:  # Quick wins
    - tool: "{mcp_name}"
      action: "Install and configure MCP"
      effort: "15 minutes"

  short_term:  # This week
    - tool: "{mcp_name}"
      action: "Install, configure, and test integration"
      effort: "1 hour"

  evaluate_later:  # Need more info
    - tool: "{tool_name}"
      reason: "Need to verify compatibility"
```

### Step 2.4: Generate Report

**Actions:**
```yaml
generate_report:
  file: ".aiox/squad-runtime/discovery/{domain}/tool-discovery-report.md"

  sections:
    - executive_summary: "1-paragraph summary of findings"
    - capability_gaps: "Table of gaps with priorities"
    - mcp_recommendations: "Scored MCP findings"
    - impact_effort_matrix: "Quick wins vs strategic investments"
    - integration_plan: "Prioritized implementation steps"
    - pro_upgrade_note: "What additional discovery pro version provides"

  pro_note: |
    This report covers MCP server discovery only.
    For comprehensive multi-source discovery, install squad-creator-pro:
      - API Discovery (REST, GraphQL, SaaS integrations)
      - CLI Tool Discovery (brew, npm, pip packages)
      - GitHub Project Discovery (reusable components)
      - Library Discovery (PyPI, npm SDKs)
      - Skill & Prompt Discovery (Claude Code skills, AI agent frameworks)
    Run: *discover-tools (pro version) for full coverage.
```

**Checkpoint SC_TDR_001:**
```yaml
heuristic_id: SC_TDR_001
name: "Tool Discovery Report Complete"
blocking: true
criteria:
  - all_gaps_researched: true
  - at_least_1_tool_per_gap: true
  - impact_effort_scored: true
  - integration_plan_created: true
  - report_generated: true
```

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Tool Discovery Report | `.aiox/squad-runtime/discovery/{domain}/tool-discovery-report.md` | MCP research findings |
| Capability Map | `.aiox/squad-runtime/discovery/{domain}/capability-tools.yaml` | Domain capability to tool mapping |
| Integration Plan | `.aiox/squad-runtime/discovery/{domain}/tool-integration-plan.md` | Prioritized implementation steps |

---

## Output Templates

### Tool Discovery Report Template

```markdown
# Tool Discovery Report: {Squad Name}

**Generated:** {date}
**Domain:** {domain}
**Gaps Analyzed:** {N}
**MCP Servers Discovered:** {total}

## Executive Summary

{1-paragraph summary of findings}

## Capability Gaps Identified

| Capability | Priority | MCPs Found | Recommended |
|------------|----------|------------|-------------|
| {gap} | {priority} | {count} | {mcp_name} |

## MCP Server Recommendations

### Quick Wins (Implement Now)

| MCP Server | Fills Gap | Score | Effort | Install Command |
|------------|-----------|-------|--------|-----------------|
| {mcp} | {gap} | {score} | {effort} | {install} |

### Strategic (Plan for)

{...}

## Impact vs Effort Matrix

{quadrant analysis}

## Integration Plan

### Immediate (Today)
- [ ] {action}

### Short-term (This Week)
- [ ] {action}

## Pro Version Available

For comprehensive discovery covering APIs, CLIs, Libraries, GitHub Projects,
and Skills/Prompts, install squad-creator-pro and run *discover-tools.

## Next Steps

1. {next step}
2. {next step}
```

---

## Integration with Squad Creation

### When to Execute

This task should be executed:

1. **During Squad Creation** - Phase 0.5 (after Discovery, before Architecture)
   ```yaml
   # In wf-create-squad.yaml
   - id: phase_0_5
     name: "TOOL DISCOVERY"
     task: "tasks/discover-tools.md"
     inputs:
       domain: "{domain}"
       use_cases: "{use_cases}"
   ```

2. **When Adding New Use Cases** - To find tools for new capabilities

3. **Periodically** - Monthly refresh to discover new MCP servers

### Task Dependencies

```yaml
depends_on:
  - "Phase 0: Discovery" # Need domain and use_cases

feeds_into:
  - "Phase 3: Creation" # Tools inform task design
  - "Phase 4: Integration" # Tools added to dependencies
```

---

## Validation Criteria

### Research Quality
- [ ] Domain intent validated from canonical artifacts before discovery
- [ ] No scope decision based only on squad/domain name
- [ ] Internal structure scanned before any external search
- [ ] External search scope derived from internal gaps
- [ ] All priority gaps researched
- [ ] At least 3 MCP sources searched
- [ ] Results validated (not just listed)

### Recommendations Quality
- [ ] Each recommendation has score
- [ ] Impact vs effort calculated
- [ ] Integration effort estimated

### Actionability
- [ ] Integration plan has concrete steps
- [ ] Quick wins identified
- [ ] Dependencies listed

---

## Error Handling

```yaml
error_handling:
  search_fails:
    - action: "Try alternative search queries"
    - fallback: "Mark gap as 'manual research needed'"

  no_tools_found:
    - action: "Expand search to adjacent domains"
    - fallback: "Document as 'custom development needed or check pro version'"

  api_access_denied:
    - action: "Note authentication requirements"
    - fallback: "Check for open alternatives"

  unknown_or_ambiguous_domain_scope:
    - action: "Stop external search and request clarification"
    - fallback: "Document scope as unverified and do not recommend tools"

  canonical_source_conflict:
    - action: "Prefer canonical hierarchy and log contradiction"
    - fallback: "Escalate for human decision before continuing"
```

---

## Examples

### Example 1: Copywriting Squad

**Input:**
```yaml
domain: "copywriting"
use_cases: ["sales pages", "email sequences", "headlines"]
capability_gaps: ["competitor_analysis", "headline_testing", "email_automation"]
```

**Output (Summarized):**
```yaml
mcps_discovered: 5
local_skills_covering: 2
top_recommendations:
  local_skills:
    - tech-search
  mcp:
    - mcp-server-playwright  # Screenshot competitor pages
    - mcp-server-pdf         # PDF swipe file processing
pro_note: "For API, CLI, Library, and Skill discovery, use squad-creator-pro."
```

### Example 2: Legal Squad

**Input:**
```yaml
domain: "legal"
use_cases: ["contract review", "compliance check", "legal research"]
capability_gaps: ["pdf_extraction", "legal_database"]
```

**Output (Summarized):**
```yaml
mcps_discovered: 3
local_skills_covering: 1
top_recommendations:
  local_skills:
    - tech-research
  mcp:
    - mcp-server-pdf        # PDF processing
pro_note: "For API, CLI, Library, and Skill discovery, use squad-creator-pro."
```

---

## Heuristics Reference

| Heuristic ID | Name | Where Applied | Blocking |
|--------------|------|---------------|----------|
| SC_DCV_001 | Domain Context Validation Gate | Phase -2 | Yes |
| SC_INT_001 | Internal Coverage Gate | Phase -1 | Yes |
| SC_MCP_001 | MCP Discovery Gate | Phase 1 | No |
| SC_TDR_001 | Tool Discovery Report | Phase 2 | Yes |

---

_Task Version: 3.0_
_Last Updated: 2026-02-24_
_Lines: 400+_
