# Task: apex-compare

```yaml
id: apex-compare
version: "1.0.0"
title: "Apex Visual Compare"
description: >
  Receives two visual inputs (screenshots, prints, or one screenshot + current
  implementation) and produces a dimension-by-dimension comparison. Highlights
  differences, scores delta per dimension, and presents options to align.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-visual-analyze.md
  - tasks/apex-fix.md
  - tasks/apex-quick.md
outputs:
  - Side-by-side dimensional comparison report
  - Delta scores per dimension
  - Actionable alignment options
```

---

## Command

### `*apex-compare`

User provides two visual references to compare.

---

## Input Modes

```yaml
input_modes:
  two_images:
    description: "User sends 2 screenshots"
    action: "Compare directly"

  image_vs_current:
    description: "User sends 1 screenshot + mentions a page/component"
    action: "Apex captures current state from code analysis, compares"

  image_vs_preset:
    description: "User sends 1 screenshot + says 'compare with {preset}'"
    action: "Load preset spec from design-presets.yaml, compare"

  before_after:
    description: "User wants to see what changed after a fix/transform"
    action: "Use cached pre-operation screenshot vs current state"
```

---

## How It Works

### Step 1: Identify Both Inputs

```yaml
identification:
  image_a:
    label: "A"  # Reference / Before / External
    source: "{internal|external|preset}"
    scope: "{micro|component|section|page}"

  image_b:
    label: "B"  # Current / After / Target
    source: "{internal|external|preset}"
    scope: "{micro|component|section|page}"
```

### Step 2: Dimension-by-Dimension Comparison

For each of the 8 dimensions, compare A vs B:

```yaml
comparison_dimensions:
  layout:
    agent: "@css-eng"
    compare:
      - Grid structure match
      - Spacing differences (identify specific gaps)
      - Alignment discrepancies
      - Responsive approach differences
    output: "Delta description + which is better"

  typography:
    agent: "@css-eng"
    compare:
      - Font family match
      - Size scale comparison
      - Weight usage differences
      - Line height / letter spacing gaps
    output: "Delta description + which is better"

  color:
    agent: "@design-sys-eng"
    compare:
      - Palette similarity (% match)
      - Contrast ratio differences
      - Brand color alignment
      - Semantic color usage (error, success, warning)
    output: "Delta description + extracted colors from both"

  composition:
    agent: "@interaction-dsgn"
    compare:
      - Visual hierarchy comparison
      - White space usage
      - CTA placement and prominence
      - Content density
    output: "Delta description + recommendations"

  interaction_design:
    agent: "@interaction-dsgn"
    compare:
      - Affordance clarity comparison
      - State visibility differences
      - Navigation patterns
      - User flow alignment
    output: "Delta description + which patterns are stronger"

  motion:
    agent: "@motion-eng"
    compare:
      - Animation approach differences
      - Motion personality (playful vs. professional)
      - Spring vs. bezier usage
    output: "Delta description + recommendation"

  accessibility:
    agent: "@a11y-eng"
    compare:
      - Contrast ratios both
      - Touch target sizes both
      - Semantic structure comparison
    output: "Delta description + which is more accessible"

  performance:
    agent: "@perf-eng"
    compare:
      - Visual complexity (layers, shadows, blurs)
      - Image usage differences
      - Animation performance risk
    output: "Delta description + lighter approach"
```

### Step 3: Generate Comparison Report

```yaml
report_format: |
  ## Comparacao Visual — A vs B

  | Dimensao | A ({label_a}) | B ({label_b}) | Delta | Melhor |
  |----------|---------------|---------------|-------|--------|
  | Layout | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | Tipografia | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | Cores | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | Composicao | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | Interacao | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | Motion | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | Acessibilidade | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | Performance | {score_a}/100 | {score_b}/100 | {delta} | {A|B|Empate} |
  | **GERAL** | **{avg_a}** | **{avg_b}** | **{total_delta}** | **{winner}** |

  ### Diferencas Chave
  1. {key_diff_1}
  2. {key_diff_2}
  3. {key_diff_3}

  ### O que A faz melhor
  - {a_strength_1}
  - {a_strength_2}

  ### O que B faz melhor
  - {b_strength_1}
  - {b_strength_2}
```

### Step 4: Present Options

```yaml
options:
  1_adopt_a:
    label: "ADOTAR A — Alinhar implementacao com A"
    action: "Extract A tokens, generate fix plan, route to pipeline"

  2_adopt_b:
    label: "ADOTAR B — Manter B como esta"
    action: "Log comparison, no changes"

  3_best_of_both:
    label: "MELHOR DOS DOIS — Combinar pontos fortes de A e B"
    action: "Cherry-pick: use A's {strengths} + B's {strengths}, generate hybrid plan"

  4_neither:
    label: "NENHUM — Quero algo diferente"
    action: "Route to *apex-inspire for preset catalog"

  5_analyze_deeper:
    label: "APROFUNDAR — Analisar uma dimensao especifica"
    action: "User picks dimension, deep dive with specialist agent"

  6_done:
    label: "DONE — Encerrar comparacao"
    action: "End chain"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-CMP-001
    condition: "Comparison executed with only 1 input"
    action: "VETO — Both inputs required. Ask for missing input."
    available_check: "manual"
    on_unavailable: BLOCK

  - id: VC-CMP-002
    condition: "Adopt/hybrid action executed without user confirmation"
    action: "VETO — Present plan and wait for approval."
    available_check: "manual"
    on_unavailable: BLOCK
```

---

## Quality Gate

```yaml
gate:
  id: QG-apex-compare
  blocker: true
  criteria:
    - "Both inputs identified and labeled"
    - "All 8 dimensions compared"
    - "Key differences listed (min 3)"
    - "Options presented after comparison"
    - "User choice recorded before execution"
  on_fail: "BLOCK — complete comparison before options"
  on_pass: "Route to selected action"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | Selected pipeline based on user choice |
| Artifact | Comparison report + user decision |
| Next action | Execute alignment (adopt A, best of both, or inspire) |

---

*Apex Squad — Visual Compare Task v1.0.0*
