# Task: Next Squad Recommendation

**Task ID:** next-squad
**Execution Type:** Hybrid (Script metrics + Agent analysis)
**Purpose:** Determine which squad should be created or improved next based on ecosystem analysis, business gaps, and backlog
**Orchestrator:** @squad-chief
**Mode:** Autonomous with optional elicitation
**Model:** `Sonnet` (analysis + synthesis over structured data)
**Haiku Eligible:** NO -- multi-dimensional prioritization requires interpretive reasoning

**Frameworks Used:**
- `{registry_path}` → Ecosystem state, gaps, extension candidates (Phase 1)
- `data/quality-dimensions-framework.md` → Scoring criteria (Phase 3)
- `data/tier-system-framework.md` → Squad maturity classification (Phase 2)

---

## Overview

This task answers the question: **"What squad should I build or improve next?"**

It analyzes 4 data sources, scores candidates across 5 dimensions, and outputs a ranked recommendation with clear rationale. Designed to be called standalone (`*next-squad`) or as Phase 0 of `*create-squad-smart`.

```
INPUT (optional: business_context, priority_domain)
    ↓
[PHASE 1: ECOSYSTEM SCAN]
    → Read ecosystem-registry.yaml (current state)
    → Identify extension candidates, config issues, gaps
    → Map domain coverage vs known needs
    ↓
[PHASE 2: SIGNAL COLLECTION]
    → Scan workspace for business signals (PRDs, stories, outputs)
    → Check recent git activity for momentum indicators
    → Detect implicit demand (frequent agent activations, failed lookups)
    ↓
[PHASE 3: SCORING]
    → Score each candidate across 5 dimensions
    → Rank by composite score
    → Separate into CREATE vs IMPROVE buckets
    ↓
[PHASE 4: RECOMMENDATION]
    → Present top 3 candidates with rationale
    → Show effort estimate (S/M/L)
    → Suggest execution path (*create-squad-smart or *brownfield-upgrade)
    ↓
OUTPUT: Ranked recommendation + execution command
```

---

## Inputs

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `business_context` | string | No | Optional business priority or constraint | "launching SaaS product Q2" |
| `priority_domain` | string | No | Optional domain to bias scoring toward | "sales", "finance" |
| `mode` | enum | No | `quick` (registry only) or `deep` (full workspace scan) | Default: `quick` |

---

## Preconditions

- [ ] `{registry_path}` exists and is current
- [ ] At least 1 squad exists in `squads/` directory
- [ ] `{registry_path}` resolved via `AIOX_ECOSYSTEM_REGISTRY_PATH` (fallback: `.aiox/squad-runtime/ecosystem-registry.yaml`)

**Recommended:** Run `*refresh-registry` before `*next-squad` for freshest data.

---

## PHASE 1: ECOSYSTEM SCAN

### Step 1.1: Load Registry State

**Action:**
```yaml
action: read
file: {registry_path}
extract:
  - metadata.total_squads
  - gaps.extension_candidates      # Squads that exist but are incomplete
  - gaps.potential_domains          # Domains not yet covered
  - gaps.removed_since_last_scan   # Squads that were removed (possible re-creation)
  - ecosystem_health.config_issues # Squads with structural problems
  - summary.*                      # Totals for context
```

### Step 1.2: Build Candidate Lists

**Action:** From registry data, build 3 candidate lists:

```yaml
candidates:
  CREATE:
    source: gaps.potential_domains + gaps.removed_since_last_scan
    description: "Squads that don't exist but could fill a business need"
    examples:
      - domain: "sales"
        reason: "No sales methodology squad (Sandler, Challenger, SPIN)"
      - domain: "finance"
        reason: "No financial analysis or FinOps squad"

  IMPROVE:
    source: gaps.extension_candidates
    description: "Squads that exist but are operationally incomplete"
    signals:
      - agents > 0 AND tasks == 0     → "Has minds but no workflows"
      - agents > 0 AND workflows == 0 → "Has agents but no orchestration"
      - has_readme == false            → "Undocumented"
      - config_issues present          → "Structural problems"

  FIX:
    source: ecosystem_health.config_issues
    description: "Squads with broken configs or structural issues"
    priority: "Quick wins — small effort, immediate health improvement"
```

### Step 1.3: Map Domain Coverage

**Action:** Build a coverage matrix showing which business domains are served:

```
Domain Coverage Matrix:
├── Strategy      → advisory-board ✅
├── Operations    → c-level, hormozi ✅
├── Marketing     → copy, storytelling, traffic-masters, movimento ✅
├── Brand         → brand ✅
├── Technical     → cybersecurity, db-sage, design, etl-ops ✅
├── Data          → data, spy ✅
├── Research      → deep-research ⚠️ (agents only, no tasks)
├── Meta          → squad-creator ✅
├── Sales         → ❌ GAP
├── Finance       → ❌ GAP
├── Product       → ❌ GAP
├── Legal         → ❌ GAP (was removed)
├── HR            → ❌ GAP (was removed)
├── Education     → ❌ GAP
└── Health        → ❌ GAP
```

---

## PHASE 2: SIGNAL COLLECTION

> **Only in `deep` mode.** Skip to Phase 3 if `mode=quick`.

### Step 2.1: Workspace Activity Scan

**Action:** Check recent workspace activity for demand signals:

```yaml
scan_locations:
  - pattern: "docs/stories/**/*.md"
    look_for: "References to domains without squads"
    signal: "Story mentions 'sales funnel' but no sales squad → demand signal"

  - pattern: "docs/prd/**/*.md"
    look_for: "PRDs that imply new domain needs"
    signal: "PRD for 'financial dashboard' → finance squad demand"

  - pattern: ".aiox/squad-runtime/**/*"
    look_for: "Ad-hoc outputs in domains without squads"
    signal: ".aiox/squad-runtime/legal-analysis/ exists but no legal squad → organic demand"

  - pattern: ".aiox/project-status.yaml"
    look_for: "Current epic/story context"
    signal: "Active work in a domain strengthens that domain's score"
```

### Step 2.2: Git Momentum Analysis

**Action:** Check recent commits for domain activity:

```bash
# Last 20 commits - which squads are being actively developed?
git log --oneline -20 --name-only | grep "squads/"
```

**Interpretation:**
- Squads with recent commits → Active development, may need supporting squads
- Squads with NO recent commits → Stale, may need revival or removal
- Non-squad commits mentioning domain keywords → Implicit demand

### Step 2.3: Removed Squad Analysis

**Action:** Cross-reference `gaps.removed_since_last_scan` with current needs:

```yaml
removed_squads_triage:
  for_each: gaps.removed_since_last_scan
  check:
    - "Was it removed intentionally (deprecated) or accidentally (cleanup)?"
    - "Does the domain still have business relevance?"
    - "Are there residual artifacts in .aiox/squad-runtime/ or docs/?"
  classify:
    - REVIVE: "Domain still relevant, removal was cleanup, re-create with current standards"
    - ARCHIVE: "Domain no longer relevant, document why, move on"
    - MERGE: "Functionality absorbed by another squad"
```

---

## PHASE 3: SCORING

### Step 3.1: Score Each Candidate

**Action:** Apply 5-dimension scoring (1-5 each, max 25):

```yaml
scoring_dimensions:
  D1_business_impact:
    question: "How much does this squad accelerate business goals?"
    weight: 1.5  # Most important
    scoring:
      5: "Directly unblocks revenue or core product"
      4: "Supports active business initiative"
      3: "General operational improvement"
      2: "Nice to have, no urgency"
      1: "Theoretical benefit only"

  D2_ecosystem_synergy:
    question: "How well does this squad integrate with existing squads?"
    weight: 1.2
    scoring:
      5: "Fills critical gap between 2+ active squads"
      4: "Complements active squad workflows"
      3: "Independent but compatible"
      2: "Minimal overlap or connection"
      1: "Isolated domain"

  D3_effort_vs_reward:
    question: "What's the ROI of creating/improving this squad?"
    weight: 1.0
    scoring:
      5: "Low effort, high reward (FIX/quick extension)"
      4: "Medium effort, high reward"
      3: "Medium effort, medium reward"
      2: "High effort, medium reward"
      1: "High effort, low reward"

  D4_demand_signals:
    question: "How many signals indicate this squad is needed?"
    weight: 1.3
    scoring:
      5: "3+ explicit signals (PRD, stories, user requests)"
      4: "2 signals (workspace activity + business need)"
      3: "1 clear signal"
      2: "Inferred from ecosystem gaps only"
      1: "No signals, purely speculative"

  D5_foundation_readiness:
    question: "How ready is the foundation to build on?"
    weight: 1.0
    scoring:
      5: "Agents exist, just need tasks/workflows (IMPROVE)"
      4: "Minds already researched, sources available"
      3: "Domain has well-known elite minds"
      2: "Domain exists but elite minds unclear"
      1: "Niche domain, research-heavy"
```

### Step 3.2: Calculate Composite Score

**Formula:**
```
composite = (D1 × 1.5) + (D2 × 1.2) + (D3 × 1.0) + (D4 × 1.3) + (D5 × 1.0)
max_possible = 25 × avg_weight = 30.0
normalized = (composite / 30.0) × 10  # Scale 0-10
```

### Step 3.3: Rank and Classify

**Action:** Sort candidates by composite score, classify by action type:

```yaml
classification:
  score >= 7.0: "🔴 HIGH PRIORITY — Do next"
  score 5.0-6.9: "🟡 MEDIUM — Plan for soon"
  score < 5.0: "🟢 LOW — Backlog"

action_type:
  FIX: "Config fix, README addition, quick structural repair"
  IMPROVE: "Add tasks/workflows to existing squad"
  CREATE: "Full squad creation from research"
```

---

## PHASE 4: RECOMMENDATION

### Step 4.1: Present Top 3

**Output format:**

```markdown
## 🎯 Next Squad Recommendation

### Analysis Summary
- **Ecosystem:** {total_squads} squads | {total_agents} agents | {total_tasks} tasks
- **Domain Coverage:** {covered}/{total_domains} domains covered
- **Health Issues:** {config_issues_count} squads with config problems
- **Extension Candidates:** {extension_count} squads need completion

---

### #1: {CANDIDATE_NAME} — {ACTION_TYPE}
**Score:** {normalized}/10 | **Effort:** {S|M|L} | **Type:** {CREATE|IMPROVE|FIX}

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Business Impact | {D1}/5 | {reason} |
| Ecosystem Synergy | {D2}/5 | {reason} |
| Effort vs Reward | {D3}/5 | {reason} |
| Demand Signals | {D4}/5 | {reason} |
| Foundation Ready | {D5}/5 | {reason} |

**Why this is #1:** {2-3 sentence explanation}
**Execute:** `*{command} {args}`

---

### #2: {CANDIDATE_NAME} — {ACTION_TYPE}
...

### #3: {CANDIDATE_NAME} — {ACTION_TYPE}
...

---

### Quick Wins (FIX — do anytime)
- [ ] {squad}: {issue} → {fix command}
- [ ] {squad}: {issue} → {fix command}
```

### Step 4.2: Suggest Execution Path

**Decision tree:**

```yaml
execution_path:
  if_action == FIX:
    command: "Direct fix (no workflow needed)"
    example: "Fix cybersecurity config.yaml syntax error"
    effort: S

  if_action == IMPROVE:
    command: "*brownfield-upgrade {squad_name}"
    example: "Add tasks and workflows to deep-research squad"
    effort: M

  if_action == CREATE:
    command: "*create-squad-smart {domain}"
    example: "Create sales squad from scratch"
    effort: L
```

---

## Outputs

| Output | Format | Location |
|--------|--------|----------|
| Recommendation report | Markdown | Displayed in terminal |
| Candidate scores | YAML (optional) | `.aiox/squad-runtime/next-squad/scores-{date}.yaml` |

**Primary output:** Terminal display with actionable recommendation.
**Optional:** Save scores to file with `--save` flag.

---

## Validation

```yaml
validation:
  - criterion: "At least 3 candidates identified and scored"
    type: blocking

  - criterion: "All 5 dimensions scored for top 3 candidates"
    type: blocking

  - criterion: "Each recommendation includes executable command"
    type: blocking

  - criterion: "Scores are justified with evidence, not assumptions"
    type: blocking

  - criterion: "business_context (if provided) influenced scoring"
    type: warning

  - criterion: "Registry data is < 24h old"
    type: warning
    fix: "Run *refresh-registry first"
```

---

## Veto Conditions

```yaml
veto:
  - condition: "ecosystem-registry.yaml not found or empty"
    action: "BLOCK — run *refresh-registry first"

  - condition: "All candidates score < 3.0"
    action: "WARN — ecosystem may be mature, consider domain expansion research"

  - condition: "business_context contradicts top recommendation"
    action: "RERANK — user priority overrides composite score"
```

---

## Command Integration

```bash
# Quick mode (registry analysis only)
*next-squad

# Deep mode (full workspace scan)
*next-squad --deep

# With business context
*next-squad --context "launching SaaS product"

# Biased toward specific domain
*next-squad --domain sales

# Save scores to file
*next-squad --save
```

---

## Examples

### Example 1: Quick Mode Output

```
🎯 Next Squad Recommendation

Analysis: 17 squads | 164 agents | 423 tasks | 12/19 domains covered

#1: deep-research — IMPROVE
Score: 8.2/10 | Effort: M | Type: IMPROVE
Why: 11 elite minds (Kahneman, Cochrane) already cloned but ZERO tasks/workflows.
     Highest ROI — agents exist, just need operational artifacts.
Execute: *brownfield-upgrade deep-research

#2: sales — CREATE
Score: 7.1/10 | Effort: L | Type: CREATE
Why: Zero coverage for sales methodology. Synergy with copy + hormozi squads.
     Well-known elite minds available (Sandler, Challenger, SPIN Selling).
Execute: *create-squad-smart sales

#3: cybersecurity — FIX
Score: 6.8/10 | Effort: S | Type: FIX
Why: config.yaml has YAML syntax error. Quick fix, immediate health gain.
Execute: Fix squads/cybersecurity/config.yaml line 422-423

Quick Wins:
- [ ] cybersecurity: YAML syntax error → fix config.yaml
- [ ] c-level: Missing config.yaml → generate from template
- [ ] deep-research: Missing README + config → generate basics
```

### Example 2: Deep Mode with Context

```
*next-squad --deep --context "preparing for product launch"

🎯 Next Squad Recommendation (Deep Analysis)

Analysis: 17 squads | 164 agents | Workspace signals: 4 detected

#1: sales — CREATE
Score: 8.7/10 | Effort: L | Type: CREATE
Why: Product launch demands sales methodology. Found 2 PRD references to
     "sales funnel" and "conversion optimization" without squad coverage.
     Direct synergy with copy (persuasion) + hormozi (offers) + traffic-masters (leads).
Execute: *create-squad-smart sales
```

---

_Task Version: 1.0.0_
_Created: 2026-02-18_
_Author: squad-chief_
